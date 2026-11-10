import { readFile, stat } from 'node:fs/promises';
import { join } from 'node:path';
import { stripXmlComments } from './about.mjs';

export const CONFIG_PATH = '.github/publish.config.json';

const isPathList = (value) => Array.isArray(value) && value.every((entry) => typeof entry === 'string' && entry && !entry.startsWith('/') && !entry.split('/').includes('..'));

// The mod-specific values of the publish workflow live in one JSON file of the mod repository, so
// the workflow and the scripts are the same for every mod.
export function parseConfig(text) {
  let raw;
  try { raw = JSON.parse(text); } catch (error) { throw new Error(`${CONFIG_PATH} is not valid JSON: ${error.message}`); }
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) throw new Error(`${CONFIG_PATH} must contain a JSON object`);
  if (typeof raw.workshopId !== 'string' || !/^[1-9][0-9]*$/.test(raw.workshopId)) throw new Error(`${CONFIG_PATH}: workshopId must be a positive number in a string`);
  if (!/^[A-Za-z0-9_.-]+$/.test(raw.packageId ?? '')) throw new Error(`${CONFIG_PATH}: packageId is missing or malformed`);
  if (typeof raw.releaseTitle !== 'string' || !raw.releaseTitle.includes('{version}')) throw new Error(`${CONFIG_PATH}: releaseTitle must contain {version}`);
  const requirePaths = raw.requirePaths ?? [];
  const forbidPaths = raw.forbidPaths ?? [];
  if (!isPathList(requirePaths) || !isPathList(forbidPaths)) throw new Error(`${CONFIG_PATH}: requirePaths and forbidPaths must be lists of paths relative to Mod/`);
  const previewFile = raw.previewFile ?? 'About/Preview.png';
  if (!isPathList([previewFile])) throw new Error(`${CONFIG_PATH}: previewFile must be a path relative to Mod/`);
  const galleryDir = raw.galleryDir ?? null;
  if (galleryDir !== null && (typeof galleryDir !== 'string' || !isPathList([galleryDir]))) throw new Error(`${CONFIG_PATH}: galleryDir must be a folder path relative to the repository`);
  const description = raw.description ?? null;
  if (description !== null) {
    if (typeof description.file !== 'string' || !isPathList([description.file])) throw new Error(`${CONFIG_PATH}: description.file must be a path relative to the repository`);
    if (description.format !== undefined && !['bbcode', 'markdown'].includes(description.format)) throw new Error(`${CONFIG_PATH}: description.format must be "bbcode" or "markdown"`);
    if (description.heading !== undefined) {
      try { new RegExp(description.heading); } catch { throw new Error(`${CONFIG_PATH}: description.heading is not a valid regular expression`); }
    }
  }
  if (raw.aboutFromDescription !== undefined && typeof raw.aboutFromDescription !== 'boolean') throw new Error(`${CONFIG_PATH}: aboutFromDescription must be true or false`);
  const aboutFromDescription = raw.aboutFromDescription === true;
  if (aboutFromDescription && description?.format !== 'markdown') throw new Error(`${CONFIG_PATH}: aboutFromDescription needs a Markdown description source (description.format "markdown")`);
  const build = raw.build ?? null;
  if (build !== null && (typeof build !== 'object' || typeof build.project !== 'string' || !build.project.endsWith('.csproj') || !isPathList([build.project]))) {
    throw new Error(`${CONFIG_PATH}: build.project must be a .csproj path relative to the repository`);
  }
  return { templateStamp: typeof raw.templateStamp === 'string' ? raw.templateStamp : null, workshopId: raw.workshopId, packageId: raw.packageId, releaseTitle: raw.releaseTitle, requirePaths, forbidPaths, previewFile, galleryDir, description, aboutFromDescription, build };
}

export async function loadConfig(commitDir) {
  let text;
  try { text = await readFile(join(commitDir, CONFIG_PATH), 'utf8'); } catch { throw new Error(`${CONFIG_PATH} is missing from the commit being published`); }
  return parseConfig(text);
}

// Identity and payload checks against the folder that would be uploaded.
export async function checkMod(modPath, config) {
  const recorded = (await readFile(join(modPath, 'About', 'PublishedFileId.txt'), 'utf8')).trim();
  if (recorded !== config.workshopId) throw new Error(`Mod/About/PublishedFileId.txt says "${recorded}" but this run targets ${config.workshopId}`);
  const about = stripXmlComments(await readFile(join(modPath, 'About', 'About.xml'), 'utf8'));
  if (!about.includes(`<packageId>${config.packageId}</packageId>`)) throw new Error(`Mod/About/About.xml does not declare packageId ${config.packageId}`);
  const exists = async (path) => stat(join(modPath, path)).then(() => true, () => false);
  for (const path of config.requirePaths) if (!(await exists(path))) throw new Error(`Mod/${path} is required and missing`);
  for (const path of config.forbidPaths) if (await exists(path)) throw new Error(`Mod/${path} must not exist`);
}
