// Line-level diff (longest common subsequence) between two texts, for the dry-run to show what a
// description update would change. Lines are compared without trailing spaces and CR.
const lines = (text) => text.replace(/\r\n/g, '\n').split('\n').map((line) => line.replace(/\s+$/, ''));

export function lineDiff(before, after) {
  const a = lines(before);
  const b = lines(after);
  const table = Array.from({ length: a.length + 1 }, () => new Array(b.length + 1).fill(0));
  for (let i = a.length - 1; i >= 0; i--) {
    for (let j = b.length - 1; j >= 0; j--) table[i][j] = a[i] === b[j] ? table[i + 1][j + 1] + 1 : Math.max(table[i + 1][j], table[i][j + 1]);
  }
  const out = [];
  let i = 0;
  let j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] === b[j]) { out.push({ kind: ' ', text: a[i] }); i++; j++; }
    else if (table[i + 1][j] >= table[i][j + 1]) { out.push({ kind: '-', text: a[i++] }); }
    else { out.push({ kind: '+', text: b[j++] }); }
  }
  while (i < a.length) out.push({ kind: '-', text: a[i++] });
  while (j < b.length) out.push({ kind: '+', text: b[j++] });
  return out;
}

// Only the changed lines, each with one line of context, as text.
export function formatDiff(diff, context = 1) {
  const keep = diff.map((entry, index) => entry.kind !== ' ' || diff.slice(Math.max(0, index - context), index + context + 1).some((near) => near.kind !== ' '));
  const rows = [];
  let skipped = false;
  diff.forEach((entry, index) => {
    if (!keep[index]) { skipped = true; return; }
    if (skipped) { rows.push('  ...'); skipped = false; }
    rows.push(`${entry.kind} ${entry.text}`);
  });
  if (skipped) rows.push('  ...');
  return rows.join('\n');
}

export const isIdentical = (diff) => diff.every((entry) => entry.kind === ' ');
