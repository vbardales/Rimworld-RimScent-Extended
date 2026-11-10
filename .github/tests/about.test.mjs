import { test } from 'node:test';
import assert from 'node:assert/strict';
import { aboutName, aboutVersions, tagsFor } from '../scripts/about.mjs';

const xml = (versions = ['1.6'], name = 'Adaptive Storage &amp; Co') => `<ModMetaData>
  <name>${name}</name>
  <packageId>nelim.test</packageId>
  <supportedVersions>${versions.map((v) => `<li>${v}</li>`).join('')}</supportedVersions>
</ModMetaData>`;

test('the title is the <name> with XML entities decoded', () => {
  assert.equal(aboutName(xml()), 'Adaptive Storage & Co');
});

test('a missing or empty <name> fails', () => {
  assert.throws(() => aboutName('<ModMetaData></ModMetaData>'), /no <name>/);
  assert.throws(() => aboutName('<name>  </name>'), /no <name>/);
});

test('one version tag per supported version, without the patch number and without duplicates', () => {
  assert.deepEqual(aboutVersions(xml(['1.6', '1.7', '1.6.4633'])), ['1.6', '1.7']);
});

test('commented-out entries are ignored', () => {
  const commented = '<!-- <name>Old</name> <supportedVersions><li>1.4</li></supportedVersions> -->\n' + xml(['1.6'], 'Real');
  assert.equal(aboutName(commented), 'Real');
  assert.deepEqual(aboutVersions(commented), ['1.6']);
  assert.throws(() => aboutName('<!-- <name>Old</name> -->'), /no <name>/);
});

test('the full tag list starts with Mod', () => {
  assert.deepEqual(tagsFor(xml(['1.6'])), ['Mod', '1.6']);
  assert.deepEqual(tagsFor(xml(['1.6', '1.7'])), ['Mod', '1.6', '1.7']);
});

test('no supported version fails instead of sending a tag set without any', () => {
  assert.throws(() => tagsFor('<name>X</name><supportedVersions></supportedVersions>'), /no <supportedVersions> entry/);
  assert.throws(() => tagsFor('<name>X</name>'), /no <supportedVersions> entry/);
});
