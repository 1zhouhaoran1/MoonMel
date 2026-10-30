import { readdirSync, readFileSync } from 'node:fs';
import { join, relative, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const defaultRoot = fileURLToPath(new URL('../../', import.meta.url));
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
export function checkArchitecture(root = defaultRoot) {
  const moduleName = /^name\s*=\s*"([^"]+)"/m.exec(readFileSync(join(root, 'moon.mod'), 'utf8'))?.[1];
  if (!moduleName) throw new Error('Missing module name in moon.mod');
  const graph = new Map();
  let edges = 0;
  for (const path of manifests(root)) {
    const name = relative(root, path).replaceAll('\\', '/').replace(/(^|\/)moon\.pkg$/, '');
    const dependencies = [...readFileSync(path, 'utf8').matchAll(/"([^"\n]+)"/g)]
      .map((match) => match[1])
      .filter((dependency) => dependency === moduleName || dependency.startsWith(`${moduleName}/`))
      .map((dependency) => dependency === moduleName ? '' : dependency.slice(moduleName.length + 1));
    graph.set(name, dependencies);
    edges += dependencies.length;
    for (const dependency of dependencies) {
      if (rank(dependency) > rank(name)) throw new Error(`${name || 'root'} imports higher layer ${dependency}`);
      if (name.startsWith('src/core/')) throw new Error(`Core must have no internal dependencies: ${name}`);
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
  return { packages: graph.size, edges };
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const { packages, edges } = checkArchitecture();
  console.log(`Architecture passed: ${packages} packages, ${edges} internal imports, no cycles or upward layer dependencies.`);
}
