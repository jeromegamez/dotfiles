#!/usr/bin/env node
// Renders JSON from fetch-status.mjs (stdin) to a self-contained HTML dashboard (stdout).

import { readFileSync } from 'node:fs';

const data = JSON.parse(readFileSync(0, 'utf8'));

const esc = (s) =>
  String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

const nowMs = Date.parse(data.fetchedAt);
function relDate(iso) {
  if (!iso) return '-';
  const days = Math.floor((nowMs - Date.parse(iso)) / 86400000);
  if (days <= 0) return 'today';
  if (days === 1) return '1d ago';
  if (days < 30) return `${days}d ago`;
  const months = Math.floor(days / 30);
  return months < 12 ? `${months}mo ago` : `${Math.floor(months / 12)}y ago`;
}

function ciBadge(state) {
  if (!state) return '<span class="badge muted">none</span>';
  const s = state.toUpperCase();
  if (s === 'SUCCESS') return '<span class="badge ok">pass</span>';
  if (s === 'FAILURE' || s === 'ERROR') return '<span class="badge err">fail</span>';
  return `<span class="badge warn">${esc(s.toLowerCase())}</span>`;
}

const repos = data.repos;
const secTotal = (r) => r.security?.total ?? r.dependabotAlerts ?? 0;
const secBreakdown = (s) => {
  if (!s) return 'Dependabot';
  const parts = [];
  if (s.advisories) parts.push(`${s.advisories} advisory`);
  if (s.secretScanning) parts.push(`${s.secretScanning} secret`);
  if (s.codeScanning) parts.push(`${s.codeScanning} code-scan`);
  if (s.dependabot) parts.push(`${s.dependabot} dependabot`);
  return parts.join(', ') || 'none';
};

const failingRepos = repos.filter((r) => r.ci === 'FAILURE' || r.ci === 'ERROR');
const alertRepos = repos.filter((r) => secTotal(r) > 0);
const allPrs = repos
  .flatMap((r) => r.pullRequests.map((pr) => ({ ...pr, repo: r.nameWithOwner, repoUrl: r.url })))
  .sort((a, b) => {
    const aScore = (!a.isBot ? 0 : 2) + (a.ci === 'FAILURE' || a.ci === 'ERROR' || a.mergeable === 'CONFLICTING' ? 0 : 1);
    const bScore = (!b.isBot ? 0 : 2) + (b.ci === 'FAILURE' || b.ci === 'ERROR' || b.mergeable === 'CONFLICTING' ? 0 : 1);
    return aScore - bScore || Date.parse(b.updatedAt) - Date.parse(a.updatedAt);
  });

const humanPrCount = allPrs.filter((p) => !p.isBot).length;
const botPrCount = allPrs.length - humanPrCount;
const totalAlerts = data.securityTotals?.total ?? repos.reduce((s, r) => s + secTotal(r), 0);
const totalIssues = repos.reduce((s, r) => s + r.openIssues, 0);

const owners = [...new Set(repos.map((r) => r.owner))];

const attentionItems = [
  ...failingRepos.map(
    (r) =>
      `<li><span class="badge err">CI fail</span> <a href="${esc(r.url)}" target="_blank">${esc(r.nameWithOwner)}</a> <span class="dim">(${esc(r.defaultBranch)}, pushed ${relDate(r.pushedAt)})</span></li>`,
  ),
  ...alertRepos.map(
    (r) =>
      `<li><span class="badge warn">${secTotal(r)} alert${secTotal(r) > 1 ? 's' : ''}</span> <a href="${esc(r.url)}/security" target="_blank">${esc(r.nameWithOwner)}</a> <span class="dim">${esc(secBreakdown(r.security))}</span></li>`,
  ),
];

const prRows = allPrs
  .map((pr) => {
    const flags = [
      pr.isBot ? '<span class="badge muted">bot</span>' : '<span class="badge info">human</span>',
      pr.isDraft ? '<span class="badge muted">draft</span>' : '',
      pr.mergeable === 'CONFLICTING' ? '<span class="badge err">conflict</span>' : '',
      ciBadge(pr.ci),
    ]
      .filter(Boolean)
      .join(' ');
    return `<tr>
      <td><a href="${esc(pr.url)}" target="_blank">${esc(pr.repo)}#${pr.number}</a><div class="pr-title">${esc(pr.title)}</div></td>
      <td class="nowrap">${flags}</td>
      <td class="dim nowrap">${esc(pr.author)} · ${relDate(pr.updatedAt)}</td>
    </tr>`;
  })
  .join('\n');

const repoRows = repos
  .map((r) => {
    const alertsCount = secTotal(r);
    const hasProblem =
      r.ci === 'FAILURE' ||
      r.ci === 'ERROR' ||
      alertsCount > 0 ||
      r.openPrCount > 0;
    const rel = r.latestRelease
      ? `<a href="${esc(r.latestRelease.url)}" target="_blank">${esc(r.latestRelease.tag)}</a>${
          r.commitsSinceRelease && r.commitsSinceRelease !== 0
            ? ` <span class="dim">+${esc(r.commitsSinceRelease)}</span>`
            : ''
        }`
      : '<span class="dim">-</span>';
    const prsCell = r.openPrCount
      ? `<a href="${esc(r.url)}/pulls" target="_blank">${r.openPrCount}</a>`
      : '<span class="dim">0</span>';
    const issCell = r.openIssues
      ? `<a href="${esc(r.url)}/issues" target="_blank">${r.openIssues}</a>`
      : '<span class="dim">0</span>';
    const secCell = alertsCount
      ? `<a class="warn-txt" title="${esc(secBreakdown(r.security))}" href="${esc(r.url)}/security" target="_blank">${alertsCount}</a>`
      : '<span class="dim">0</span>';

    return `<tr data-owner="${esc(r.owner)}" data-attention="${hasProblem ? '1' : '0'}">
      <td><a href="${esc(r.url)}" target="_blank">${esc(r.nameWithOwner)}</a>${r.isPrivate ? ' <span class="badge muted">priv</span>' : ''}</td>
      <td>${ciBadge(r.ci)}</td>
      <td class="num">${prsCell}</td>
      <td class="num">${issCell}</td>
      <td class="num">${secCell}</td>
      <td class="nowrap">${rel}</td>
      <td class="dim nowrap">${relDate(r.pushedAt)}</td>
    </tr>`;
  })
  .join('\n');

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Repo Status</title>
<style>
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font-family: var(--font-sans, system-ui, -apple-system, sans-serif);
    font-size: 13px;
    line-height: 1.45;
    color: var(--foreground, #e5e7eb);
  }
  a { color: var(--primary, #60a5fa); text-decoration: none; }
  a:hover { text-decoration: underline; }
  .grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; margin-bottom: 14px; }
  @media (max-width: 560px) { .grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
  .kpi {
    background: var(--card, #18181b);
    border: 1px solid var(--border, #27272a);
    border-radius: var(--radius, 8px);
    padding: 12px 14px;
  }
  .kpi-label { font-size: 11px; color: var(--muted-foreground, #a1a1aa); text-transform: uppercase; letter-spacing: 0.04em; }
  .kpi-val { font-size: 22px; font-weight: 600; margin-top: 2px; font-variant-numeric: tabular-nums; }
  .kpi-sub { font-size: 11px; color: var(--muted-foreground, #a1a1aa); margin-top: 2px; }
  .section {
    background: var(--card, #18181b);
    border: 1px solid var(--border, #27272a);
    border-radius: var(--radius, 8px);
    padding: 14px 16px;
    margin-bottom: 14px;
  }
  .section-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; flex-wrap: wrap; margin-bottom: 10px; }
  h2 { margin: 0; font-size: 13px; font-weight: 600; }
  .att-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 6px; }
  .table-wrap { overflow-x: auto; }
  table { width: 100%; border-collapse: collapse; }
  th, td { text-align: left; padding: 6px 8px; border-bottom: 1px solid var(--border, #27272a); vertical-align: top; }
  th { font-size: 11px; font-weight: 500; color: var(--muted-foreground, #a1a1aa); text-transform: uppercase; letter-spacing: 0.03em; }
  tr:last-child td { border-bottom: 0; }
  .num { text-align: right; font-variant-numeric: tabular-nums; }
  .nowrap { white-space: nowrap; }
  .dim { color: var(--muted-foreground, #a1a1aa); }
  .pr-title { font-size: 12px; color: var(--muted-foreground, #a1a1aa); margin-top: 2px; }
  .badge {
    display: inline-block;
    padding: 1px 6px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 500;
    line-height: 1.5;
  }
  .badge.ok { background: color-mix(in srgb, var(--success, #22c55e) 18%, transparent); color: var(--success, #22c55e); }
  .badge.err { background: var(--destructive-surface, rgba(239,68,68,.16)); color: var(--destructive, #ef4444); }
  .badge.warn { background: var(--warning-surface, rgba(245,158,11,.16)); color: var(--warning, #f59e0b); }
  .badge.info { background: color-mix(in srgb, var(--info, #3b82f6) 18%, transparent); color: var(--info, #3b82f6); }
  .badge.muted { background: var(--secondary, #27272a); color: var(--muted-foreground, #a1a1aa); }
  .err-txt { color: var(--destructive, #ef4444); }
  .warn-txt { color: var(--warning, #f59e0b); font-weight: 600; }
  .filters { display: flex; gap: 6px; flex-wrap: wrap; }
  .btn {
    background: var(--secondary, #27272a);
    color: var(--foreground, #e5e7eb);
    border: 1px solid var(--border, #3f3f46);
    border-radius: 6px;
    padding: 3px 9px;
    font-size: 11px;
    cursor: pointer;
  }
  .btn.active { background: var(--primary, #3b82f6); color: var(--primary-foreground, #fff); border-color: transparent; }
  .foot { font-size: 11px; color: var(--muted-foreground, #a1a1aa); text-align: right; }
</style>
</head>
<body>
  <div class="grid">
    <div class="kpi">
      <div class="kpi-label">Repos</div>
      <div class="kpi-val">${repos.length}</div>
      <div class="kpi-sub">${owners.map((o) => `${o}: ${repos.filter((r) => r.owner === o).length}`).join(' · ')}</div>
    </div>
    <div class="kpi">
      <div class="kpi-label">Failing CI</div>
      <div class="kpi-val ${failingRepos.length ? 'err-txt' : ''}">${failingRepos.length}</div>
      <div class="kpi-sub">default branch</div>
    </div>
    <div class="kpi">
      <div class="kpi-label">Open PRs</div>
      <div class="kpi-val">${allPrs.length}</div>
      <div class="kpi-sub">${humanPrCount} human · ${botPrCount} bot</div>
    </div>
    <div class="kpi">
      <div class="kpi-label">Security & Issues</div>
      <div class="kpi-val ${totalAlerts ? 'warn-txt' : ''}">${totalAlerts}</div>
      <div class="kpi-sub">${esc(secBreakdown(data.securityTotals))} · ${totalIssues} issues</div>
    </div>
  </div>

  ${
    attentionItems.length
      ? `<div class="section">
          <div class="section-head"><h2>Needs Attention (${attentionItems.length})</h2></div>
          <ul class="att-list">${attentionItems.join('')}</ul>
        </div>`
      : ''
  }

  ${
    allPrs.length
      ? `<div class="section">
          <div class="section-head"><h2>Open Pull Requests (${allPrs.length})</h2></div>
          <div class="table-wrap">
            <table>
              <thead><tr><th>PR</th><th>Status</th><th>Author · Updated</th></tr></thead>
              <tbody>${prRows}</tbody>
            </table>
          </div>
        </div>`
      : ''
  }

  <div class="section">
    <div class="section-head">
      <h2>All Repositories (${repos.length})</h2>
      <div class="filters">
        <button class="btn active" data-filter="all">All</button>
        ${owners.map((o) => `<button class="btn" data-filter="owner:${esc(o)}">${esc(o)}</button>`).join('')}
        <button class="btn" data-filter="attention">Attention</button>
      </div>
    </div>
    <div class="table-wrap">
      <table id="repo-table">
        <thead>
          <tr>
            <th>Repository</th>
            <th>CI</th>
            <th class="num">PRs</th>
            <th class="num">Issues</th>
            <th class="num">Alerts</th>
            <th>Latest Release</th>
            <th>Pushed</th>
          </tr>
        </thead>
        <tbody>${repoRows}</tbody>
      </table>
    </div>
  </div>

  <div class="foot">Snapshot: ${esc(data.fetchedAt.replace('T', ' ').slice(0, 16))} UTC · unarchived, non-fork</div>

  <script>
    const buttons = document.querySelectorAll('.filters .btn');
    const rows = document.querySelectorAll('#repo-table tbody tr');
    buttons.forEach((btn) => {
      btn.addEventListener('click', () => {
        buttons.forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');
        const f = btn.dataset.filter;
        rows.forEach((tr) => {
          const show =
            f === 'all' ||
            (f === 'attention' && tr.dataset.attention === '1') ||
            (f.startsWith('owner:') && tr.dataset.owner === f.slice(6));
          tr.style.display = show ? '' : 'none';
        });
      });
    });
  </script>
</body>
</html>
`;

process.stdout.write(html);
