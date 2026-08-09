// A first-line match is worth 0.5 to a grammar's score, and preferring
// Tree-sitter is worth only 0.1. So whenever a TextMate grammar declares
// `firstLineMatch` and its Tree-sitter twin declares no `firstLineRegex`, every
// file whose first line matches quietly gets the TextMate grammar — here, a
// script run through Boot.

describe("Clojure grammar selection", () => {
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-clojure");
    lumine.config.set("language.useTreeSitterParsers", true);
  });

  it("prefers the Tree-sitter grammar for a boot shebang", () => {
    const grammar = lumine.grammars.selectGrammar("build.clj", "#!/usr/bin/env boot\n(ns build)\n");

    expect(grammar.scopeName).toBe("source.clojure");
    expect(grammar.constructor.name).toBe("TreeSitterGrammar");
  });

  it("prefers the Tree-sitter grammar for an ordinary namespace", () => {
    const grammar = lumine.grammars.selectGrammar("build.clj", "(ns build)\n");

    expect(grammar.scopeName).toBe("source.clojure");
    expect(grammar.constructor.name).toBe("TreeSitterGrammar");
  });

  it("still honours the TextMate preference", () => {
    lumine.config.set("language.useTreeSitterParsers", false);

    const grammar = lumine.grammars.selectGrammar("build.clj", "#!/usr/bin/env boot\n(ns build)\n");

    expect(grammar.scopeName).toBe("source.clojure");
    expect(grammar.constructor.name).toBe("Grammar");
  });
});
