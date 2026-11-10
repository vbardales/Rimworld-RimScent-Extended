import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { MAX_PREVIEW_BYTES, checkPreview } from '../scripts/preview.mjs';

const png = (size) => Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), Buffer.alloc(size - 8, 1)]);
async function file(buffer) {
  const path = join(await mkdtemp(join(tmpdir(), 'preview-')), 'Preview.png');
  await writeFile(path, buffer);
  return path;
}

test('returns the size and the SHA-256 of a PNG under 1 MiB', async () => {
  const buffer = png(1000);
  assert.deepEqual(await checkPreview(await file(buffer)), { bytes: 1000, sha256: createHash('sha256').update(buffer).digest('hex') });
});

test('rejects a file that is not a PNG, including an empty one', async () => {
  await assert.rejects(checkPreview(await file(Buffer.from('GIF89a and more'))), /not a PNG/);
  await assert.rejects(checkPreview(await file(Buffer.alloc(0))), /not a PNG/);
});

test('the limit is strict: 1 MiB minus one byte passes, 1 MiB fails', async () => {
  assert.equal((await checkPreview(await file(png(MAX_PREVIEW_BYTES - 1)))).bytes, MAX_PREVIEW_BYTES - 1);
  await assert.rejects(checkPreview(await file(png(MAX_PREVIEW_BYTES))), /under 1 MiB/);
});
