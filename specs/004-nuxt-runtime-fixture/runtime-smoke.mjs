import assert from "node:assert/strict";
import { spawn, spawnSync } from "node:child_process";
import { createServer, request } from "node:http";
import { fileURLToPath } from "node:url";
import { dirname, join, relative, resolve, sep } from "node:path";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";

const SCRIPT_ROOT = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(SCRIPT_ROOT, "../..");
const PRIVATE_MARKER = "fixture-private-marker-7b3";

const fixtures = [
  {
    id: "nuxt3-baseline",
    version: "3.21.11",
    publicMarker: "nuxt3-public-marker",
    pluginLabel: "nuxt-3-plugin",
    files: createNuxt3Files()
  },
  {
    id: "nuxt4-structure",
    version: "4.5.2",
    publicMarker: "nuxt4-public-marker",
    pluginLabel: "nuxt-4-plugin",
    files: createNuxt4Files()
  }
];

const observations = [];

for (const fixture of fixtures) {
  await runFixture(fixture);
}

console.log("NUXT3_RUNTIME=PASS");
console.log("NUXT4_RUNTIME=PASS");
console.log("SSR_DATA=PASS");
console.log("RUNTIME_CONFIG=PASS");
console.log("BOUNDARIES=PASS");
console.log("FIXTURE_ISOLATION=PASS");
console.log("PUBLIC_BOUNDARY=PASS");
console.log("Observed fixtures: " + observations.map((item) => item.id).join(", "));
for (const observation of observations) {
  const label = observation.id.toUpperCase().replaceAll("-", "_");
  console.log(label + "_VERSION=" + observation.version);
  console.log(label + "_OUTSIDE_REPO=" + observation.outsideRepo);
  console.log(label + "_PRIVATE_EXPOSED=" + observation.privateMarkerExposed);
}
console.log("Node: " + process.version);
console.log("npm: " + run("npm", ["--version"], REPO_ROOT).stdout.trim());

async function runFixture(fixture) {
  const root = await mkdtemp(join(tmpdir(), "nuxt-runtime-fixture-"));
  const outsideRepo = !resolve(root).startsWith(REPO_ROOT + sep);
  assert.equal(outsideRepo, true, fixture.id + " fixture must be outside repository");

  let child;
  try {
    await writeFixture(root, fixture);
    run("npm", [
      "install",
      "--no-audit",
      "--no-fund",
      "--legacy-peer-deps",
      "--save-exact",
      "nuxt@" + fixture.version
    ], root);

    const nuxtBin = join(root, "node_modules", ".bin", "nuxt");
    run(nuxtBin, ["prepare"], root);
    run(nuxtBin, ["build"], root);

    const installed = JSON.parse(run("npm", ["list", "nuxt", "--json", "--depth=0"], root).stdout);
    const installedVersion = installed.dependencies && installed.dependencies.nuxt
      ? installed.dependencies.nuxt.version
      : null;
    assert.equal(installedVersion, fixture.version, fixture.id + " version must be pinned");

    const port = await getFreePort();
    child = spawn(process.execPath, [join(root, ".output", "server", "index.mjs")], {
      cwd: root,
      env: {
        ...process.env,
        HOST: "127.0.0.1",
        PORT: String(port),
        NODE_ENV: "production",
        NUXT_PRIVATE_MARKER: PRIVATE_MARKER,
        NUXT_PUBLIC_FIXTURE_MARKER: fixture.publicMarker
      },
      stdio: ["ignore", "pipe", "pipe"]
    });

    const rootResponse = await waitForHttp(child, "http://127.0.0.1:" + port + "/");
    const apiResponse = await getHttp("http://127.0.0.1:" + port + "/api/message");

    assert.equal(rootResponse.status, 200, fixture.id + " page status");
    assert.equal(apiResponse.status, 200, fixture.id + " API status");
    assert.equal(rootResponse.body.includes(fixture.publicMarker), true, fixture.id + " public marker");
    assert.equal(rootResponse.body.includes(fixture.pluginLabel), true, fixture.id + " plugin marker");
    assert.equal(rootResponse.body.includes("FIXTURE-MESSAGE"), true, fixture.id + " SSR message");
    assert.equal(rootResponse.body.includes("checked"), true, fixture.id + " middleware marker");
    assert.equal(rootResponse.body.includes(PRIVATE_MARKER), false, fixture.id + " private marker in HTML");
    assert.equal(apiResponse.body.includes(PRIVATE_MARKER), false, fixture.id + " private marker in API");

    const api = JSON.parse(apiResponse.body);
    assert.deepEqual(api, {
      message: "fixture-message",
      publicMarker: fixture.publicMarker,
      hasPrivateMarker: true
    }, fixture.id + " safe API response");

    observations.push({
      id: fixture.id,
      version: installedVersion,
      pageStatus: rootResponse.status,
      apiStatus: apiResponse.status,
      hasPrivateMarker: api.hasPrivateMarker,
      privateMarkerExposed: false,
      outsideRepo
    });
  } catch (error) {
    throw new Error(fixture.id + " failed: " + redact(error.message));
  } finally {
    if (child) {
      await stopProcess(child);
    }
    await rm(root, { recursive: true, force: true });
  }
}

async function writeFixture(root, fixture) {
  const packageJson = {
    private: true,
    type: "module"
  };

  await writeFile(join(root, "package.json"), JSON.stringify(packageJson, null, 2) + "\n");
  for (const [file, content] of Object.entries(fixture.files)) {
    const target = join(root, file);
    await mkdir(dirname(target), { recursive: true });
    await writeFile(target, content);
  }
}

function createNuxt3Files() {
  return {
    "nuxt.config.ts": [
      "export default defineNuxtConfig({",
      "  devtools: { enabled: false },",
      "  runtimeConfig: {",
      "    privateMarker: '',",
      "    public: { fixtureMarker: '' }",
      "  }",
      "})",
      ""
    ].join("\n"),
    "pages/index.vue": [
      "<script setup lang='ts'>",
      "const { data } = await useFixtureMessage()",
      "const config = useRuntimeConfig()",
      "const nuxtApp = useNuxtApp()",
      "const route = useRoute()",
      "</script>",
      "",
      "<template>",
      "  <main data-fixture='nuxt3'>",
      "    <h1>{{ data?.message?.toUpperCase() }}</h1>",
      "    <p>{{ config.public.fixtureMarker }}</p>",
      "    <p>{{ nuxtApp.$fixtureLabel }}</p>",
      "    <p>{{ route.meta.fixtureBoundary }}</p>",
      "  </main>",
      "</template>",
      ""
    ].join("\n"),
    "composables/useFixtureMessage.ts": [
      "export function useFixtureMessage() {",
      "  return useFetch('/api/message', { key: 'fixture-message' })",
      "}",
      ""
    ].join("\n"),
    "plugins/fixture.ts": [
      "export default defineNuxtPlugin(() => ({",
      "  provide: { fixtureLabel: 'nuxt-3-plugin' }",
      "}))",
      ""
    ].join("\n"),
    "middleware/fixture.global.ts": [
      "export default defineNuxtRouteMiddleware((to) => {",
      "  to.meta.fixtureBoundary = 'checked'",
      "})",
      ""
    ].join("\n"),
    "server/api/message.get.ts": apiFile(),
    "public/fixture.txt": "synthetic public asset\n"
  };
}

function createNuxt4Files() {
  return {
    "nuxt.config.ts": [
      "export default defineNuxtConfig({",
      "  devtools: { enabled: false },",
      "  runtimeConfig: {",
      "    privateMarker: '',",
      "    public: { fixtureMarker: '' }",
      "  }",
      "})",
      ""
    ].join("\n"),
    "app/app.vue": [
      "<template>",
      "  <NuxtPage />",
      "</template>",
      ""
    ].join("\n"),
    "app/pages/index.vue": [
      "<script setup lang='ts'>",
      "import { formatMessage } from '#shared/utils/format-message'",
      "const { data } = await useFixtureMessage()",
      "const config = useRuntimeConfig()",
      "const nuxtApp = useNuxtApp()",
      "const route = useRoute()",
      "const formatted = formatMessage(data.value?.message || 'missing')",
      "</script>",
      "",
      "<template>",
      "  <main data-fixture='nuxt4'>",
      "    <h1>{{ formatted }}</h1>",
      "    <p>{{ config.public.fixtureMarker }}</p>",
      "    <p>{{ nuxtApp.$fixtureLabel }}</p>",
      "    <p>{{ route.meta.fixtureBoundary }}</p>",
      "  </main>",
      "</template>",
      ""
    ].join("\n"),
    "app/composables/useFixtureMessage.ts": [
      "export function useFixtureMessage() {",
      "  return useFetch('/api/message', { key: 'fixture-message' })",
      "}",
      ""
    ].join("\n"),
    "app/plugins/fixture.ts": [
      "export default defineNuxtPlugin(() => ({",
      "  provide: { fixtureLabel: 'nuxt-4-plugin' }",
      "}))",
      ""
    ].join("\n"),
    "app/middleware/fixture.global.ts": [
      "export default defineNuxtRouteMiddleware((to) => {",
      "  to.meta.fixtureBoundary = 'checked'",
      "})",
      ""
    ].join("\n"),
    "server/api/message.get.ts": apiFile(),
    "public/fixture.txt": "synthetic public asset\n",
    "shared/utils/format-message.ts": [
      "export function formatMessage(message: string) {",
      "  return message.toUpperCase()",
      "}",
      ""
    ].join("\n")
  };
}

function apiFile() {
  return [
    "export default defineEventHandler((event) => {",
    "  const config = useRuntimeConfig(event)",
    "  return {",
    "    message: 'fixture-message',",
    "    publicMarker: config.public.fixtureMarker,",
    "    hasPrivateMarker: Boolean(config.privateMarker)",
    "  }",
    "})",
    ""
  ].join("\n");
}

function run(command, args, cwd) {
  const result = spawnSync(command, args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"]
  });

  if (result.status !== 0) {
    const detail = result.stderr || result.stdout || "no command output";
    throw new Error("command " + command + " " + args.join(" ") + ": " + redact(detail).slice(-1600));
  }

  return {
    stdout: result.stdout || "",
    stderr: result.stderr || ""
  };
}

function redact(value) {
  return String(value).split(PRIVATE_MARKER).join("[redacted-private-marker]");
}

async function getFreePort() {
  const server = createServer();
  await new Promise((resolvePromise, rejectPromise) => {
    server.once("error", rejectPromise);
    server.listen(0, "127.0.0.1", resolvePromise);
  });
  const address = server.address();
  const port = typeof address === "object" && address ? address.port : null;
  await new Promise((resolvePromise) => server.close(resolvePromise));
  assert.notEqual(port, null, "free port must be available");
  return port;
}

async function waitForHttp(child, url) {
  for (let attempt = 0; attempt < 120; attempt += 1) {
    if (child.exitCode !== null) {
      throw new Error("production server exited before HTTP smoke");
    }

    try {
      return await getHttp(url);
    } catch {
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 250));
    }
  }

  throw new Error("production server did not become ready");
}

function getHttp(url) {
  return new Promise((resolvePromise, rejectPromise) => {
    const requestHandle = request(url, { timeout: 3000 }, (response) => {
      const chunks = [];
      response.setEncoding("utf8");
      response.on("data", (chunk) => chunks.push(chunk));
      response.on("end", () => {
        resolvePromise({
          status: response.statusCode,
          body: chunks.join("")
        });
      });
    });

    requestHandle.on("error", rejectPromise);
    requestHandle.on("timeout", () => {
      requestHandle.destroy(new Error("HTTP request timeout"));
    });
    requestHandle.end();
  });
}

async function stopProcess(child) {
  if (child.exitCode !== null) {
    return;
  }

  child.kill("SIGTERM");
  await new Promise((resolvePromise) => {
    const timer = setTimeout(() => {
      if (child.exitCode === null) {
        child.kill("SIGKILL");
      }
      resolvePromise();
    }, 2000);
    child.once("exit", () => {
      clearTimeout(timer);
      resolvePromise();
    });
  });
}
