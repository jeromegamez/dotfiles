#!/usr/bin/env node
// Fetches status of unarchived, non-fork repos for GitHub orgs/users via `gh api graphql`.
// Usage: node fetch-status.mjs [owner1 owner2 ...] (defaults to: beste jeromegamez)

import { execFile, execFileSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);
const __dirname = dirname(fileURLToPath(import.meta.url));
const FETCH_ALERTS = resolve(__dirname, '../../security-audit/scripts/fetch-alerts.mjs');

const DEFAULT_OWNERS = ['beste', 'jeromegamez'];
const BOT_LOGINS = new Set(['renovate', 'dependabot', 'github-actions']);

const QUERY = `
query($owner: String!, $cursor: String) {
  repositoryOwner(login: $owner) {
    __typename
    login
    repositories(
      first: 50
      after: $cursor
      isFork: false
      ownerAffiliations: OWNER
      orderBy: { field: PUSHED_AT, direction: DESC }
    ) {
      pageInfo { hasNextPage endCursor }
      nodes {
        nameWithOwner
        name
        url
        isPrivate
        isArchived
        pushedAt
        defaultBranchRef {
          name
          target {
            ... on Commit {
              oid
              committedDate
              statusCheckRollup { state }
              history(first: 25) {
                nodes { oid }
              }
            }
          }
        }
        latestRelease {
          tagName
          publishedAt
          url
          tagCommit { oid }
        }
        issues(states: OPEN) { totalCount }
        vulnerabilityAlerts(states: OPEN) { totalCount }
        pullRequests(states: OPEN, first: 50, orderBy: { field: UPDATED_AT, direction: DESC }) {
          totalCount
          nodes {
            number
            title
            url
            isDraft
            createdAt
            updatedAt
            mergeable
            author { login __typename }
            commits(last: 1) {
              nodes {
                commit {
                  statusCheckRollup { state }
                }
              }
            }
          }
        }
      }
    }
  }
}
`;

function ghGraphql(variables) {
  const args = ['api', 'graphql', '-f', `query=${QUERY}`];
  for (const [k, v] of Object.entries(variables)) {
    if (v !== null && v !== undefined) args.push('-F', `${k}=${v}`);
  }
  const out = execFileSync('gh', args, { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });
  const parsed = JSON.parse(out);
  if (parsed.errors?.length) {
    throw new Error(`GraphQL error: ${parsed.errors.map((e) => e.message).join('; ')}`);
  }
  return parsed.data;
}

function isBotAuthor(author) {
  if (!author) return false;
  if (author.__typename === 'Bot') return true;
  const login = (author.login || '').toLowerCase().replace(/\[bot\]$/, '');
  return BOT_LOGINS.has(login);
}

function commitsSinceRelease(repo) {
  const tagOid = repo.latestRelease?.tagCommit?.oid;
  const history = repo.defaultBranchRef?.target?.history?.nodes;
  if (!tagOid || !history?.length) return null;
  const idx = history.findIndex((c) => c.oid === tagOid);
  return idx === -1 ? `${history.length}+` : idx;
}

function fetchOwner(owner) {
  const repos = [];
  let cursor = null;
  while (true) {
    const data = ghGraphql({ owner, cursor });
    const ro = data.repositoryOwner;
    if (!ro) throw new Error(`Owner not found: ${owner}`);
    for (const r of ro.repositories.nodes) {
      if (r.isArchived) continue;
      const prs = r.pullRequests.nodes.map((pr) => ({
        number: pr.number,
        title: pr.title,
        url: pr.url,
        isDraft: pr.isDraft,
        author: pr.author?.login ?? 'ghost',
        isBot: isBotAuthor(pr.author),
        createdAt: pr.createdAt,
        updatedAt: pr.updatedAt,
        mergeable: pr.mergeable,
        ci: pr.commits.nodes[0]?.commit?.statusCheckRollup?.state ?? null,
      }));
      repos.push({
        owner: ro.login,
        name: r.name,
        nameWithOwner: r.nameWithOwner,
        url: r.url,
        isPrivate: r.isPrivate,
        pushedAt: r.pushedAt,
        defaultBranch: r.defaultBranchRef?.name ?? null,
        ci: r.defaultBranchRef?.target?.statusCheckRollup?.state ?? null,
        latestRelease: r.latestRelease
          ? {
              tag: r.latestRelease.tagName,
              publishedAt: r.latestRelease.publishedAt,
              url: r.latestRelease.url,
            }
          : null,
        commitsSinceRelease: commitsSinceRelease(r),
        openIssues: r.issues.totalCount,
        dependabotAlerts: r.vulnerabilityAlerts.totalCount,
        openPrCount: r.pullRequests.totalCount,
        pullRequests: prs,
      });
    }
    if (!ro.repositories.pageInfo.hasNextPage) break;
    cursor = ro.repositories.pageInfo.endCursor;
  }
  return repos;
}

const owners = process.argv.slice(2).length ? process.argv.slice(2) : DEFAULT_OWNERS;
const useDefaultOwners =
  owners.length === DEFAULT_OWNERS.length && owners.every((o, i) => o === DEFAULT_OWNERS[i]);

const alertsPromise = useDefaultOwners
  ? execFileAsync(process.execPath, [FETCH_ALERTS, '--json'], {
      encoding: 'utf8',
      maxBuffer: 20 * 1024 * 1024,
    }).then(({ stdout }) => JSON.parse(stdout))
  : Promise.resolve(null);

const repos = owners.flatMap(fetchOwner);
const alerts = await alertsPromise;

const secByRepo = new Map();
const bump = (repoName, key) => {
  if (!repoName) return;
  let entry = secByRepo.get(repoName);
  if (!entry) {
    entry = { advisories: 0, dependabot: 0, codeScanning: 0, secretScanning: 0, total: 0 };
    secByRepo.set(repoName, entry);
  }
  entry[key]++;
  entry.total++;
};

if (alerts) {
  for (const a of alerts.advisories) bump(a.repo, 'advisories');
  for (const a of alerts.dependabot) bump(a.repo, 'dependabot');
  for (const a of alerts.codeScanning) bump(a.repo, 'codeScanning');
  for (const a of alerts.secretScanning) bump(a.repo, 'secretScanning');
}

for (const r of repos) {
  r.security = secByRepo.get(r.nameWithOwner) ?? {
    advisories: 0,
    dependabot: r.dependabotAlerts,
    codeScanning: 0,
    secretScanning: 0,
    total: r.dependabotAlerts,
  };
}

process.stdout.write(
  JSON.stringify(
    {
      fetchedAt: new Date().toISOString(),
      owners,
      repoCount: repos.length,
      securityTotals: alerts
        ? {
            advisories: alerts.advisories.length,
            dependabot: alerts.dependabot.length,
            codeScanning: alerts.codeScanning.length,
            secretScanning: alerts.secretScanning.length,
            total:
              alerts.advisories.length +
              alerts.dependabot.length +
              alerts.codeScanning.length +
              alerts.secretScanning.length,
          }
        : null,
      repos,
    },
    null,
    2,
  ) + '\n',
);
