import { Elm } from "./Main.elm";
import('./Editor/code-editor')


window.addEventListener('load', function () {
    main = Elm.Main.init({ node: document.getElementById("root") });
    main.ports.submitSource.subscribe(function (source, id) {
        var editorNode = document.getElementById(id);
        var codeNode = document.getElementById(`${id}code`);
        codeNode.value = source;
        editorNode.submit();
    });
});


document.addEventListener("DOMContentLoaded", () => {
    import('./Editor/column-divider')
});
