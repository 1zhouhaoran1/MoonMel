import { readdirSync, readFileSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../../', import.meta.url));
function manifests(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (['_build', '.git', 'node_modules', '.mooncakes'].includes(entry.name)) return [];
    const path = join(directory, entry.name);
    return entry.isDirectory() ? manifests(path) : entry.name === 'moon.pkg' ? [path] : [];
  });
}
function rank(name) {
  if (name === '') return 5;
  const top = name.split('/')[1];
  return { core: 0, dsp: 1, codec: 1, features: 2, pipeline: 3, facade: 4, bindings: 5 }[top] ?? 6;
}
const graph = new Map();
for (const path of manifests(root)) {
  const name = relative(root, path).replaceAll('\\', '/').replace(/(^|\/)moon\.pkg$/, '');
  const dependencies = [...readFileSync(path, 'utf8').matchAll(/"zhr\/moonmel(?:\/([^"@]+))?"/g)]
    .map((match) => match[1] ?? '');
  graph.set(name, dependencies);
  for (const dependency of dependencies) {
    if (rank(dependency) > rank(name)) throw new Error(`${name || 'root'} imports higher layer ${dependency}`);
    if (name.startsWith('src/core/') && dependency) throw new Error(`Core must have no internal dependencies: ${name}`);
  }
}
const active = new Set();
const visited = new Set();
function visit(name) {
  if (active.has(name)) throw new Error(`Dependency cycle at ${name}`);
  if (visited.has(name)) return;
  if (!graph.has(name)) throw new Error(`Missing package: ${name}`);
  active.add(name);
  for (const dependency of graph.get(name)) visit(dependency);
  active.delete(name);
  visited.add(name);
}
for (const name of graph.keys()) visit(name);
console.log(`Architecture passed: ${graph.size} packages, no cycles or upward layer dependencies.`);
