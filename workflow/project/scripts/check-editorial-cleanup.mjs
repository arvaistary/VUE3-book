#!/usr/bin/env node

import {
  cpSync,
  existsSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const CHAPTER_NAMES = [
  "00-introduction",
  "01-system-thinking",
  "02-application-state",
  "03-boundaries",
  "04-user-scenarios",
  "05-performance",
  "06-change-quality",
  "07-delivery",
  "08-resilient-patterns"
];
const PUBLIC_READER_FILES = [
  "public/README.md",
  "public/contents.md",
  ...CHAPTER_NAMES.map((name) => `public/${name}.md`)
];
const DRAFT_CHAPTER_FILES = CHAPTER_NAMES.map((name) => `draft/chapters/${name}.md`);
const REQUIRED_CHAPTER_HEADINGS = [
  "Ситуация и риск для пользователя",
  "Учебная цель",
  "Термины",
  "Минимальная задача",
  "Плохой пример",
  "Хороший пример",
  "Сравнение и ограничения",
  "Упражнение"
];
const EDITORIAL_PATTERNS = [
  /^#{1,6}\s+публичн(?:ая|ой|ую|ые|ых)?\s+проверк/im,
  /редакторск(?:ая|ой|ое|ую|ие|ий|ого|ом|ими|их)?\s+(?:провер|ревью|процесс|контекст|материал)/i,
  /(?:источник|источники)\s+и\s+провер/i,
  /privacy-review|evidence/i,
  /внутренн(?:ий|его|ему|им|ом)?\s+курс/i,
  /исходн(?:ый|ого|ому|ым|ом)?\s+проект/i,
  /доступ\s+к\s+(?:чужому|исходному)\s+репозитори/i,
  /на\s+дат(?:у|ы)\s+редактор/i,
  /перед\s+переносом/i,
  /техническ(?:ие|их|ими)?\s+утверждени[яй]\s+сверен/i,
  /синтетич(?:еский|еские|еских|еском|еского)?\s+(?:данн|пример|приложен)/i,
  /вымышлен(?:ы|ые|ых|ом|ого)?\s+(?:данн|идентификатор|пример|имена)/i
];

const options = parseArgs(process.argv.slice(2));
const root = resolve(options.root || REPO_ROOT);

if (options.selfTest) {
  runSelfTest(root);
} else {
  checkRoot(root);
  printSuccess();
}

function parseArgs(args) {
  const result = { root: null, selfTest: false };
  for (let index = 0; index < args.length; index += 1) {
    const argument = args[index];
    if (argument === "--root") {
      const value = args[index + 1];
      if (!value || value.startsWith("--")) throw new Error("--root requires a value");
      result.root = value;
      index += 1;
    } else if (argument === "--self-test") {
      result.selfTest = true;
    } else if (argument === "--help" || argument === "-h") {
      console.log("Usage: check-editorial-cleanup.mjs [--root PATH] [--self-test]");
      process.exit(0);
    } else {
      throw new Error("unknown argument: " + argument);
    }
  }
  return result;
}

function checkRoot(checkRootPath) {
  const errors = [];
  const readerTexts = new Map();

  for (const relativePath of PUBLIC_READER_FILES) {
    const fullPath = join(checkRootPath, relativePath);
    if (!existsSync(fullPath)) {
      errors.push("missing reader-facing file: " + relativePath);
      continue;
    }
    readerTexts.set(relativePath, readFileSync(fullPath, "utf8"));
  }

  for (const relativePath of DRAFT_CHAPTER_FILES) {
    const fullPath = join(checkRootPath, relativePath);
    if (!existsSync(fullPath)) {
      errors.push("missing draft chapter: " + relativePath);
    }
  }

  for (const [relativePath, text] of readerTexts) {
    for (const pattern of EDITORIAL_PATTERNS) {
      if (pattern.test(text)) {
        errors.push("editorial fragment in " + relativePath + ": " + pattern);
      }
    }
  }

  for (const relativePath of DRAFT_CHAPTER_FILES) {
    const fullPath = join(checkRootPath, relativePath);
    if (!existsSync(fullPath)) continue;
    const text = readFileSync(fullPath, "utf8");
    for (const pattern of EDITORIAL_PATTERNS) {
      if (pattern.test(text)) {
        errors.push("editorial fragment in " + relativePath + ": " + pattern);
      }
    }
  }

  for (const name of CHAPTER_NAMES.slice(1)) {
    const relativePath = `public/${name}.md`;
    const text = readerTexts.get(relativePath) || "";
    const headings = new Set([...text.matchAll(/^#{1,6}\s+(.+)$/gm)].map((match) => match[1].trim()));
    for (const heading of REQUIRED_CHAPTER_HEADINGS) {
      if (!headings.has(heading)) {
        errors.push("required reader section is missing in " + relativePath + ": " + heading);
      }
    }
  }

  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }

  return {
    readerFiles: PUBLIC_READER_FILES.length,
    draftChapters: DRAFT_CHAPTER_FILES.length,
    chapters: CHAPTER_NAMES.length - 1
  };
}

function runSelfTest(checkRootPath) {
  checkRoot(checkRootPath);
  const temporaryRoot = mkdtempSync(join(tmpdir(), "editorial-cleanup-"));
  try {
    for (const relativePath of [...PUBLIC_READER_FILES, ...DRAFT_CHAPTER_FILES]) {
      const sourcePath = join(checkRootPath, relativePath);
      const targetPath = join(temporaryRoot, relativePath);
      mkdirSync(dirname(targetPath), { recursive: true });
      cpSync(sourcePath, targetPath);
    }

    const regressionPath = join(temporaryRoot, "public/01-system-thinking.md");
    writeFileSync(regressionPath, readFileSync(regressionPath, "utf8") + "\n## Публичная проверка\n\nСлужебная вставка.\n");
    let rejected = false;
    try {
      checkRoot(temporaryRoot);
    } catch {
      rejected = true;
    }
    if (!rejected) throw new Error("negative editorial regression was not rejected");
    console.log("EDITORIAL_REGRESSION=PASS");
  } finally {
    rmSync(temporaryRoot, { recursive: true, force: true });
  }
  printSuccess();
}

function printSuccess() {
  console.log("EDITORIAL_FILES=PASS");
  console.log("EDITORIAL_META=PASS");
  console.log("TECHNICAL_SECTIONS=PASS");
  console.log("DRAFT_PUBLIC_COVERAGE=PASS");
  console.log("EDITORIAL_CLEAN=PASS");
}
