import { writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { aboutState } from './about-description.mjs';
import { loadConfig } from './config.mjs';

// node .github/scripts/sync-about-description.mjs [--write]   (from the root of the repository)
// Without --write it only says whether the <description> of Mod/About/About.xml is the plain text of the
// description source, and exits 1 when it is not. With --write it rewrites that one element and nothing else.
const write = process.argv.includes('--write');
const root = process.cwd();
const config = await loadConfig(root);
const { expected, current, next, path } = await aboutState(root, config);
if (current === expected) {
  console.log(`${path}: the description is already the plain text of ${config.description.file}.`);
} else if (write) {
  await writeFile(join(root, path), next);
  console.log(`${path}: description rewritten from ${config.description.file}. Read the diff, then commit.`);
} else {
  console.log(`${path}: the description differs from the plain text of ${config.description.file}. Run with --write.`);
  process.exit(1);
}
