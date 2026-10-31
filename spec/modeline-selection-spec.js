describe("clojure modeline selection", () => {
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-clojure");
  });
  it("selects exact Vim aliases", () => {
    for (const field of ["ft", "filetype", "syntax"]) {
      const source = "# vim: set " + field + "=" + "clojure" + ":";
      expect(lumine.grammars.selectGrammar("extensionless", source).scopeName)
        .withContext(source)
        .toBe("source.clojure");
    }
  });
  it("rejects aliases that only start with the language name", () => {
    for (const field of ["ft", "filetype", "syntax"])
      for (const suffix of ["ish", "_extra", "-extra", ".extra"]) {
        const source = "# vim: set " + field + "=" + "clojure" + suffix + ":";
        expect(lumine.grammars.selectGrammar("extensionless", source).scopeName)
          .withContext(source)
          .not.toBe("source.clojure");
      }
  });
  it("bounds supported Emacs mode aliases", () => {
    for (const alias of ["clojure", "clojurescript"]) {
      expect(
        lumine.grammars.selectGrammar("extensionless", ";; -*- mode: " + alias + " -*-").scopeName,
      ).toBe("source.clojure");
      for (const suffix of ["ish", "_extra", "-extra", ".extra"]) {
        const source = ";; -*- mode: " + alias + suffix + " -*-";
        expect(lumine.grammars.selectGrammar("extensionless", source).scopeName)
          .withContext(source)
          .not.toBe("source.clojure");
      }
    }
  });
});
