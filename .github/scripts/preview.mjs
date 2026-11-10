import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';

export const MAX_PREVIEW_BYTES = 1024 * 1024;
const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

export const digest = (buffer) => ({ bytes: buffer.length, sha256: createHash('sha256').update(buffer).digest('hex') });

// The header image Steam would receive: it must be a PNG strictly under 1 MiB.
export async function checkPreview(file) {
  const buffer = await readFile(file);
  if (buffer.length < PNG_SIGNATURE.length || !buffer.subarray(0, PNG_SIGNATURE.length).equals(PNG_SIGNATURE)) throw new Error(`${file} is not a PNG file`);
  if (buffer.length >= MAX_PREVIEW_BYTES) throw new Error(`${file} is ${buffer.length} bytes: the preview must stay under 1 MiB (${MAX_PREVIEW_BYTES})`);
  return digest(buffer);
}
