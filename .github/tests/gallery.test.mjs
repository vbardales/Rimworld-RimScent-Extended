import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdir, mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { formatGallery, listGallery } from '../scripts/gallery.mjs';

async function folder(files) {
  const dir = await mkdtemp(join(tmpdir(), 'gallery-'));
  for (const [name, size] of Object.entries(files)) await writeFile(join(dir, name), Buffer.alloc(size, 1));
  return dir;
}

test('lists the images of the folder by name, with their size, and nothing else', async () => {
  const dir = await folder({ '02-b.png': 2000, '01-a.PNG': 10, '03-c.gif': 5, 'photo.jpeg': 7, 'notes.md': 4, 'README.txt': 4 });
  await mkdir(join(dir, 'sub.png'));
  assert.deepEqual(await listGallery(dir), [{ name: '01-a.PNG', bytes: 10 }, { name: '02-b.png', bytes: 2000 }, { name: '03-c.gif', bytes: 5 }, { name: 'photo.jpeg', bytes: 7 }]);
});

test('says the gallery is a manual step and prints every file', async () => {
  const text = formatGallery(await listGallery(await folder({ 'a.png': 1234567, 'b.png': 9 })), 'Screenshots');
  assert.match(text, /gallery \(2 files in Screenshots, uploaded by hand on the Steam page; the workflow does not send it\):/);
  assert.match(text, /a\.png {2}1,234,567 bytes/);
  assert.match(text, /b\.png {2}9 bytes/);
});

test('a folder with no image says so', async () => {
  assert.equal(formatGallery(await listGallery(await folder({ 'notes.md': 1 })), 'Screenshots'), 'gallery: no image in Screenshots');
});

test('a folder that does not exist rejects, so the caller can report it', async () => {
  await assert.rejects(listGallery(join(tmpdir(), 'no-such-gallery-folder')), /ENOENT/);
});
