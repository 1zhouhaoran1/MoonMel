import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const root = fileURLToPath(new URL('../../', import.meta.url));
const build = spawnSync('moon', ['build', '--target', 'js', '--release'], {
  cwd: root, stdio: 'inherit', shell: false,
});
if (build.error) throw build.error;
if (build.status !== 0) process.exit(build.status ?? 1);
const destination = resolve(root, 'playground/src/generated');
mkdirSync(destination, { recursive: true });
copyFileSync(resolve(root, '_build/js/release/build/src/bindings/web/web.js'), resolve(destination, 'moonmel.js'));
console.log('Browser bindings synchronized from the current MoonBit source.');
