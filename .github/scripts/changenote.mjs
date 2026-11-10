// The text sent to Steam (change note, description) is the fenced block under a heading of a
// markdown file, so there is no second copy that could drift from it.
export function fencedBlockUnder(text, headingRegex, { label, what }) {
  const lines = text.split(/\r?\n/);
  const start = lines.findIndex((line) => headingRegex.test(line));
  if (start === -1) throw new Error(`no ${label} section found`);
  const open = lines.findIndex((line, i) => i > start && /^```/.test(line));
  const next = lines.findIndex((line, i) => i > start && /^#{1,6} /.test(line));
  if (open === -1 || (next !== -1 && open > next)) throw new Error(`the ${label} section has no fenced ${what}`);
  const close = lines.findIndex((line, i) => i > open && /^```\s*$/.test(line));
  if (close === -1) throw new Error(`the ${what} of ${label} is not closed`);
  const block = lines.slice(open + 1, close).join('\n').trim();
  if (!block) throw new Error(`the ${what} of ${label} is empty`);
  return block;
}

// A note sent as written has only the version heading it carries: Steam shows an entry whose first line has no
// version as an entry with no version at all, and only the owner can correct a published note, by hand (Architect
// Studio 1.0.5, 2026-09-25). So the first line must be a BBCode line ([b] or [h1] to [h3]) that carries the version.
// Every regular-expression metacharacter of a version is escaped, not only the dot: the workflow only lets x.y.z and
// x.y.z-beta.N through, but this function is exported and must not depend on that.
const escapeRegExp = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, (character) => `\\${character}`);

export function checkVersionHeading(note, version) {
  const first = note.split('\n', 1)[0].trim();
  const escaped = escapeRegExp(version);
  if (!new RegExp(`^\\[(b|h[1-3])\\].*(?<![\\d.-])${escaped}(?![\\d.]|-[0-9A-Za-z]).*\\[/(b|h[1-3])\\]$`).test(first)) {
    throw new Error(`the change note of ${version} must begin with a line that carries the version, like [b]${version}[/b] or [h3]${version}[/h3]: Steam shows the entry with no version otherwise. It begins with: ${first.slice(0, 80)}`);
  }
  return note;
}

export function changenoteFor(publication, version) {
  const heading = new RegExp(`^### +${escapeRegExp(version)}(\\s|$)`);
  return checkVersionHeading(fencedBlockUnder(publication, heading, { label: `"### ${version}"`, what: 'change note' }), version);
}
