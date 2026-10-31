describe("Literal recovery in clojure", () => {
  let editor;
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-clojure");
    editor = await lumine.workspace.open();
    editor.setGrammar(lumine.grammars.grammarForScopeName("source.clojure"));
    editor.update({ tabLength: 4, softTabs: true });
    await editor.whenGrammarSettled();
  });
  afterEach(() => editor?.destroy());

  async function enterAfter(source, columns) {
    editor.setText(source);
    await editor.whenGrammarSettled();
    const row = editor.getLastBufferRow();
    editor.setCursorBufferPosition([row, Infinity]);
    editor.insertText("\n", { autoIndent: true, autoIndentNewline: true });
    await editor.whenGrammarSettled();
    expect(editor.lineTextForBufferRow(row + 1))
      .withContext(source)
      .toBe(" ".repeat(columns));
    expect(editor.getCursorBufferPosition().column).withContext(source).toBe(columns);
  }

  for (const [source, columns] of [
    ['(def text "{', 0],
    ['    (def text "{', 4],
  ]) {
    it("keeps the literal margin for " + JSON.stringify(source), async () => {
      await enterAfter(source, columns);
    });
  }

  for (const source of ["(def values [", '(def text "ok") (def values [']) {
    it("still indents a real container in " + JSON.stringify(source), async () => {
      await enterAfter(source, 4);
    });
  }
});
