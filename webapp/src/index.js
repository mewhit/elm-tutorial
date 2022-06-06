import { Elm } from "./Main.elm";

const ACCESS_TOKEN = "accessToken"

window.addEventListener('load', function () {
    const accessToken = this.localStorage.getItem(ACCESS_TOKEN) || ""

    const main = Elm.Main.init({ node: document.getElementById("root"), flags: { domain: process.env.DOMAIN, accessToken, now: Date.now() } });
    main.ports.saveAccessToken.subscribe((at) => {
        localStorage.setItem(ACCESS_TOKEN, at)
        main.ports.accessTokenSaved.send(ACCESS_TOKEN);
    })
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
