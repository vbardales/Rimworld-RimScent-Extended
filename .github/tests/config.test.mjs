import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { checkMod, parseConfig } from '../scripts/config.mjs';

const valid = { workshopId: '123', packageId: 'nelim.test', releaseTitle: 'Test {version}' };

test('accepts a minimal configuration and fills the defaults', () => {
  assert.deepEqual(parseConfig(JSON.stringify(valid)), { ...valid, templateStamp: null, requirePaths: [], forbidPaths: [], previewFile: 'About/Preview.png', galleryDir: null, description: null, aboutFromDescription: false, build: null });
});

test('build.project must be a .csproj path inside the repository', () => {
  assert.deepEqual(parseConfig(JSON.stringify({ ...valid, build: { project: 'Source/X.csproj' } })).build, { project: 'Source/X.csproj' });
  for (const build of [{ project: 'Source/X.sln' }, { project: '../X.csproj' }, { project: '/abs/X.csproj' }, { project: 3 }, {}, 'Source/X.csproj']) {
    assert.throws(() => parseConfig(JSON.stringify({ ...valid, build })), /build\.project must be a \.csproj path/, JSON.stringify(build));
  }
});

test('keeps the gallery folder, and rejects one that would leave the repository', () => {
  assert.equal(parseConfig(JSON.stringify({ ...valid, galleryDir: 'Art/Screenshots' })).galleryDir, 'Art/Screenshots');
  for (const galleryDir of ['../x', '/abs', '', 3, ['a']]) assert.throws(() => parseConfig(JSON.stringify({ ...valid, galleryDir })), /galleryDir/, JSON.stringify(galleryDir));
});

test('keeps required and forbidden paths, the preview file and the description source', () => {
  const c = parseConfig(JSON.stringify({ ...valid, requirePaths: ['Defs'], forbidPaths: ['Assemblies'], previewFile: 'About/Other.png', description: { file: 'PUBLICATION.md', heading: '^## 1' } }));
  assert.deepEqual([c.requirePaths, c.forbidPaths, c.previewFile, c.description], [['Defs'], ['Assemblies'], 'About/Other.png', { file: 'PUBLICATION.md', heading: '^## 1' }]);
});

test('rejects what would send the wrong thing or escape the repository', () => {
  const bad = [
    { ...valid, workshopId: '0' }, { ...valid, workshopId: 123 }, { ...valid, packageId: 'has space' }, { ...valid, releaseTitle: 'no placeholder' },
    { ...valid, requirePaths: ['../outside'] }, { ...valid, forbidPaths: ['/absolute'] }, { ...valid, previewFile: '../x.png' },
    { ...valid, description: { file: '../x.md' } }, { ...valid, description: { file: 'A.md', heading: '(' } },
  ];
  for (const config of bad) assert.throws(() => parseConfig(JSON.stringify(config)), /publish\.config\.json/, JSON.stringify(config));
  assert.throws(() => parseConfig('{not json'), /not valid JSON/);
  for (const text of ['null', '[]', '"text"', '3']) assert.throws(() => parseConfig(text), /must contain a JSON object/, text);
});

test('a description is BBCode by default, or Markdown to convert (a whole file, or the block under a heading)', () => {
  assert.equal(parseConfig(JSON.stringify({ ...valid, description: { file: 'README.template.md', format: 'markdown' } })).description.format, 'markdown');
  assert.equal(parseConfig(JSON.stringify({ ...valid, description: { file: 'P.md', format: 'bbcode', heading: '^## 1' } })).description.format, 'bbcode');
  assert.equal(parseConfig(JSON.stringify({ ...valid, description: { file: 'PUBLICATION.md', format: 'markdown', heading: '^## Steam description$' } })).description.heading, '^## Steam description$');
  assert.throws(() => parseConfig(JSON.stringify({ ...valid, description: { file: 'R.md', format: 'html' } })), /description.format/);
  assert.throws(() => parseConfig(JSON.stringify({ ...valid, description: { file: 'R.md', format: 'markdown', heading: '(' } })), /not a valid regular expression/);
});

test('the template stamp is kept when it is a string', () => {
  assert.equal(parseConfig(JSON.stringify({ ...valid, templateStamp: 'abc123' })).templateStamp, 'abc123');
});

async function mod({ id = '123', pkg = 'nelim.test', files = [] } = {}) {
  const dir = await mkdtemp(join(tmpdir(), 'mod-'));
  await mkdir(join(dir, 'About'), { recursive: true });
  await writeFile(join(dir, 'About', 'PublishedFileId.txt'), id);
  await writeFile(join(dir, 'About', 'About.xml'), `<ModMetaData><packageId>${pkg}</packageId></ModMetaData>`);
  for (const file of files) await mkdir(join(dir, file), { recursive: true });
  return dir;
}
const config = (extra = {}) => parseConfig(JSON.stringify({ ...valid, ...extra }));

test('checkMod passes when the identity matches and the paths are as configured', async () => {
  await checkMod(await mod({ id: '123\n', files: ['Defs'] }), config({ requirePaths: ['Defs'], forbidPaths: ['Assemblies'] }));
});

test('checkMod stops on another item, another package, a missing or a forbidden path', async () => {
  await assert.rejects(checkMod(await mod({ id: '999' }), config()), /says "999" but this run targets 123/);
  await assert.rejects(checkMod(await mod({ pkg: 'someone.else' }), config()), /packageId nelim\.test/);
  const commented = await mod({ pkg: 'someone.else' });
  await writeFile(join(commented, 'About', 'About.xml'), '<ModMetaData><!-- <packageId>nelim.test</packageId> --><packageId>someone.else</packageId></ModMetaData>');
  await assert.rejects(checkMod(commented, config()), /packageId nelim\.test/);
  await assert.rejects(checkMod(await mod(), config({ requirePaths: ['Defs'] })), /Mod\/Defs is required and missing/);
  await assert.rejects(checkMod(await mod({ files: ['Assemblies'] }), config({ forbidPaths: ['Assemblies'] })), /Mod\/Assemblies must not exist/);
});

test('aboutFromDescription needs a Markdown description source and a boolean', () => {
  const markdown = { file: 'PUBLICATION.md', format: 'markdown', heading: '^## Steam description$' };
  assert.equal(parseConfig(JSON.stringify({ ...valid, description: markdown, aboutFromDescription: true })).aboutFromDescription, true);
  assert.equal(parseConfig(JSON.stringify({ ...valid, description: markdown })).aboutFromDescription, false);
  assert.throws(() => parseConfig(JSON.stringify({ ...valid, description: { file: 'PUBLICATION.md' }, aboutFromDescription: true })), /needs a Markdown description source/);
  assert.throws(() => parseConfig(JSON.stringify({ ...valid, aboutFromDescription: true })), /needs a Markdown description source/);
  assert.throws(() => parseConfig(JSON.stringify({ ...valid, description: markdown, aboutFromDescription: 'yes' })), /must be true or false/);
});
