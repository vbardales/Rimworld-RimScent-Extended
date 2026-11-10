import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { relocatingExec } from '../scripts/relocate-vdf.mjs';

test('moves workshop.vdf out of the content folder before steamcmd reads it', async () => {
  const stage = await mkdtemp(join(tmpdir(), 'stage-'));
  await writeFile(join(stage, 'Real.dll'), 'x');
  await writeFile(join(stage, 'workshop.vdf'), '"workshopitem" {}');
  let received;
  const fake = async (file, args) => {
    const vdf = args.find((arg) => arg.endsWith('workshop.vdf'));
    received = { file, args, content: await readFile(vdf, 'utf8'), vdf };
    return { stdout: '', stderr: '' };
  };
  await relocatingExec(fake)('steamcmd', ['+login', 'u', '+workshop_build_item', join(stage, 'workshop.vdf'), '+quit'], {});
  assert.equal(received.file, 'steamcmd');
  assert.notEqual(received.vdf, join(stage, 'workshop.vdf'));
  assert.equal(received.content, '"workshopitem" {}');
  assert.deepEqual(await readdir(stage), ['Real.dll']);
  assert.deepEqual(received.args.filter((arg) => !arg.endsWith('workshop.vdf')), ['+login', 'u', '+workshop_build_item', '+quit']);
});

test('passes arguments through untouched when there is no workshop.vdf', async () => {
  let seen;
  await relocatingExec(async (file, args) => { seen = args; return {}; })('x', ['a', 'b'], {});
  assert.deepEqual(seen, ['a', 'b']);
});

test('returns what the wrapped exec returns and propagates its errors', async () => {
  const result = await relocatingExec(async () => ({ stdout: 'ok' }))('x', ['a'], {});
  assert.deepEqual(result, { stdout: 'ok' });
  await assert.rejects(relocatingExec(async () => { throw new Error('steamcmd failed'); })('x', ['a'], {}), /steamcmd failed/);
});
