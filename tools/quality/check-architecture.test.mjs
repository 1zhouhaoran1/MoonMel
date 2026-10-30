import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { checkArchitecture } from './check-architecture.mjs';

function fixture(t, packages) {
  const parent = new URL('../../_build/', import.meta.url);
  mkdirSync(parent, { recursive: true });
  const root = mkdtempSync(new URL('architecture-', parent));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  writeFileSync(join(root, 'moon.mod'), 'name = "1zhouhaoran1/moonmel"\n');
  for (const [name, dependencies] of Object.entries(packages)) {
    mkdirSync(join(root, name), { recursive: true });
    writeFileSync(join(root, name, 'moon.pkg'), `import {${dependencies.map((d) => `"1zhouhaoran1/moonmel${d ? `/${d}` : ''}"`).join(',')}}`);
  }
  return root;
}

test('current namespace dependencies are counted', (t) => {
  assert.deepEqual(checkArchitecture(fixture(t, { '': ['src/facade'], 'src/facade': ['src/core/types'], 'src/core/types': [] })), { packages: 3, edges: 2 });
});
test('rejects an upward dependency in the current namespace', (t) => {
  assert.throws(() => checkArchitecture(fixture(t, { 'src/dsp/fft': ['src/facade'], 'src/facade': [] })), /higher layer/);
});
test('rejects same-layer cycles', (t) => {
  assert.throws(() => checkArchitecture(fixture(t, { 'src/dsp/a': ['src/dsp/b'], 'src/dsp/b': ['src/dsp/a'] })), /cycle/);
});
test('rejects unresolved internal packages', (t) => {
  assert.throws(() => checkArchitecture(fixture(t, { 'src/facade': ['src/dsp/missing'] })), /Missing package/);
});
test('core packages cannot import another core package', (t) => {
  assert.throws(() => checkArchitecture(fixture(t, { 'src/core/a': ['src/core/b'], 'src/core/b': [] })), /Core must/);
});
