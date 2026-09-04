#!/usr/bin/env node
import { inflateRawSync } from "node:zlib";
import { readFile } from "node:fs/promises";
import { posix, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = resolve(fileURLToPath(new URL("../../..", import.meta.url)));
const DEFAULT_INPUT = resolve(REPO_ROOT, "dist/frontend-systems-book.epub");
const EXPECTED_ENTRIES = [
  "mimetype",
  "META-INF/container.xml",
  "OEBPS/package.opf",
  "OEBPS/nav.xhtml",
  "OEBPS/styles.css",
  "OEBPS/cover.xhtml",
  "OEBPS/contents.xhtml",
  "OEBPS/00-introduction.xhtml",
  "OEBPS/01-system-thinking.xhtml",
  "OEBPS/02-application-state.xhtml",
  "OEBPS/03-boundaries.xhtml",
  "OEBPS/04-user-scenarios.xhtml",
  "OEBPS/05-performance.xhtml",
  "OEBPS/06-change-quality.xhtml",
  "OEBPS/07-delivery.xhtml",
  "OEBPS/08-resilient-patterns.xhtml"
];
const EXPECTED_SPINE = [
  "cover",
  "contents",
  "intro",
  "chapter-1",
  "chapter-2",
  "chapter-3",
  "chapter-4",
  "chapter-5",
  "chapter-6",
  "chapter-7",
  "chapter-8"
];
const EXPECTED_NAV_HREFS = [
  "cover.xhtml",
  "contents.xhtml",
  "00-introduction.xhtml",
  "01-system-thinking.xhtml",
  "02-application-state.xhtml",
  "03-boundaries.xhtml",
  "04-user-scenarios.xhtml",
  "05-performance.xhtml",
  "06-change-quality.xhtml",
  "07-delivery.xhtml",
  "08-resilient-patterns.xhtml"
];

async function main() {
  const input = resolve(process.argv[2] || DEFAULT_INPUT);
  const archive = await readFile(input);
  const zip = parseZip(archive);

  checkZipEnvelope(zip);
  console.log("EPUB_INPUT=PASS");

  const entries = zip.entries;
  const container = textOf(entries, "META-INF/container.xml");
  const opf = textOf(entries, "OEBPS/package.opf");
  const nav = textOf(entries, "OEBPS/nav.xhtml");
  const css = textOf(entries, "OEBPS/styles.css");
  const manifest = checkPackage(container, opf, entries);
  checkNavigation(nav, entries);
  console.log("EPUB_STRUCTURE=PASS");

  checkContent(entries, manifest);
  console.log("EPUB_CONTENT=PASS");

  checkPrivacy(entries);
  console.log("EPUB_PRIVACY=PASS");

  checkAccessibility(entries, css);
  console.log("EPUB_ACCESSIBILITY=PASS");
  console.log("EPUB_CHECK=PASS");
}

function parseZip(buffer) {
  const eocdOffset = findEndOfCentralDirectory(buffer);
  assert(buffer.readUInt16LE(eocdOffset + 4) === 0, "multi-disk ZIP is not supported");
  assert(buffer.readUInt16LE(eocdOffset + 6) === 0, "multi-disk ZIP is not supported");
  const entryCount = buffer.readUInt16LE(eocdOffset + 10);
  const centralSize = buffer.readUInt32LE(eocdOffset + 12);
  const centralOffset = buffer.readUInt32LE(eocdOffset + 16);
  assert(centralOffset + centralSize <= eocdOffset, "central directory overlaps ZIP trailer");

  const entries = new Map();
  const orderedNames = [];
  let cursor = centralOffset;
  for (let index = 0; index < entryCount; index += 1) {
    assert(cursor + 46 <= buffer.length, "truncated central directory");
    assert(buffer.readUInt32LE(cursor) === 0x02014b50, "invalid central directory signature");
    const flags = buffer.readUInt16LE(cursor + 8);
    const method = buffer.readUInt16LE(cursor + 10);
    const crc = buffer.readUInt32LE(cursor + 16);
    const compressedSize = buffer.readUInt32LE(cursor + 20);
    const uncompressedSize = buffer.readUInt32LE(cursor + 24);
    const nameLength = buffer.readUInt16LE(cursor + 28);
    const extraLength = buffer.readUInt16LE(cursor + 30);
    const commentLength = buffer.readUInt16LE(cursor + 32);
    const localOffset = buffer.readUInt32LE(cursor + 42);
    const name = buffer.subarray(cursor + 46, cursor + 46 + nameLength).toString("utf8");
    assert(name && !entries.has(name), "duplicate ZIP entry: " + name);
    assert((flags & 0x0001) === 0, "encrypted ZIP entry: " + name);
    const data = readEntryData(buffer, localOffset, method, crc, compressedSize, uncompressedSize, name);
    entries.set(name, { data, method, flags, compressedSize, uncompressedSize });
    orderedNames.push(name);
    cursor += 46 + nameLength + extraLength + commentLength;
  }
  assert(cursor === centralOffset + centralSize, "central directory size mismatch");
  assert(entryCount === entries.size, "ZIP entry count mismatch");
  return { entries, orderedNames };
}

function findEndOfCentralDirectory(buffer) {
  const minimumOffset = Math.max(0, buffer.length - 0xffff - 22);
  for (let offset = buffer.length - 22; offset >= minimumOffset; offset -= 1) {
    if (buffer.readUInt32LE(offset) === 0x06054b50) {
      assert(offset + 22 <= buffer.length, "truncated ZIP trailer");
      assert(offset + 22 + buffer.readUInt16LE(offset + 20) === buffer.length, "unexpected ZIP trailer data");
      return offset;
    }
  }
  throw new Error("ZIP end of central directory was not found");
}

function readEntryData(buffer, localOffset, method, expectedCrc, compressedSize, uncompressedSize, name) {
  assert(localOffset + 30 <= buffer.length, "truncated local header: " + name);
  assert(buffer.readUInt32LE(localOffset) === 0x04034b50, "invalid local header: " + name);
  const localNameLength = buffer.readUInt16LE(localOffset + 26);
  const localExtraLength = buffer.readUInt16LE(localOffset + 28);
  const dataOffset = localOffset + 30 + localNameLength + localExtraLength;
  const compressed = buffer.subarray(dataOffset, dataOffset + compressedSize);
  assert(compressed.length === compressedSize, "truncated ZIP entry: " + name);
  let data;
  if (method === 0) {
    data = Buffer.from(compressed);
  } else if (method === 8) {
    data = inflateRawSync(compressed);
  } else {
    throw new Error("unsupported compression method " + method + ": " + name);
  }
  assert(data.length === uncompressedSize, "uncompressed size mismatch: " + name);
  assert(crc32(data) === expectedCrc, "CRC mismatch: " + name);
  return data;
}

function checkZipEnvelope(zip) {
  assert(zip.orderedNames[0] === "mimetype", "mimetype must be the first ZIP entry");
  assert(zip.entries.size === EXPECTED_ENTRIES.length, "unexpected number of EPUB entries");
  assert(JSON.stringify(zip.orderedNames) === JSON.stringify(EXPECTED_ENTRIES), "ZIP entry order or allowlist mismatch");
  const mimetype = zip.entries.get("mimetype");
  assert(mimetype.method === 0, "mimetype must be stored without compression");
  assert(mimetype.data.toString("utf8") === "application/epub+zip", "invalid mimetype content");
  for (const name of EXPECTED_ENTRIES) assert(zip.entries.has(name), "missing EPUB entry: " + name);
}

function checkPackage(container, opf, entries) {
  assert(container.includes('full-path="OEBPS/package.opf"'), "container does not point to package.opf");
  assert(opf.includes('version="3.0"'), "package is not EPUB 3.x");
  assert(opf.includes('unique-identifier="pub-id"'), "package identifier is missing");
  assert(opf.includes("<dc:title>Проектирование frontend-систем</dc:title>"), "book title is missing");
  assert(opf.includes("<dc:language>ru</dc:language>"), "book language is missing");
  assert(opf.includes("urn:uuid:7c3e4f9c-5a1b-4d9f-8e2c-20260904f001"), "stable publication identifier is missing");
  assert(opf.includes("2026-09-04T00:00:00Z"), "fixed modification date is missing");

  const itemTags = [...opf.matchAll(/<item\b[^>]*\/?>(?:<\/item>)?/g)].map((match) => match[0]);
  const manifest = new Map();
  for (const tag of itemTags) {
    const id = attribute(tag, "id");
    const href = attribute(tag, "href");
    assert(id && href, "manifest item lacks id or href");
    assert(!manifest.has(id), "duplicate manifest id: " + id);
    manifest.set(id, { href, mediaType: attribute(tag, "media-type"), properties: attribute(tag, "properties") || "" });
  }
  assert(manifest.size === 13, "unexpected manifest item count");
  assert(manifest.get("nav")?.properties.split(/\s+/).includes("nav"), "navigation item lacks nav property");
  for (const item of manifest.values()) {
    assert(!item.href.includes("..") && !/^[a-z]+:/i.test(item.href), "manifest href escapes OEBPS: " + item.href);
    assert(entries.has("OEBPS/" + item.href), "manifest href has no archive entry: " + item.href);
  }

  const spineIds = [...opf.matchAll(/<itemref\b[^>]*\bidref="([^"]+)"[^>]*\/?>(?:<\/itemref>)?/g)].map((match) => match[1]);
  assert(JSON.stringify(spineIds) === JSON.stringify(EXPECTED_SPINE), "spine order mismatch");
  for (const id of spineIds) assert(manifest.has(id), "spine references missing manifest item: " + id);
  return manifest;
}

function checkNavigation(nav, entries) {
  assert(nav.includes('<nav epub:type="toc"'), "navigation document lacks epub:type=toc");
  assert(nav.includes("<ol>"), "navigation document lacks an ordered list");
  const hrefs = [...nav.matchAll(/<a\s+href="([^"]+)"/g)].map((match) => match[1]);
  assert(JSON.stringify(hrefs) === JSON.stringify(EXPECTED_NAV_HREFS), "navigation order or links mismatch");
  for (const href of hrefs) assert(entries.has("OEBPS/" + href), "navigation link has no target: " + href);
}

function checkContent(entries, manifest) {
  const contentNames = EXPECTED_ENTRIES.filter((name) => name.endsWith(".xhtml"));
  for (const name of contentNames) {
    const content = textOf(entries, name);
    assert(content.startsWith('<?xml version="1.0" encoding="UTF-8"?>'), "missing UTF-8 declaration: " + name);
    assert(content.includes('xmlns="http://www.w3.org/1999/xhtml"'), "missing XHTML namespace: " + name);
    assert(content.includes('lang="ru"') && content.includes('xml:lang="ru"'), "missing Russian language markers: " + name);
    assert(content.includes('href="styles.css"'), "missing stylesheet link: " + name);
    assert(!content.includes("\ufffd"), "invalid UTF-8 replacement character: " + name);
    assert(!content.includes("\u0000"), "unresolved inline markup token: " + name);
    assert(!/&(?!amp;|lt;|gt;|quot;|apos;|#\d+;|#x[0-9a-f]+;)/i.test(content), "unescaped ampersand: " + name);
    checkLocalLinks(name, content, entries);
  }

  const chapterNames = contentNames.filter((name) => !["OEBPS/nav.xhtml", "OEBPS/cover.xhtml"].includes(name));
  for (const name of chapterNames) {
    const content = textOf(entries, name);
    assert(content.includes("<main"), "manuscript document lacks main landmark: " + name);
    assert(content.includes("<h1") || name === "OEBPS/contents.xhtml", "manuscript document lacks a heading: " + name);
  }
  assert(manifest.get("styles")?.mediaType === "text/css", "stylesheet media type is incorrect");
}

function checkLocalLinks(name, content, entries) {
  for (const match of content.matchAll(/\bhref="([^"]+)"/g)) {
    const href = match[1];
    if (href.startsWith("#")) continue;
    if (/^(https?:|mailto:|tel:)/i.test(href)) continue;
    assert(!/^[a-z]+:/i.test(href), "unsupported link scheme in " + name + ": " + href);
    const pathPart = href.split("#", 1)[0];
    const target = posix.normalize(posix.join(posix.dirname(name), pathPart));
    assert(target.startsWith("OEBPS/") && !target.includes("../"), "link escapes OEBPS in " + name + ": " + href);
    assert(entries.has(target), "local link target is absent in " + name + ": " + href);
  }
}

function checkPrivacy(entries) {
  const forbiddenEntry = /(^|\/)(draft|specs|workflow)(\/|$)|(^|\/)(README|AGENTS)\.md$/i;
  const forbiddenText = /theoryGPT|henderson|\/Users\/|\/Volumes\/|localhost|127\.0\.0\.1/i;
  for (const [name, entry] of entries) {
    assert(!forbiddenEntry.test(name), "forbidden worktree entry: " + name);
    const content = entry.data.toString("utf8");
    assert(!forbiddenText.test(content), "private or local path marker in entry: " + name);
    assert(!/\.(?:md|json|env|log)$/i.test(name), "source or runtime artifact in EPUB: " + name);
  }
}

function checkAccessibility(entries, css) {
  assert(!/position\s*:\s*fixed/i.test(css), "stylesheet uses fixed positioning");
  assert(/overflow-wrap\s*:/i.test(css), "code wrapping rule is missing");
  assert(/white-space\s*:\s*pre-wrap/i.test(css), "reflowable code rule is missing");
  const nav = textOf(entries, "OEBPS/nav.xhtml");
  assert(/<nav\s+epub:type="toc"[^>]*id="toc"/.test(nav), "navigation landmark is not identifiable");
  for (const name of EXPECTED_ENTRIES.filter((entry) => entry.endsWith(".xhtml"))) {
    const content = textOf(entries, name);
    assert(/<title>[^<]+<\/title>/.test(content), "document title is missing: " + name);
  }
}

function textOf(entries, name) {
  const entry = entries.get(name);
  assert(entry, "missing EPUB entry: " + name);
  return entry.data.toString("utf8");
}

function attribute(tag, name) {
  const match = tag.match(new RegExp("\\b" + name + "=\\\"([^\\\"]*)\\\""));
  return match ? match[1] : "";
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const CRC_TABLE = Array.from({ length: 256 }, (_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit += 1) {
    value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
  }
  return value >>> 0;
});

function crc32(buffer) {
  let value = 0xffffffff;
  for (const byte of buffer) value = CRC_TABLE[(value ^ byte) & 0xff] ^ (value >>> 8);
  return (value ^ 0xffffffff) >>> 0;
}

main().catch((error) => {
  console.error("EPUB check failed: " + error.message);
  process.exitCode = 1;
});
