import { Elm } from "./Main.elm";

window.addEventListener('load', function () {
    main = Elm.Main.init({ node: document.getElementById("root") });
    main.ports.submitSource.subscribe(function (source) {
        var editorNode = document.getElementById('editor');
        var codeNode = document.getElementById('code');
        console.log(source, editorNode)
        codeNode.value = source;
        editorNode.submit();
    });
});


document.addEventListener("DOMContentLoaded", () => {
    import('./Editor/code-editor')
    import('./Editor/column-divider')
});
