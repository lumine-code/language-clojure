const path = require("path");
const { Point } = require("lumine");

describe("Jank C++ literal injection", () => {
  let editor;
  beforeEach(async () => {
    await lumine.packages.activatePackage("language-c");
    await lumine.packages.activatePackage("language-javascript");
    await lumine.packages.activatePackage(path.resolve(__dirname, ".."));
    editor = await lumine.workspace.open("injection.jank");
  });
  afterEach(() => editor.destroy());

  const scopesAt = (editor, row, column) =>
    editor.scopeDescriptorForBufferPosition([row, column]).getScopesArray();
  const cppLayers = (editor) =>
    editor.languageMode
      .getAllLanguageLayers()
      .filter((layer) => layer.grammar.scopeName === "source.cpp");

  it("parses the actual cpp/raw string content at its buffer offset and updates it after an edit", async () => {
    editor.setText('(cpp/raw "int answer = 42;")');
    expect(await editor.whenGrammarSettled()).toBe(true);
    expect(editor.getGrammar().scopeName).toBe("source.clojure");
    expect(editor.languageMode.tree.rootNode.hasError).toBe(false);
    const content = editor.languageMode.tree.rootNode.descendantsOfType("str_content")[0];
    expect(content.text).toBe("int answer = 42;");
    expect(scopesAt(editor, 0, 10)).toContain("source.cpp");
    expect(scopesAt(editor, 0, 9)).not.toContain("source.cpp");
    expect(scopesAt(editor, 0, 26)).not.toContain("source.cpp");
    const layers = cppLayers(editor);
    expect(layers.length).toBe(1);
    if (layers.length === 1) {
      expect(layers[0].tree.rootNode.hasError).toBe(false);
      expect(layers[0].tree.rootNode.startIndex).toBe(content.startIndex);
      expect(layers[0].tree.rootNode.endIndex).toBe(content.endIndex);
    }
    editor.getBuffer().insert([0, 0], "; lead\n");
    expect(await editor.whenGrammarSettled()).toBe(true);
    expect(scopesAt(editor, 1, 10)).toContain("source.cpp");
    expect(cppLayers(editor).length).toBe(1);
  });

  it("preserves js* while excluding unrelated heads and nonleading cpp/raw symbols", async () => {
    editor.setText(
      '(js* "const answer = 42;")\n(other/raw "int ignored = 1;")\n(identity cpp/raw "int ignored = 2;")',
    );
    expect(await editor.whenGrammarSettled()).toBe(true);
    expect(scopesAt(editor, 0, 6)).toContain("source.js");
    expect(scopesAt(editor, 1, 12)).not.toContain("source.cpp");
    expect(scopesAt(editor, 2, 20)).not.toContain("source.cpp");
    expect(cppLayers(editor).length).toBe(0);
  });

  it("keeps injection content local inside a 6000-row Clojure parent", async () => {
    const lines = ["(do"];
    for (let index = 0; index < 6000; index++)
      lines.push(index === 3000 ? '  (cpp/raw "int local = 1;")' : `  value-${index}`);
    lines.push(")");
    editor.setText(lines.join("\n"));
    expect(await editor.whenGrammarSettled()).toBe(true);
    expect(editor.languageMode.tree.rootNode.hasError).toBe(false);
    const query = await editor.getGrammar().getQuery("injectionsQuery");
    const matches = query.matches(editor.languageMode.tree.rootNode, {
      startPosition: new Point(2998, 0),
      endPosition: new Point(3004, 0),
    });
    const captures = matches.flatMap((match) => match.captures);
    expect(matches.length).toBe(1);
    expect(captures.length).toBeLessThanOrEqual(3);
    expect(
      captures.every(
        ({ node }) => node.startPosition.row === 3001 && node.endPosition.row === 3001,
      ),
    ).toBe(true);
    expect(captures.find((capture) => capture.name === "injection.content")?.node.text).toBe(
      "int local = 1;",
    );
    expect(scopesAt(editor, 3001, 12)).toContain("source.cpp");
    expect(scopesAt(editor, 3000, 2)).not.toContain("source.cpp");
    expect(cppLayers(editor).length).toBe(1);
  });
});
