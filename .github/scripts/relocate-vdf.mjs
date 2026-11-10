import { execFile } from 'node:child_process';
import { copyFile, mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import { promisify } from 'node:util';

const defaultExec = promisify(execFile);

// uploadWorkshopItem writes workshop.vdf inside the content folder it uploads, so the file would
// ship to players. This exec wrapper moves it out just before steamcmd reads it.
export function relocatingExec(exec = defaultExec) {
  return async (file, args, options) => {
    const index = args.findIndex((arg) => basename(arg) === 'workshop.vdf');
    if (index === -1) return exec(file, args, options);
    const outside = join(await mkdtemp(join(tmpdir(), 'workshop-vdf-')), 'workshop.vdf');
    await copyFile(args[index], outside);
    await rm(args[index]);
    return exec(file, args.map((arg, i) => (i === index ? outside : arg)), options);
  };
}
