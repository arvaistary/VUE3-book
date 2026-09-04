#!/usr/bin/env node
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { posix } from "node:path";

const MAIN_FILES = [
  "README.md",
  ".gitignore",
  "dist/frontend-systems-book.epub",
  "public/README.md",
  "public/contents.md",
  "public/00-introduction.md",
  "public/01-system-thinking.md",
  "public/02-application-state.md",
  "public/03-boundaries.md",
  "public/04-user-scenarios.md",
  "public/05-performance.md",
  "public/06-change-quality.md",
  "public/07-delivery.md",
  "public/08-resilient-patterns.md"
];
const MANUSCRIPT_FILES = MAIN_FILES.filter((path) => path.startsWith("public/") && path.endsWith(".md"));
const CHAPTER_FILES = MANUSCRIPT_FILES.filter((path) => path !== "public/README.md" && path !== "public/contents.md");
const DRAFT_PREFIXES = ["draft/", "specs/", ".specify/", ".agents/", ".codex/", ".cursor/", "workflow/"];
const DRAFT_FILES = ["AGENTS.md"];
const EPUB_HASH = "b320a8cc6c765413914c4405f73a2e95be66601018d2ddc69340008caf8d63f6";

const ref = process.argv[2] || "main";
const files = treeFiles(ref);

if (ref === "main") {
  checkMain(files);
  console.log("PUBLIC_MAIN_TREE=PASS");
  checkMainNavigation(ref, files);
  console.log("PUBLIC_NAVIGATION=PASS");
  checkEpub(ref, files);
  console.log("PUBLIC_EPUB=PASS");
} else if (ref === "drafts") {
  checkDrafts(files);
  console.log("DRAFTS_TREE=PASS");
  checkPublicParity(ref, files);
  console.log("DRAFTS_PUBLIC_PARITY=PASS");
} else {
  throw new Error("unsupported ref; use main or drafts");
}

console.log("PUBLICATION_CHECK=PASS");

function treeFiles(branch) {
  const output = git(["ls-tree", "-r", "--name-only", branch]);
  const result = output.split("\n").map((line) => line.trim()).filter(Boolean);
  if (result.length === 0) throw new Error("branch has no tracked files: " + branch);
  return result;
}

function checkMain(files) {
  assertSameSet(files, MAIN_FILES, "main publication allowlist");
  for (const prefix of DRAFT_PREFIXES) {
    assert(!files.some((path) => path.startsWith(prefix)), "draft-only path in main: " + prefix);
  }
  for (const path of DRAFT_FILES) {
    assert(!files.includes(path), "draft-only file in main: " + path);
  }
}

function checkDrafts(files) {
  for (const path of MAIN_FILES) {
    assert(files.includes(path), "drafts is missing published path: " + path);
  }
  for (const prefix of DRAFT_PREFIXES) {
    assert(files.some((path) => path.startsWith(prefix)), "drafts is missing work area: " + prefix);
  }
  for (const path of DRAFT_FILES) {
    assert(files.includes(path), "drafts is missing work file: " + path);
  }
}

function checkMainNavigation(branch, files) {
  const rootLinks = localLinks("README.md", show(branch, "README.md"));
  const expectedRootTargets = [
    "dist/frontend-systems-book.epub",
    "public/contents.md",
    "public/00-introduction.md",
    ...CHAPTER_FILES.filter((path) => path !== "public/00-introduction.md")
  ];
  assertSameSet(rootLinks, expectedRootTargets, "root README navigation");

  const contentsLinks = localLinks("public/contents.md", show(branch, "public/contents.md"));
  assertSameSet(contentsLinks, CHAPTER_FILES, "contents navigation");
  for (const target of [...rootLinks, ...contentsLinks]) {
    assert(files.includes(target), "navigation target is absent: " + target);
  }
}

function checkEpub(branch, files) {
  const path = "dist/frontend-systems-book.epub";
  assert(files.includes(path), "published EPUB is missing");
  const hash = sha256(showBuffer(branch, path));
  assert(hash === EPUB_HASH, "published EPUB hash mismatch: " + hash);
}

function checkPublicParity(branch, files) {
  for (const path of [...MANUSCRIPT_FILES, "dist/frontend-systems-book.epub"]) {
    assert(files.includes(path), "drafts is missing parity path: " + path);
    assert(sha256(showBuffer(branch, path)) === sha256(showBuffer("main", path)),
      "drafts public path differs from main: " + path);
  }
}

function localLinks(source, content) {
  const links = [];
  for (const match of content.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)) {
    const target = match[1].trim();
    if (/^(https?:|mailto:|tel:|#)/i.test(target)) continue;
    const pathPart = target.split("#", 1)[0];
    const normalized = posix.normalize(posix.join(posix.dirname(source), pathPart));
    assert(!normalized.startsWith("../") && normalized !== "..", "link escapes repository: " + source + " -> " + target);
    links.push(normalized);
  }
  return links;
}

function assertSameSet(actual, expected, description) {
  const normalizedActual = [...new Set(actual)].sort();
  const normalizedExpected = [...new Set(expected)].sort();
  assert(JSON.stringify(normalizedActual) === JSON.stringify(normalizedExpected),
    description + " mismatch; actual=" + normalizedActual.join(",") + "; expected=" + normalizedExpected.join(","));
}

function show(branch, path) {
  return showBuffer(branch, path).toString("utf8");
}

function showBuffer(branch, path) {
  return git(["show", branch + ":" + path], true);
}

function sha256(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

function git(args, binary = false) {
  return execFileSync("git", args, { encoding: binary ? undefined : "utf8", maxBuffer: 64 * 1024 * 1024 });
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}
