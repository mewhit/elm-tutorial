import { Elm } from "./Main.elm";


window.addEventListener('load', function () {
    const main = Elm.Main.init({ node: document.getElementById("root"), flags: { domain: process.env.DOMAIN } });
    main.ports.submitSource.subscribe(function (source, id) {
        var editorNode = document.getElementById(id);
        var codeNode = document.getElementById(`${id}code`);
        codeNode.value = source;
        editorNode.submit();
    });
});


document.addEventListener("DOMContentLoaded", () => {
    import('./Editor/code-editor')
    import('./Editor/column-divider')
});
