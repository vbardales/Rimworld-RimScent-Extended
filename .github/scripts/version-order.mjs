import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const VERSION = /^(\d+)\.(\d+)\.(\d+)(?:-(alpha|beta|rc)\.(\d+))?$/;
const STAGES = { alpha: 0, beta: 1, rc: 2 };

function parse(version) {
  const match = VERSION.exec(version);
  if (!match) return null;
  return { core: [Number(match[1]), Number(match[2]), Number(match[3])], stage: match[4] === undefined ? Infinity : STAGES[match[4]], number: match[5] === undefined ? 0 : Number(match[5]) };
}

// Semver precedence for the versions this workflow accepts: 1.0.6-alpha.1 < 1.0.6-beta.1 < 1.0.6-beta.2 < 1.0.6-rc.1 < 1.0.6.
export function compareVersions(a, b) {
  const [x, y] = [parse(a), parse(b)];
  if (!x || !y) throw new Error(`not a version this workflow accepts: ${!x ? a : b}`);
  for (let i = 0; i < 3; i++) if (x.core[i] !== y.core[i]) return x.core[i] < y.core[i] ? -1 : 1;
  if (x.stage !== y.stage) return x.stage < y.stage ? -1 : 1;
  return x.number === y.number ? 0 : x.number < y.number ? -1 : 1;
}

// The semantic-release path forced the next patch, minor or major; this workflow takes the version as an input, so a
// mistyped one (1.0.60 for 1.0.6, or a version below the last release) would tag and publish out of order. A version
// must be above every existing tag. Tags that are not versions (a release-candidate label, a date) are ignored.
export function checkVersionOrder(version, tags) {
  const highest = tags.map((tag) => tag.replace(/^v/, '')).filter((tag) => VERSION.test(tag)).sort(compareVersions).at(-1);
  if (highest !== undefined && compareVersions(version, highest) <= 0) {
    throw new Error(`version ${version} is not above the highest existing tag v${highest}: publish a higher version (a version can only go up)`);
  }
  return highest ?? null;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const version = process.argv[2];
  if (!version) { console.error('usage: node version-order.mjs <version>  (run in the repository)'); process.exit(2); }
  try {
    const tags = execFileSync('git', ['tag', '--list', 'v*'], { encoding: 'utf8' }).split('\n').map((line) => line.trim()).filter(Boolean);
    const highest = checkVersionOrder(version, tags);
    console.log(highest === null ? `version ${version}: no earlier version tag.` : `version ${version} is above the highest existing tag v${highest}.`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
