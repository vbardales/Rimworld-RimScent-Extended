import { test } from 'node:test';
import assert from 'node:assert/strict';
import { formatDiff, isIdentical, lineDiff } from '../scripts/line-diff.mjs';

test('identical texts, ignoring line endings and trailing spaces, have no change', () => {
  assert.ok(isIdentical(lineDiff('a\r\nb  \nc', 'a\nb\nc')));
});

test('reports removed and added lines and keeps the common ones', () => {
  const diff = lineDiff('one\ntwo\nthree', 'one\n2\nthree');
  assert.deepEqual(diff.filter((entry) => entry.kind !== ' ').map((entry) => `${entry.kind}${entry.text}`), ['-two', '+2']);
  assert.equal(diff.filter((entry) => entry.kind === ' ').length, 2);
});

test('handles an empty side', () => {
  assert.deepEqual(lineDiff('', 'x').filter((entry) => entry.kind === '+').map((entry) => entry.text), ['x']);
  assert.ok(lineDiff('x', '').some((entry) => entry.kind === '-' && entry.text === 'x'));
});

test('formats only the changed lines with one line of context and marks the gaps', () => {
  const before = Array.from({ length: 10 }, (_, i) => `line ${i}`).join('\n');
  const after = before.replace('line 5', 'changed');
  assert.equal(formatDiff(lineDiff(before, after)), '  ...\n  line 4\n- line 5\n+ changed\n  line 6\n  ...');
});
