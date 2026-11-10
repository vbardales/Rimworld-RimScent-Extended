const decode = (text) => text.replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&apos;', "'").replaceAll('&amp;', '&');

// A commented-out <name> or <supportedVersions> must not be read as the real one.
export const stripXmlComments = (xml) => xml.replace(/<!--[\s\S]*?-->/g, '');

// The Workshop title is the <name> of About.xml, the same field the in-game upload reads.
export function aboutName(xml) {
  const match = stripXmlComments(xml).match(/<name>([\s\S]*?)<\/name>/);
  if (!match || !match[1].trim()) throw new Error('About.xml has no <name>');
  return decode(match[1].trim());
}

// RimWorld players filter by version tag: one tag per <supportedVersions> entry ("1.6.4633" gives "1.6").
export function aboutVersions(xml) {
  const block = stripXmlComments(xml).match(/<supportedVersions>([\s\S]*?)<\/supportedVersions>/);
  const versions = [...(block?.[1] ?? '').matchAll(/<li>\s*(\d+)\.(\d+)[^<]*<\/li>/g)].map((entry) => `${entry[1]}.${entry[2]}`);
  if (versions.length === 0) throw new Error('About.xml has no <supportedVersions> entry');
  return [...new Set(versions)];
}

// The tags key of workshop.vdf replaces the whole tag set, so the complete list is built here.
export const tagsFor = (xml) => ['Mod', ...aboutVersions(xml)];
