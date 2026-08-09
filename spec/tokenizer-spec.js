const path = require("path");

function setConfigForLanguageMode(mode) {
  let useTreeSitterParsers = mode !== "textmate";
  lumine.config.set("language.useTreeSitterParsers", useTreeSitterParsers);
}

describe("Clojure grammars", () => {
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-c");
    await lumine.packages.activatePackage("language-javascript");
    await lumine.packages.activatePackage("language-clojure");
  });

  it("tokenizes the editor using TextMate parser", async () => {
    setConfigForLanguageMode("textmate");
    await runGrammarTests(path.join(__dirname, "fixtures", "textmate-tokens.clj"), /;/);
  });

  it("tokenizes the editor using tree-sitter parser", async () => {
    setConfigForLanguageMode("tree-sitter");
    lumine.config.set("language-clojure.dismissTag", true);
    lumine.config.set("language-clojure.commentTag", false);
    lumine.config.set("language-clojure.markDeprecations", true);
    await runGrammarTests(path.join(__dirname, "fixtures", "tokens.clj"), /;/);
  });

  it("tokenizes EDN using tree-sitter parser", async () => {
    setConfigForLanguageMode("tree-sitter");
    lumine.config.set("language-clojure.dismissTag", true);
    await runGrammarTests(path.join(__dirname, "fixtures", "tokens.edn"), /;/);
  });

  it("tokenizes the editor using tree-sitter, but with all default configs toggled", async () => {
    setConfigForLanguageMode("tree-sitter");
    lumine.config.set("language-clojure.dismissTag", false);
    lumine.config.set("language-clojure.commentTag", true);
    lumine.config.set("language-clojure.markDeprecations", false);
    await runGrammarTests(path.join(__dirname, "fixtures", "config-toggle.clj"), /;/);
  });

  it("folds Clojure code", async () => {
    setConfigForLanguageMode("tree-sitter");
    await runFoldsTests(path.join(__dirname, "fixtures", "tree-sitter-folds.clj"), /;/);
  });
});
