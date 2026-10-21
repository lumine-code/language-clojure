module.exports = function registerInjections(grammars) {
  let injectionRegistrations = [];

  const path = require("path");

  const activate = function () {
    const notDisChild = (node) => {
      let parent = node.parent;
      while (parent) {
        if (parent.type === "dis_expr") return null;
        parent = parent.parent;
      }
      return node;
    };

    injectionRegistrations.push(
      grammars.addInjectionPoint("source.clojure", {
        type: "quoting_lit",
        language: () => "edn",
        content: notDisChild,
        includeChildren: true,
        languageScope: "source.clojure",
        coverShallowerScopes: true,
      }),
    );

    injectionRegistrations.push(
      grammars.addInjectionPoint("source.clojure", {
        type: "source",
        language: () => "edn",
        content: (node, buffer) => {
          if (path.extname(buffer.getPath() ?? "") === ".edn") {
            return node;
          }
        },
        includeChildren: true,
        languageScope: "source.clojure",
        coverShallowerScopes: true,
      }),
    );
  };

  const deactivate = function () {
    for (const registration of injectionRegistrations.splice(0)) registration.dispose();
  };

  activate();
  return { dispose: deactivate };
};
