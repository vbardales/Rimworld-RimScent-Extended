import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkVersionOrder, compareVersions } from '../scripts/version-order.mjs';

test('orders versions like semver, pre-releases below their release', () => {
  const ascending = ['1.0.0-alpha.1', '1.0.0-alpha.2', '1.0.0-beta.1', '1.0.0-beta.10', '1.0.0-rc.1', '1.0.0', '1.0.1-beta.1', '1.0.1', '1.1.0', '2.0.0'];
  for (let i = 0; i < ascending.length; i++) {
    for (let j = 0; j < ascending.length; j++) assert.equal(compareVersions(ascending[i], ascending[j]), Math.sign(i - j), `${ascending[i]} vs ${ascending[j]}`);
  }
  assert.equal(compareVersions('1.0.10', '1.0.9'), 1, 'numbers, not text');
});

test('a version above every tag passes, and the highest tag is reported', () => {
  assert.equal(checkVersionOrder('1.0.6', ['v1.0.4', 'v1.0.5']), '1.0.5');
  assert.equal(checkVersionOrder('1.0.6-beta.1', ['v1.0.5']), '1.0.5');
  assert.equal(checkVersionOrder('1.0.6', ['v1.0.6-beta.2', 'v1.0.5']), '1.0.6-beta.2', 'the release follows its betas');
  assert.equal(checkVersionOrder('1.0.0', []), null, 'no tag yet');
});

test('a version equal to or below a tag is refused', () => {
  assert.throws(() => checkVersionOrder('1.0.5', ['v1.0.5']), /not above the highest existing tag v1\.0\.5/);
  assert.throws(() => checkVersionOrder('1.0.4', ['v1.0.5']), /not above/);
  assert.throws(() => checkVersionOrder('1.0.6-beta.1', ['v1.0.6']), /not above the highest existing tag v1\.0\.6/, 'a beta after the release');
  assert.throws(() => checkVersionOrder('1.0.6-beta.1', ['v1.0.6-beta.2']), /not above/);
});

test('tags that are not versions are ignored', () => {
  assert.equal(checkVersionOrder('1.0.6', ['v1.0.5', 'vnext', 'v2026-09-25', 'v1.0.9-dev.1', 'backup']), '1.0.5');
});
