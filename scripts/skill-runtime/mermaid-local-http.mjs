// Mermaid CLI loads its own HTML over HTTP because this environment's managed
// Chromium blocks file:// navigation. Only the installed npm runtime is served.
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const moduleRoot = '/workspace/.tooling/mermaid/node_modules';
const packageRoot = path.join(moduleRoot, '@mermaid-js/mermaid-cli');
const puppeteerRoot = path.join(moduleRoot, 'puppeteer');
const puppeteerManifest = JSON.parse(fs.readFileSync(path.join(puppeteerRoot, 'package.json'), 'utf8'));
// Use the same ESM export as Mermaid, rather than its independent CJS instance.
const {default: puppeteer} = await import(pathToFileURL(path.join(puppeteerRoot, puppeteerManifest.exports['.'].import)).href);
const mime = {'.html':'text/html', '.js':'text/javascript', '.mjs':'text/javascript',
  '.css':'text/css', '.json':'application/json', '.svg':'image/svg+xml',
  '.woff':'font/woff', '.woff2':'font/woff2'};
const server = http.createServer((req,res) => {
  try {
    const requested = path.resolve(moduleRoot, '.' + decodeURIComponent(new URL(req.url,'http://localhost').pathname));
    const real = fs.realpathSync(requested);
    if (!real.startsWith(moduleRoot + path.sep) || !fs.statSync(real).isFile()) {
      res.writeHead(403).end(); return;
    }
    res.setHeader('Content-Type', mime[path.extname(real)] || 'application/octet-stream');
    fs.createReadStream(real).pipe(res);
  } catch { res.writeHead(404).end(); }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const port = server.address().port;
const launch = puppeteer.launch.bind(puppeteer);
puppeteer.launch = async options => {
  const browser = await launch({...options, executablePath: '/usr/bin/chromium',
    args: [...(options?.args || []), '--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']});
  const newPage = browser.newPage.bind(browser);
  browser.newPage = async () => {
    const page = await newPage();
    const goto = page.goto.bind(page);
    page.goto = (url, ...args) => {
      if (String(url).startsWith('file:')) {
        const file = fs.realpathSync(fileURLToPath(url));
        if (!file.startsWith(moduleRoot + path.sep)) throw new Error('Refusing file outside Mermaid runtime');
        url = `http://127.0.0.1:${port}/` + path.relative(moduleRoot,file).split(path.sep).map(encodeURIComponent).join('/');
      }
      return goto(url, ...args);
    };
    return page;
  };
  return browser;
};
try {
  const {cli} = await import(pathToFileURL(path.join(packageRoot,'src/index.js')).href);
  await cli();
} finally {
  await new Promise(resolve => server.close(resolve));
}
