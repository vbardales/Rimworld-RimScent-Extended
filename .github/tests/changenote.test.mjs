import { test } from 'node:test';
import assert from 'node:assert/strict';
import { changenoteFor } from '../scripts/changenote.mjs';

const publication = [
  '# Publication',
  '',
  '### 1.0.2 — pending',
  '',
  'Some text.',
  '',
  '```',
  '[h3]1.0.2[/h3]',
  '',
  '[list]',
  '[*]one',
  '[/list]',
  '```',
  '',
  '### 1.0.0 - 2026-09-21',
  '',
  '```',
  '[h3]1.0.0[/h3]',
  '```',
].join('\n');

test('returns the fenced block under the matching version heading', () => {
  assert.equal(changenoteFor(publication, '1.0.2'), '[h3]1.0.2[/h3]\n\n[list]\n[*]one\n[/list]');
});

test('a version whose heading is followed by a date is found too', () => {
  assert.equal(changenoteFor(publication, '1.0.0'), '[h3]1.0.0[/h3]');
});

test('handles CRLF line endings', () => {
  assert.equal(changenoteFor(publication.replaceAll('\n', '\r\n'), '1.0.0'), '[h3]1.0.0[/h3]');
});

test('a missing version fails', () => {
  assert.throws(() => changenoteFor(publication, '9.9.9'), /no "### 9\.9\.9" section/);
});

test('a version is not matched as a prefix of a longer one', () => {
  assert.throws(() => changenoteFor('### 1.0.20\n```\nx\n```', '1.0.2'), /no "### 1\.0\.2" section/);
});

test('does not borrow the fenced block of the next section', () => {
  assert.throws(() => changenoteFor('### 1.0.2\nno fence\n### 1.0.1\n```\nx\n```', '1.0.2'), /no fenced change note/);
});

test('an unclosed or empty block fails', () => {
  assert.throws(() => changenoteFor('### 1.0.2\n```\nx', '1.0.2'), /not closed/);
  assert.throws(() => changenoteFor('### 1.0.2\n```\n\n```', '1.0.2'), /is empty/);
});

test('a note whose first line does not carry the version is refused, whatever else it says', () => {
  const note = (first) => `### 1.0.5\n\`\`\`\n${first}\n\n[h3]Fixed[/h3]\n\`\`\``;
  const stop = /must begin with a line that carries the version/;
  assert.throws(() => changenoteFor(note('[h3]Fixed[/h3]'), '1.0.5'), stop, 'sections only, the Architect Studio 1.0.5 case');
  assert.throws(() => changenoteFor(note('First release.'), '1.0.5'), stop, 'plain text');
  assert.throws(() => changenoteFor(note('[b]1.0.4[/b]'), '1.0.5'), stop, 'another version');
  assert.throws(() => changenoteFor(note('[b]1.0.55[/b]'), '1.0.5'), stop, '1.0.5 is not inside 1.0.55');
  assert.throws(() => changenoteFor(note('[b]1.0.5'), '1.0.5'), stop, 'an unclosed tag');
  assert.throws(() => changenoteFor(note('[b]1.0.4-1.0.5[/b]'), '1.0.5'), stop, 'a dash right before the version');
  for (const ok of ['[b]1.0.5[/b]', '[h3]1.0.5[/h3]', '[h3]1.0.5 — first release[/h3]', '[h2][url=https://github.com/o/r/compare/v1.0.4...v1.0.5]1.0.5[/url] (2026-09-25)[/h2]']) {
    assert.ok(changenoteFor(note(ok), '1.0.5').startsWith(ok), ok);
  }
});

test('a pre-release version has its own note, and a stable version is not satisfied by it', () => {
  const note = (heading, first) => `### ${heading}\n\`\`\`\n${first}\n\`\`\``;
  assert.equal(changenoteFor(note('1.0.6-beta.1', '[b]1.0.6-beta.1[/b]'), '1.0.6-beta.1'), '[b]1.0.6-beta.1[/b]');
  assert.throws(() => changenoteFor(note('1.0.6-beta.1', '[b]1.0.6-beta.1[/b]'), '1.0.6'), /no "### 1\.0\.6" section/, 'the beta heading is not the stable one');
  assert.throws(() => changenoteFor(note('1.0.6', '[b]1.0.6-beta.1[/b]'), '1.0.6'), /must begin with a line that carries the version/, 'a stable note may not carry the beta name');
  assert.throws(() => changenoteFor(note('1.0.6-beta.1', '[b]1.0.6-beta.10[/b]'), '1.0.6-beta.1'), /must begin with a line that carries the version/, 'beta.1 is not inside beta.10');
});

test('a version with regular-expression characters is escaped, not interpreted', () => {
  const note = (heading, first) => `### ${heading}\n\`\`\`\n${first}\n\`\`\``;
  assert.equal(changenoteFor(note('1.0.0+build.5', '[b]1.0.0+build.5[/b]'), '1.0.0+build.5'), '[b]1.0.0+build.5[/b]');
  assert.throws(() => changenoteFor(note('1.0.0', '[b]1.0.0[/b]'), '1.0.0+build.5'), /no "### 1\.0\.0\+build\.5" section/, '+ is not a repetition of 0');
  assert.throws(() => changenoteFor(note('1x0x0', '[b]1x0x0[/b]'), '1.0.0'), /no "### 1\.0\.0" section/, 'a dot is not any character');
});
