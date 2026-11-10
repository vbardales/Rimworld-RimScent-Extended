import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LIMITS, checkBytes } from '../scripts/limits.mjs';

test('returns the size in bytes when it is within the limit, the limit itself included', () => {
  assert.equal(checkBytes('the title', 'a'.repeat(LIMITS.title), LIMITS.title), LIMITS.title);
});

test('counts UTF-8 bytes, not characters', () => {
  const text = 'é'.repeat(4001);
  assert.equal(text.length, 4001);
  assert.throws(() => checkBytes('the description', text, LIMITS.description), /the description is 8002 bytes, over the 8000 bytes/);
  assert.equal(checkBytes('the description', 'é'.repeat(4000), LIMITS.description), 8000);
});

test('an emoji costs four bytes', () => {
  assert.throws(() => checkBytes('the title', '😀'.repeat(33), LIMITS.title), /is 132 bytes/);
});
