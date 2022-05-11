  echo "EDITOR"
  # code mirror
  cat src/Editor/code-mirror/lib/codemirror.js \
      src/Editor/code-mirror/mode/elm.js \
      src/Editor/code-mirror/addon/edit/closebrackets.js \
      src/Editor/code-mirror/addon/edit/matchbrackets.js \
      src/Editor/code-mirror/addon/comment/comment.js \
      src/Editor/code-mirror/addon/search/searchcursor.js \
      src/Editor/code-mirror/addon/search/search.js \
      src/Editor/code-mirror/addon/dialog/dialog.js \
      src/Editor/code-mirror/lib/active-line.js \
      src/Editor/code-mirror/addon/dialog/dialog.js \
      src/Editor/code-mirror/keymap/sublime.js \
      > src/editor-codemirror.js

  # custom elements
  cat src/Editor/code-editor.js src/Editor/column-divider.js > src/editor-custom-elements.js

