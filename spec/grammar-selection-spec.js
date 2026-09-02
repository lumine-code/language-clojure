// Boot shebangs and ordinary extensions resolve to the same Tree-sitter grammar.

describe("Clojure grammar selection", () => {
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-clojure");
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
});
