describe("Conservative clojure indentation", () => {
  let editor;

  beforeEach(async () => {
    await lumine.packages.activatePackage("language-clojure");
    editor = await lumine.workspace.open();
    editor.setGrammar(lumine.grammars.grammarForScopeName("source.clojure"));
    editor.update({ tabLength: 4, softTabs: true });
    await editor.whenGrammarSettled();
  });

  afterEach(() => editor?.destroy());

  for (const [name, source, row, columns] of [
    ["an open vector", "(def values [\n])", 0, 4],
    ["a complete expression", "(def values [1 2])", 0, 0],
    ["a completed set in a vector", "[#{1 2}\n]", 0, 4],
    ["a literal", '"([{"', 0, 0],
    ["a comment", "; ([{", 0, 0],
    ["a nested body", "[\n    1\n]", 1, 4],
  ]) {
    it(`keeps the intended level after ${name}`, async () => {
      editor.setText(source);
      await editor.whenGrammarSettled();
      editor.setCursorBufferPosition([row, Infinity]);
      editor.insertText("\n", { autoIndent: true, autoIndentNewline: true });
      await editor.whenGrammarSettled();
      expect(editor.lineTextForBufferRow(row + 1)).toBe(" ".repeat(columns));
      expect(editor.getCursorBufferPosition().column).toBe(columns);
    });
  }

  it("dedents a closing delimiter only when it is typed at the start of a row", async () => {
    editor.setText("[" + "\n    ");
    await editor.whenGrammarSettled();
    editor.setCursorBufferPosition([1, Infinity]);
    editor.insertText("]", { autoIndent: true, autoDecreaseIndent: true });
    await editor.whenGrammarSettled();
    expect(editor.lineTextForBufferRow(1)).toBe("]");
  });

  it("preserves multiline literal contents during explicit reindent", async () => {
    const source = '"first\n\tkeep this tab\n  keep these spaces"\n';
    editor.setText(source);
    await editor.whenGrammarSettled();
    editor.getBuffer().clearUndoStack();
    editor.autoIndentBufferRows(0, editor.getLastBufferRow() - 1);
    await editor.whenGrammarSettled();
    expect(editor.getText()).toBe(source);
    editor.autoIndentBufferRows(0, editor.getLastBufferRow() - 1);
    expect(editor.getText()).toBe(source);
  });
});
