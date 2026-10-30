import { execFileSync } from 'node:child_process';
const version = execFileSync('moonc', ['-v'], { encoding: 'utf8' }).trim();
const parts = /v?(\d+)\.(\d+)\.(\d+)/.exec(version);
if (!parts) throw new Error(`Cannot parse compiler version: ${version}`);
const [major, minor, patch] = parts.slice(1).map(Number);
if (major === 0 && (minor < 10 || (minor === 10 && patch < 16))) {
  throw new Error(`Acceptance requires moonc >= 0.10.16; got ${version}. On this Windows workspace: . ./tools/dev/activate.ps1`);
}
console.log(`Compiler requirement passed: ${version}`);
