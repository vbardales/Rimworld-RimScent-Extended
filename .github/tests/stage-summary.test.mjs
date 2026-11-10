import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { formatSummary, topLevelSummary } from '../scripts/stage-summary.mjs';

async function tree() {
  const root = await mkdtemp(join(tmpdir(), 'stage-'));
  await mkdir(join(root, 'About'));
  await mkdir(join(root, '1.6', 'Assemblies'), { recursive: true });
  await writeFile(join(root, 'About', 'About.xml'), 'aaaa');
  await writeFile(join(root, 'About', 'Preview.png'), 'bbbbbb');
  await writeFile(join(root, '1.6', 'Assemblies', 'X.dll'), 'cc');
  await writeFile(join(root, 'LoadFolders.xml'), 'd');
  return root;
}

test('lists each top-level entry with its recursive file count and size, sorted by name', async () => {
  assert.deepEqual(await topLevelSummary(await tree()), [
    { name: '1.6/', files: 1, bytes: 2 },
    { name: 'About/', files: 2, bytes: 10 },
    { name: 'LoadFolders.xml', files: 1, bytes: 1 },
  ]);
});

test('a folder that is missing from the staged content is visible by its absence', async () => {
  const names = (await topLevelSummary(await tree())).map((row) => row.name);
  assert.ok(!names.includes('Languages/'));
});

test('formats one line per entry', async () => {
  const text = formatSummary(await topLevelSummary(await tree()));
  assert.equal(text.split('\n').length, 3);
  assert.match(text, /About\/\s+2 files/);
  assert.match(text, /LoadFolders\.xml\s+1 file /);
});
