const fs = require("fs");
const path = require("path");
const { Point } = require("lumine");

const queryDir = path.join(__dirname, "..", "grammars");

describe("Clojure grammars", () => {
  let editor;
  let languageMode;

  beforeEach(async () => {
    await lumine.packages.activatePackage("language-c");
    await lumine.packages.activatePackage("language-javascript");
    await lumine.packages.activatePackage("language-clojure");
  });

  afterEach(() => editor?.destroy());

  async function setUp(text, scopeName = "source.clojure") {
    editor = await lumine.workspace.open();
    editor.setGrammar(lumine.grammars.grammarForScopeName(scopeName));
    editor.setText(text);
    languageMode = editor.getBuffer().languageMode;
    await languageMode.ready;
  }

  function scopesAt(row, text, occurrence = 0) {
    const line = editor.lineTextForBufferRow(row);
    let column = -1;
    for (let i = 0; i <= occurrence; i++) column = line.indexOf(text, column + 1);
    expect(column).not.toBe(-1);
    return editor.scopeDescriptorForBufferPosition([row, column]).getScopesArray();
  }

  function rawCaptures(startRow, endRow) {
    const options =
      startRow == null
        ? undefined
        : {
            startPosition: new Point(startRow, 0),
            endPosition: new Point(endRow, 0),
          };
    const layer = languageMode.rootLanguageLayer;
    return layer.queries.highlightsQuery.captures(layer.tree.rootNode, options);
  }

  it("tokenizes the editor using tree-sitter parser", async () => {
    lumine.config.set("language-clojure.dismissTag", true);
    lumine.config.set("language-clojure.commentTag", false);
    lumine.config.set("language-clojure.markDeprecations", true);
    await runGrammarTests(path.join(__dirname, "fixtures", "tokens.clj"), /;/);
  });

  it("tokenizes EDN using tree-sitter parser", async () => {
    lumine.config.set("language-clojure.dismissTag", true);
    await runGrammarTests(path.join(__dirname, "fixtures", "tokens.edn"), /;/);
  });

  it("tokenizes the editor using tree-sitter, but with all default configs toggled", async () => {
    lumine.config.set("language-clojure.dismissTag", false);
    lumine.config.set("language-clojure.commentTag", true);
    lumine.config.set("language-clojure.markDeprecations", false);
    await runGrammarTests(path.join(__dirname, "fixtures", "config-toggle.clj"), /;/);
  });

  it("folds Clojure code", async () => {
    await runFoldsTests(path.join(__dirname, "fixtures", "tree-sitter-folds.clj"), /;/);
  });

  it("keeps unbounded EDN collections and string delimiters leaf-rooted", () => {
    const queries = ["edn-only-highlights.scm", "clojure-edn-highlights.scm"]
      .map((name) => fs.readFileSync(path.join(queryDir, name), "utf8"))
      .join("\n");

    expect(queries).not.toMatch(/\((?:list_lit|vec_lit|map_lit|set_lit)\s*\n\s*["[]/);
    for (const type of ["list_lit", "vec_lit", "map_lit", "set_lit", "str_lit"]) {
      expect(queries).toContain(`(#is? test.childOfType ${type})`);
    }
    expect(queries).toContain(String.raw`(("\"" @punctuation.definition.string.begin.clojure)`);
    expect(queries).toContain('adjust.endBeforeFirstMatchOf "\\\\r?\\\\n?$"');
  });

  it("keeps Clojure call-list captures leaf-rooted", () => {
    const query = fs.readFileSync(path.join(queryDir, "clojure-highlights.scm"), "utf8");

    expect(query).not.toMatch(/\(list_lit\s*\n\s*["(]/);
    expect(query).toContain('(#is? test.matchAt "firstNamedChild ^ns$")');
    expect(query).toContain('(#is? test.matchAt "previousNamedSibling /def")');
    expect(query).toContain('(#is? test.childOfType "list_lit anon_fn_lit")');
  });

  it("preserves collection, string, and CRLF comment scopes", async () => {
    await setUp(`; generated\r
(foo ["value"] {:key "value"} #{:value})
""`);

    expect(scopesAt(0, ";")).toContain("comment.line.semicolon.clojure");
    expect(scopesAt(1, "(")).toContain("punctuation.section.expression.begin.clojure");
    expect(scopesAt(1, "[")).toContain("punctuation.section.vector.begin.clojure");
    expect(scopesAt(1, "]")).toContain("punctuation.section.vector.end.clojure");
    expect(scopesAt(1, "{", 0)).toContain("punctuation.section.map.begin.clojure");
    expect(scopesAt(1, "}", 0)).toContain("punctuation.section.map.end.clojure");
    expect(scopesAt(1, "#{")).toContain("punctuation.section.set.begin.clojure");
    expect(scopesAt(1, "}", 1)).toContain("punctuation.section.set.end.clojure");
    expect(scopesAt(1, '"', 0)).toContain("punctuation.definition.string.begin.clojure");
    expect(scopesAt(1, '"', 1)).toContain("punctuation.definition.string.end.clojure");
    expect(scopesAt(1, "(")).not.toContain("comment.line.semicolon.clojure");
    expect(scopesAt(2, '"', 0)).toContain("punctuation.definition.string.begin.clojure");
    expect(scopesAt(2, '"', 1)).toContain("punctuation.definition.string.end.clojure");
  });

  it("keeps leaf-rooted EDN captures viewport-local", async () => {
    await setUp(
      `(
  [
    {:key "value"}
  ]
)`,
      "source.edn",
    );

    const captures = rawCaptures(2, 5).filter(
      (capture) =>
        capture.name.startsWith("punctuation.section.") ||
        capture.name.startsWith("punctuation.definition.string."),
    );
    expect(captures.every((capture) => capture.node.startPosition.row >= 2)).toBe(true);
    expect(
      captures.some(
        (capture) =>
          capture.name === "punctuation.definition.string.begin.clojure" &&
          capture.node.startPosition.row === 2,
      ),
    ).toBe(true);
    expect(
      captures.some(
        (capture) =>
          capture.name === "punctuation.section.vector.end.clojure" &&
          capture.node.startPosition.row === 3,
      ),
    ).toBe(true);
    expect(
      captures.some(
        (capture) =>
          capture.name === "punctuation.section.list.end.clojure" &&
          capture.node.startPosition.row === 4,
      ),
    ).toBe(true);
  });

  it("bounds raw work inside a 6000-row list parent", async () => {
    const lines = ["(benchmark"];
    for (let i = 0; i < 6000; i++) lines.push(`  value-${i}`);
    lines.push(")");
    await setUp(lines.join("\r\n"));

    const tileCaptures = rawCaptures(2998, 3004);
    expect(tileCaptures.length).toBeLessThanOrEqual(64);
    expect(
      tileCaptures
        .filter((capture) => capture.name.startsWith("punctuation.section.list."))
        .every(
          (capture) =>
            capture.node.startPosition.row >= 2998 && capture.node.startPosition.row < 3004,
        ),
    ).toBe(true);
  });
});
