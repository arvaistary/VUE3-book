#!/usr/bin/env node
import { deflateRawSync } from "node:zlib";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, posix, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const DEFAULT_SOURCE = join(REPO_ROOT, "public");
const DEFAULT_OUTPUT = join(REPO_ROOT, "dist/frontend-systems-book.epub");
const MODIFIED = "2026-09-04T00:00:00Z";
const PUBLIC_FILES = [
  "contents.md",
  "00-introduction.md",
  "01-system-thinking.md",
  "02-application-state.md",
  "03-boundaries.md",
  "04-user-scenarios.md",
  "05-performance.md",
  "06-change-quality.md",
  "07-delivery.md",
  "08-resilient-patterns.md"
];
const XHTML_FILES = new Map([
  ["contents.md", "contents.xhtml"],
  ["00-introduction.md", "00-introduction.xhtml"],
  ["01-system-thinking.md", "01-system-thinking.xhtml"],
  ["02-application-state.md", "02-application-state.xhtml"],
  ["03-boundaries.md", "03-boundaries.xhtml"],
  ["04-user-scenarios.md", "04-user-scenarios.xhtml"],
  ["05-performance.md", "05-performance.xhtml"],
  ["06-change-quality.md", "06-change-quality.xhtml"],
  ["07-delivery.md", "07-delivery.xhtml"],
  ["08-resilient-patterns.md", "08-resilient-patterns.xhtml"]
]);
const EPUB_CONTENT = [
  { source: "cover", output: "cover.xhtml", title: "Проектирование frontend-систем" },
  { source: "contents.md", output: "contents.xhtml", title: "Содержание" },
  { source: "00-introduction.md", output: "00-introduction.xhtml", title: "Введение. Frontend как система" },
  { source: "01-system-thinking.md", output: "01-system-thinking.xhtml", title: "Часть 1. Как мыслить о frontend-системе" },
  { source: "02-application-state.md", output: "02-application-state.xhtml", title: "Часть 2. Состояние приложения и SSR" },
  { source: "03-boundaries.md", output: "03-boundaries.xhtml", title: "Часть 3. Границы ответственности: API, сервисы и middleware" },
  { source: "04-user-scenarios.md", output: "04-user-scenarios.xhtml", title: "Часть 4. Пользовательские сценарии: формы и авторизация" },
  { source: "05-performance.md", output: "05-performance.xhtml", title: "Часть 5. Производительность, SEO и внешние интеграции" },
  { source: "06-change-quality.md", output: "06-change-quality.xhtml", title: "Часть 6. TypeScript, тестирование и code review" },
  { source: "07-delivery.md", output: "07-delivery.xhtml", title: "Часть 7. Доставка, окружения и эксплуатация" },
  { source: "08-resilient-patterns.md", output: "08-resilient-patterns.xhtml", title: "Часть 8. Устойчивые UI-решения и паттерны Vue" }
];

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const sourceRoot = resolve(options.source || DEFAULT_SOURCE);
  const outputPath = resolve(options.output || DEFAULT_OUTPUT);
  const sourceTexts = new Map();

  for (const file of PUBLIC_FILES) {
    sourceTexts.set(file, await readFile(join(sourceRoot, file), "utf8"));
  }

  const entries = [
    ["mimetype", Buffer.from("application/epub+zip", "utf8"), 0],
    ["META-INF/container.xml", Buffer.from(containerXml(), "utf8"), 8],
    ["OEBPS/package.opf", Buffer.from(packageOpf(), "utf8"), 8],
    ["OEBPS/nav.xhtml", Buffer.from(navXhtml(), "utf8"), 8],
    ["OEBPS/styles.css", Buffer.from(stylesCss(), "utf8"), 8],
    ["OEBPS/cover.xhtml", Buffer.from(coverXhtml(), "utf8"), 8]
  ];

  for (const item of EPUB_CONTENT.slice(1)) {
    const markdown = sourceTexts.get(item.source);
    const body = renderMarkdown(markdown, item.source);
    entries.push([
      "OEBPS/" + item.output,
      Buffer.from(contentXhtml(item.title, body, item.output.replace(".xhtml", "")), "utf8"),
      8
    ]);
  }

  await mkdir(dirname(outputPath), { recursive: true });
  await writeFile(outputPath, createZip(entries));
  console.log("EPUB_BUILD=PASS");
  console.log("SOURCE_FILES=" + PUBLIC_FILES.length);
  console.log("EPUB_ENTRIES=" + entries.length);
  console.log("OUTPUT=" + outputPath);
}

function parseArgs(args) {
  const options = {};
  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--source" || argument === "--output") {
      const value = args[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(argument + " requires a value");
      }
      options[argument.slice(2)] = value;
      index += 1;
    } else if (argument === "--help" || argument === "-h") {
      console.log("Usage: build-epub.mjs [--source public] [--output dist/book.epub]");
      process.exit(0);
    } else {
      throw new Error("unknown argument: " + argument);
    }
  }
  return options;
}

function containerXml() {
  return '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">\n' +
    '  <rootfiles><rootfile full-path="OEBPS/package.opf" media-type="application/oebps-package+xml"/></rootfiles>\n' +
    '</container>\n';
}

function packageOpf() {
  const manifest = [
    '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
    '<item id="styles" href="styles.css" media-type="text/css"/>',
    '<item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="contents" href="contents.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="intro" href="00-introduction.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-1" href="01-system-thinking.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-2" href="02-application-state.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-3" href="03-boundaries.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-4" href="04-user-scenarios.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-5" href="05-performance.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-6" href="06-change-quality.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-7" href="07-delivery.xhtml" media-type="application/xhtml+xml"/>',
    '<item id="chapter-8" href="08-resilient-patterns.xhtml" media-type="application/xhtml+xml"/>'
  ].join("\n    ");
  const spine = [
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
  ].map((id) => '<itemref idref="' + id + '"/>').join("\n    ");

  return '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id">\n' +
    '  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/">\n' +
    '    <dc:identifier id="pub-id">urn:uuid:7c3e4f9c-5a1b-4d9f-8e2c-20260904f001</dc:identifier>\n' +
    '    <dc:title>Проектирование frontend-систем</dc:title>\n' +
    '    <dc:language>ru</dc:language>\n' +
    '    <meta property="dcterms:modified">' + MODIFIED + '</meta>\n' +
    '  </metadata>\n' +
    '  <manifest>\n    ' + manifest + '\n  </manifest>\n' +
    '  <spine>\n    ' + spine + '\n  </spine>\n' +
    '</package>\n';
}

function navXhtml() {
  const items = EPUB_CONTENT.map((item) =>
    '<li><a href="' + item.output + '">' + escapeXml(item.title) + "</a></li>"
  ).join("\n      ");
  return xhtmlDocument("Содержание", '<nav epub:type="toc" id="toc">\n    <h1>Содержание</h1>\n    <ol>\n      ' + items + '\n    </ol>\n  </nav>', "nav");
}

function coverXhtml() {
  return xhtmlDocument("Проектирование frontend-систем",
    '<section epub:type="cover" class="title-page">\n' +
    '    <p class="kicker">Техническая книга</p>\n' +
    '    <h1>Проектирование frontend-систем</h1>\n' +
    '    <p>Архитектура, состояние, SSR, границы ответственности, качество и эксплуатация.</p>\n' +
    '  </section>', "cover");
}

function contentXhtml(title, body, id) {
  return xhtmlDocument(title, '<main id="' + escapeXml(id) + '">\n' + body + "\n  </main>", id);
}

function xhtmlDocument(title, body, id) {
  return '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<!DOCTYPE html>\n' +
    '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="ru" xml:lang="ru">\n' +
    '  <head>\n' +
    '    <meta charset="utf-8"/>\n' +
    '    <meta name="viewport" content="width=device-width, initial-scale=1"/>\n' +
    '    <title>' + escapeXml(title) + '</title>\n' +
    '    <link rel="stylesheet" type="text/css" href="styles.css"/>\n' +
    '  </head>\n' +
    '  <body data-document="' + escapeXml(id) + '">\n' +
    "  " + body + "\n" +
    "  </body>\n" +
    "</html>\n";
}

function stylesCss() {
  return [
    "body { margin: 0; padding: 1rem; color: #202124; font-family: Georgia, serif; line-height: 1.55; }",
    "main, nav { max-width: 48rem; margin: 0 auto; }",
    "h1, h2, h3, h4 { line-height: 1.2; margin-top: 1.6em; }",
    "h1 { font-size: 1.8rem; }",
    "h2 { font-size: 1.45rem; }",
    "h3 { font-size: 1.2rem; }",
    "p, li { orphans: 2; widows: 2; }",
    "pre { overflow-x: auto; padding: 0.8rem; background: #f1f3f4; font-family: monospace; line-height: 1.35; white-space: pre-wrap; overflow-wrap: anywhere; }",
    "code { font-family: monospace; }",
    "pre code { white-space: pre-wrap; }",
    "table { border-collapse: collapse; width: 100%; }",
    "th, td { border: 1px solid #9aa0a6; padding: 0.35rem; text-align: left; vertical-align: top; }",
    "blockquote { margin: 1rem 0; padding-left: 1rem; border-left: 0.25rem solid #9aa0a6; }",
    ".title-page { min-height: 80vh; display: flex; flex-direction: column; justify-content: center; }",
    ".kicker { text-transform: uppercase; letter-spacing: 0.08em; }",
    "a { color: #174ea6; }"
  ].join("\n") + "\n";
}

function renderMarkdown(markdown, sourceName) {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const output = [];
  const anchors = new Set();
  const fencePattern = new RegExp("^(" + String.fromCharCode(96).repeat(3) + "|~~~)(.*)$");

  let index = 0;
  while (index < lines.length) {
    const line = lines[index];
    if (!line.trim()) {
      index += 1;
      continue;
    }

    const fence = line.match(fencePattern);
    if (fence) {
      const marker = fence[1];
      const language = fence[2].trim();
      const code = [];
      index += 1;
      while (index < lines.length && !lines[index].startsWith(marker)) {
        code.push(lines[index]);
        index += 1;
      }
      if (index === lines.length) {
        throw new Error("unclosed code fence in " + sourceName);
      }
      index += 1;
      const className = language ? ' class="language-' + escapeXml(language) + '"' : "";
      output.push("<pre><code" + className + ">" + escapeXml(code.join("\n")) + "</code></pre>");
      continue;
    }

    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      const level = heading[1].length;
      const id = uniqueAnchor(heading[2], anchors);
      output.push("<h" + level + ' id="' + id + '">' + renderInline(heading[2], sourceName) + "</h" + level + ">");
      index += 1;
      continue;
    }

    if (isTableStart(lines, index)) {
      const table = renderTable(lines, index, sourceName);
      output.push(table.html);
      index = table.nextIndex;
      continue;
    }

    if (/^\s*[-*]\s+/.test(line)) {
      const list = [];
      while (index < lines.length && /^\s*[-*]\s+/.test(lines[index])) {
        list.push(lines[index].replace(/^\s*[-*]\s+/, ""));
        index += 1;
      }
      output.push("<ul>\n" + list.map((item) => "  <li>" + renderInline(item, sourceName) + "</li>").join("\n") + "\n</ul>");
      continue;
    }

    if (/^\s*\d+\.\s+/.test(line)) {
      const list = [];
      while (index < lines.length && /^\s*\d+\.\s+/.test(lines[index])) {
        list.push(lines[index].replace(/^\s*\d+\.\s+/, ""));
        index += 1;
      }
      output.push("<ol>\n" + list.map((item) => "  <li>" + renderInline(item, sourceName) + "</li>").join("\n") + "\n</ol>");
      continue;
    }

    if (/^>\s?/.test(line)) {
      const quote = [];
      while (index < lines.length && /^>\s?/.test(lines[index])) {
        quote.push(lines[index].replace(/^>\s?/, ""));
        index += 1;
      }
      output.push("<blockquote><p>" + renderInline(quote.join(" "), sourceName) + "</p></blockquote>");
      continue;
    }

    if (/^\s*(---+|\*\*\*|___)\s*$/.test(line)) {
      output.push("<hr/>");
      index += 1;
      continue;
    }

    const paragraph = [line];
    index += 1;
    while (index < lines.length && lines[index].trim() &&
      !fencePattern.test(lines[index]) &&
      !/^(#{1,6})\s+/.test(lines[index]) &&
      !/^\s*[-*]\s+/.test(lines[index]) &&
      !/^\s*\d+\.\s+/.test(lines[index]) &&
      !/^>\s?/.test(lines[index]) &&
      !isTableStart(lines, index) &&
      !/^\s*(---+|\*\*\*|___)\s*$/.test(lines[index])) {
      paragraph.push(lines[index]);
      index += 1;
    }
    output.push("<p>" + renderInline(paragraph.join(" "), sourceName) + "</p>");
  }

  return output.join("\n");
}

function isTableStart(lines, index) {
  if (!lines[index] || !lines[index].trim().startsWith("|") || !lines[index + 1]) {
    return false;
  }
  return /^\s*\|?(\s*:?-{3,}:?\s*\|)+\s*$/.test(lines[index + 1]);
}

function renderTable(lines, index, sourceName) {
  const header = parseTableRow(lines[index]);
  index += 2;
  const rows = [];
  while (index < lines.length && lines[index].trim().startsWith("|")) {
    rows.push(parseTableRow(lines[index]));
    index += 1;
  }
  const headHtml = header.map((cell) => "<th>" + renderInline(cell, sourceName) + "</th>").join("");
  const bodyHtml = rows.map((row) =>
    "<tr>" + row.map((cell) => "<td>" + renderInline(cell, sourceName) + "</td>").join("") + "</tr>"
  ).join("\n");
  return {
    html: "<table><thead><tr>" + headHtml + "</tr></thead><tbody>" + bodyHtml + "</tbody></table>",
    nextIndex: index
  };
}

function parseTableRow(line) {
  let value = line.trim();
  if (value.startsWith("|")) value = value.slice(1);
  if (value.endsWith("|")) value = value.slice(0, -1);
  return value.split("|").map((cell) => cell.trim());
}

function renderInline(text, sourceName) {
  const protectedMarkup = [];
  const protect = (html) => {
    const token = "\u0000" + protectedMarkup.length + "\u0000";
    protectedMarkup.push(html);
    return token;
  };
  let value = String(text);
  value = value.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, label, target) =>
    protect('<a href="' + escapeXml(resolveHref(target, sourceName)) + '">' +
      renderInline(label, sourceName) + "</a>")
  );

  const codeMark = String.fromCharCode(96);
  const codePattern = new RegExp(codeMark + "([^" + codeMark + "]+)" + codeMark, "g");
  value = value.replace(codePattern, (match, code) => protect("<code>" + escapeXml(code) + "</code>"));
  value = value.replace(/\*\*([^*]+)\*\*/g, (match, strong) => protect("<strong>" + escapeXml(strong) + "</strong>"));
  value = value.replace(/\*([^*]+)\*/g, (match, emphasis) => protect("<em>" + escapeXml(emphasis) + "</em>"));
  value = escapeXml(value);
  let restored = value;
  let previous;
  do {
    previous = restored;
    restored = restored.replace(/\u0000(\d+)\u0000/g, (match, token) => protectedMarkup[Number(token)] || "");
  } while (restored !== previous && /\u0000\d+\u0000/.test(restored));
  return restored;
}

function resolveHref(target, sourceName) {
  const trimmed = target.trim();
  if (trimmed.startsWith("#")) return trimmed;
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  if (/^(mailto:|tel:)/i.test(trimmed)) return trimmed;
  if (trimmed.startsWith("/") || trimmed.includes("://")) {
    throw new Error("unsupported or private link in " + sourceName + ": " + trimmed);
  }

  const hashIndex = trimmed.indexOf("#");
  const pathPart = hashIndex >= 0 ? trimmed.slice(0, hashIndex) : trimmed;
  const fragment = hashIndex >= 0 ? trimmed.slice(hashIndex) : "";
  const normalized = posix.normalize(posix.join(posix.dirname(sourceName), pathPart.replace(/^\.\//, "")));
  if (!XHTML_FILES.has(normalized)) {
    throw new Error("local link does not target included manuscript file in " + sourceName + ": " + trimmed);
  }
  return XHTML_FILES.get(normalized) + fragment;
}

function uniqueAnchor(text, anchors) {
  const base = String(text).toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, "-")
    .replace(/^-+|-+$/g, "") || "section";
  let id = base;
  let suffix = 2;
  while (anchors.has(id)) {
    id = base + "-" + suffix;
    suffix += 1;
  }
  anchors.add(id);
  return id;
}

function escapeXml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function createZip(entries) {
  const localParts = [];
  const centralParts = [];
  let offset = 0;

  for (const [name, data, method] of entries) {
    const nameBytes = Buffer.from(name, "utf8");
    const compressed = method === 0 ? data : deflateRawSync(data, { level: 9 });
    const crc = crc32(data);
    const flags = 0x0800;
    const local = Buffer.alloc(30 + nameBytes.length);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(20, 4);
    local.writeUInt16LE(flags, 6);
    local.writeUInt16LE(method, 8);
    local.writeUInt16LE(0, 10);
    local.writeUInt16LE(0, 12);
    local.writeUInt32LE(crc, 14);
    local.writeUInt32LE(compressed.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(nameBytes.length, 26);
    local.writeUInt16LE(0, 28);
    nameBytes.copy(local, 30);
    localParts.push(local, compressed);

    const central = Buffer.alloc(46 + nameBytes.length);
    central.writeUInt32LE(0x02014b50, 0);
    central.writeUInt16LE(20, 4);
    central.writeUInt16LE(20, 6);
    central.writeUInt16LE(flags, 8);
    central.writeUInt16LE(method, 10);
    central.writeUInt16LE(0, 12);
    central.writeUInt16LE(0, 14);
    central.writeUInt32LE(crc, 16);
    central.writeUInt32LE(compressed.length, 20);
    central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(nameBytes.length, 28);
    central.writeUInt16LE(0, 30);
    central.writeUInt16LE(0, 32);
    central.writeUInt16LE(0, 34);
    central.writeUInt16LE(0, 36);
    central.writeUInt32LE(0, 38);
    central.writeUInt32LE(offset, 42);
    nameBytes.copy(central, 46);
    centralParts.push(central);

    offset += local.length + compressed.length;
  }

  const centralDirectory = Buffer.concat(centralParts);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(0, 4);
  end.writeUInt16LE(0, 6);
  end.writeUInt16LE(entries.length, 8);
  end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(centralDirectory.length, 12);
  end.writeUInt32LE(offset, 16);
  end.writeUInt16LE(0, 20);

  return Buffer.concat([...localParts, centralDirectory, end]);
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
  for (const byte of buffer) {
    value = CRC_TABLE[(value ^ byte) & 0xff] ^ (value >>> 8);
  }
  return (value ^ 0xffffffff) >>> 0;
}

main().catch((error) => {
  console.error("EPUB build failed: " + error.message);
  process.exitCode = 1;
});
