#!/usr/bin/env node
// Fetch open GitHub security advisories (triage/draft), Dependabot alerts,
// code scanning alerts, and secret scanning alerts for beste + jeromegamez.
//
// Usage:
//   fetch-alerts.mjs [--json] [owner/repo ...]

import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);
const CONCURRENCY = 8;

const rawArgs = process.argv.slice(2);
const asJson = rawArgs.includes('--json');
const targets = rawArgs.filter((a) => a !== '--json');

async function ghApi(endpoint) {
  try {
    const { stdout } = await execFileAsync('gh', ['api', '--paginate', endpoint], {
      encoding: 'utf8',
      maxBuffer: 20 * 1024 * 1024,
    });
    // `gh api --paginate` concatenates JSON arrays across pages (`[...][...]`)
    const trimmed = stdout.trim();
    if (!trimmed) return [];
    return JSON.parse(trimmed.replace(/\]\s*\[/g, ','));
  } catch {
    // shortcut: 403/404 from repos with a feature disabled are ignored; upgrade if we need to audit which repos lack scanning
    return [];
  }
}

async function mapPool(items, limit, fn) {
  const results = new Array(items.length);
  let i = 0;
  async function worker() {
    while (i < items.length) {
      const idx = i++;
      results[idx] = await fn(items[idx]);
    }
  }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
}

const mapAdvisory = (repo) => (a) => ({
  repo: a.repository?.full_name || repo,
  id: a.ghsa_id,
  state: a.state,
  severity: a.severity || 'unknown',
  summary: a.summary || '',
  url: a.html_url || null,
});

const mapDependabot = (repo) => (a) => ({
  repo: a.repository?.full_name || repo,
  number: a.number,
  severity: a.security_advisory?.severity || 'unknown',
  package: a.dependency?.package?.name || '',
  manifest: a.dependency?.manifest_path || '',
  summary: a.security_advisory?.summary || '',
  url: a.html_url || null,
});

const mapCodeScan = (repo) => (a) => ({
  repo: a.repository?.full_name || repo,
  number: a.number,
  tool: a.tool?.name || '',
  rule: a.rule?.id || '',
  severity: a.rule?.security_severity_level || a.rule?.severity || 'unknown',
  path: a.most_recent_instance?.location?.path || '',
  url: a.html_url || null,
});

const mapSecret = (repo) => (a) => ({
  repo: a.repository?.full_name || repo,
  number: a.number,
  type: a.secret_type_display_name || a.secret_type || '',
  state: a.state || '',
  url: a.html_url || null,
});

function buildTasks(repoTargets) {
  const tasks = [];
  const addRepo = (r) => {
    tasks.push(
      { kind: 'advisories', repo: r, endpoint: `repos/${r}/security-advisories?per_page=100` },
      { kind: 'dependabot', repo: r, endpoint: `repos/${r}/dependabot/alerts?state=open&per_page=100` },
      { kind: 'codeScanning', repo: r, endpoint: `repos/${r}/code-scanning/alerts?state=open&per_page=100` },
      { kind: 'secretScanning', repo: r, endpoint: `repos/${r}/secret-scanning/alerts?state=open&per_page=100` },
    );
  };
  for (const r of repoTargets) addRepo(r);
  return tasks;
}

try {
  await execFileAsync('gh', ['auth', 'status']);
} catch {
  process.stderr.write("error: gh is not authenticated (run 'gh auth login')\n");
  process.exit(1);
}

let tasks = [];
if (targets.length > 0) {
  tasks = buildTasks(targets);
} else {
  tasks.push(
    { kind: 'advisories', repo: '', endpoint: 'orgs/beste/security-advisories?per_page=100' },
    { kind: 'dependabot', repo: '', endpoint: 'orgs/beste/dependabot/alerts?state=open&per_page=100' },
    { kind: 'codeScanning', repo: '', endpoint: 'orgs/beste/code-scanning/alerts?state=open&per_page=100' },
    { kind: 'secretScanning', repo: '', endpoint: 'orgs/beste/secret-scanning/alerts?state=open&per_page=100' },
  );
  const userRepos = await ghApi('users/jeromegamez/repos?type=owner&per_page=100');
  const active = userRepos.filter((r) => !r.archived && !r.fork).map((r) => r.full_name);
  tasks.push(...buildTasks(active));
}

const out = { advisories: [], dependabot: [], codeScanning: [], secretScanning: [] };

await mapPool(tasks, CONCURRENCY, async (t) => {
  const items = await ghApi(t.endpoint);
  if (!Array.isArray(items) || items.length === 0) return;
  if (t.kind === 'advisories') {
    const open = items.filter((a) => a.state !== 'published' && a.state !== 'closed');
    out.advisories.push(...open.map(mapAdvisory(t.repo)));
  } else if (t.kind === 'dependabot') {
    out.dependabot.push(...items.map(mapDependabot(t.repo)));
  } else if (t.kind === 'codeScanning') {
    out.codeScanning.push(...items.map(mapCodeScan(t.repo)));
  } else if (t.kind === 'secretScanning') {
    out.secretScanning.push(...items.map(mapSecret(t.repo)));
  }
});

if (asJson) {
  process.stdout.write(JSON.stringify({ fetchedAt: new Date().toISOString(), ...out }, null, 2) + '\n');
} else {
  const printSection = (title, lines) => {
    process.stdout.write(`=== ${title} ===\n`);
    process.stdout.write(lines.length ? `${lines.join('\n')}\n\n` : '(none)\n\n');
  };
  printSection(
    'Security Advisories (triage / draft)',
    out.advisories.map((a) => `${a.repo} | ${a.id} | ${a.state} | ${a.severity} | ${a.summary}`),
  );
  printSection(
    'Dependabot Alerts (open)',
    out.dependabot.map((a) => `${a.repo}#${a.number} | ${a.severity} | ${a.package} (${a.manifest}) | ${a.summary}`),
  );
  printSection(
    'Code Scanning Alerts (open)',
    out.codeScanning.map((a) => `${a.repo}#${a.number} | ${a.tool} | ${a.rule} (${a.severity}) | ${a.path}`),
  );
  printSection(
    'Secret Scanning Alerts (open)',
    out.secretScanning.map((a) => `${a.repo}#${a.number} | ${a.type} | ${a.state}`),
  );
}
