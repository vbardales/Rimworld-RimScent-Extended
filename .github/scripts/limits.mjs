// Steam counts these in bytes of UTF-8 (the k_cchPublishedDocument*Max constants of Steamworks), so
// accents, dashes and emoji cost more than one unit each.
export const LIMITS = { description: 8000, changenote: 8000, title: 128 };

export function checkBytes(label, text, max) {
  const bytes = Buffer.byteLength(text, 'utf8');
  if (bytes > max) throw new Error(`${label} is ${bytes} bytes, over the ${max} bytes Steam accepts`);
  return bytes;
}
