import CodeMirror from "codemirror";
import './elm.mode';
import 'codemirror/addon/edit/closebrackets';
import 'codemirror/addon/edit/matchbrackets';
import 'codemirror/addon/comment/comment';
import 'codemirror/addon/search/searchcursor';
import 'codemirror/addon/search/search';
import 'codemirror/addon/dialog/dialog';
// import 'codemirror/lib/active-line';
import 'codemirror/addon/dialog/dialog';
import 'codemirror/keymap/sublime';


function isPositionNull(position) {
  return position === null || position.line === null || position.column === null;
}

function isPositionEqual(a, b) {
  return (b && b.line) === (a && a.line) && (b && b.column) === (a && a.column);
}


// CODEMIRROR: EXTRA KEYS

function handleTab(cm) {
  cm.execCommand("indentMore");
}

function handleUntab(cm) {
  cm.execCommand("indentLess");
}


// GET HINT

function getHint(editor, importEnd) {
  var start = editor.getCursor('anchor');
  var cursor = editor.getCursor('head');

  if (start.line !== cursor.line || start.ch !== cursor.ch) {
    return null;
  }

  var line = cursor.line;
  var token = editor.getTokenAt(cursor);
  var type = token.type;
  return type === 'variable' ? getLowerHint(editor, line, token)
    : type === 'variable-2' ? getUpperHint(editor, importEnd, line, token)
      : type === 'keyword' ? getKeywordHint(editor, importEnd, line, token)
        : type === 'def' ? getDefHint(token.string)
          : null;
}

function getLowerHint(editor, line, token) {
  return getPrefix(editor, line, token) + token.string;
}

function getUpperHint(editor, importEnd, line, token) {
  var name = getPrefix(editor, line, token) + token.string + getPostfix(editor, line, token);
  if (line < importEnd) {
    var content = editor.getLine(line);
    if (!/^import\b/.test(content)) return name;
    var i1 = content.indexOf('as');
    var i2 = content.indexOf('exposing');
    if (i1 < 0 && i2 < 0) return 'module:' + name;
    if (i1 > 0 && token.end < i1) return 'module:' + name;
    if (i2 > 0 && token.end < i2) return 'module:' + name;
  }
  return name;
}

function getKeywordHint(editor, importEnd, line, token) {
  switch (token.string) {
    case '.':
      var next = getTokenAfter(editor, line, token);
      return next.type === 'variable' ? getLowerHint(editor, line, next)
        : next.type === 'variable-2' ? getUpperHint(editor, importEnd, line, next) : null;

    case 'type':
      return /^type\salias\b/.test(editor.getLine(line)) ? 'alias' : 'type';

    case 'as':
      return line < importEnd ? 'import' : 'as';

    default:
      return token.string;
  }
}

function getDefHint(name) {
  return name === 'init' || name === 'view' || name === 'update' || name === 'subscriptions'
    ? 'def:' + name
    : null;
}

function getPrefix(editor, line, token) {
  var dot = getTokenBefore(editor, line, token);
  if (dot.string !== '.') { return ''; }

  var qualifier = getTokenBefore(editor, line, dot);
  return qualifier.type === 'variable-2'
    ? getPrefix(editor, line, qualifier) + qualifier.string + '.'
    : '.';
}

function getPostfix(editor, line, token) {
  var dot = getTokenAfter(editor, line, token);
  if (dot.string !== '.') { return ''; }

  var next = getTokenAfter(editor, line, dot);
  return next.type === 'variable'
    ? '.' + next.string
    : next.type === 'variable-2'
      ? '.' + next.string + getPostfix(editor, line, next)
      : '.';
}

function getTokenBefore(editor, line, token) {
  return editor.getTokenAt({ line: line, ch: token.start });
}

function getTokenAfter(editor, line, token) {
  return editor.getTokenAt({ line: line, ch: token.end + 1 });
}


var debounce = function (func) {
  var token;
  return function () {
    var later = function () {
      token = null;
      func.apply(null, arguments);
    };
    cancelIdleCallback(token);
    token = requestIdleCallback(later);
  };
};

const _editors = {};

export class CodeTest extends HTMLElement {
  _source = null;
  _editor = null;
  constructor() {
    super()
  }

  connectedCallback() {
    this.init();
  }

  init() {
    // var sendChangeEvent = debounce((function () {
    //   var previous = this._source;
    //   this._source = this._editor.getValue();
    //   if (previous === this._source) return;
    //   this.dispatchEvent(new Event('change'));
    // }).bind(this));

    // var sendSaveEvent = debounce((function () {
    //   this.dispatchEvent(new Event('save'));
    // }).bind(this));

    // var sendHintEvent = (function () {
    //   this.dispatchEvent(new Event('hint'));
    // }).bind(this);

    this._editor = CodeMirror((elt => {
      this.appendChild(elt);
    }), {
      mode: "elm",
      lineNumbers: true,
      keyMap: "sublime",
      matchBrackets: true,
      autoCloseBrackets: true,
      styleActiveLine: true,
      theme: "dark",
      value: this._source,
      tabSize: 2,
      indentWithTabs: false,
      extraKeys: {
        "Tab": handleTab,
        "Shift-Tab": handleUntab,
        "Cmd-S": function (cm) { sendSaveEvent(); },
        "Ctrl-Enter": function (cm) { sendSaveEvent(); }
      }
    })
  }

  get source() {
    this._source = source;
  }
  set source(u) {

    this._source = u;
  }
}



export class CodeEditorV2 extends HTMLElement {

  _theme = 'light';
  _source = null;
  _id = null;
  _start = null;
  _end = null;
  _importEnd = 0;

  constructor() {
    super()
  }

  connectedCallback() { this.init(); }


  init() {
    var sendChangeEvent = debounce((function () {
      var previous = this._source;
      this._source = _editors[this.getAttribute("id")].getValue();
      if (previous === this._source) return;
      this.dispatchEvent(new Event('change'));
    }).bind(this));

    var sendSaveEvent = debounce((function () {
      this.dispatchEvent(new Event('save'));
    }).bind(this));

    var sendHintEvent = (function () {
      this.dispatchEvent(new Event('hint'));
    }).bind(this);

    _editors[this.getAttribute("id")] = CodeMirror((elt => {
      this.appendChild(elt, this)
    }), {
      mode: "elm",
      lineNumbers: true,
      keyMap: "sublime",
      matchBrackets: true,
      autoCloseBrackets: true,
      styleActiveLine: true,
      theme: this._theme,
      value: this._source,
      tabSize: 2,
      indentWithTabs: false,
      extraKeys: {
        "Tab": handleTab,
        "Shift-Tab": handleUntab,
        "Cmd-S": function (cm) { sendSaveEvent(); },
        "Ctrl-Enter": function (cm) { sendSaveEvent(); }
      }
    })
    _editors[this.getAttribute("id")].on('changes', sendChangeEvent);
    // _editors[this.getAttribute("id")].focus();
    requestIdleCallback((function () {
      // Make sure Elm is ready to receive messages.
      _editors[this.getAttribute("id")].on('cursorActivity', sendHintEvent)
    }).bind(this));

    this._updateSource();
    this._updateCursor();
  }

  _updateSource() {
    if (!_editors[this.getAttribute("id")]) return;

    _editors[this.getAttribute("id")].setValue(this._source);
  }

  _updateTheme() {
    if (!_editors[this.getAttribute("id")]) return;

    _editors[this.getAttribute("id")].setOption('theme', this._theme);
  }

  _updateCursor() {
    if (!_editors[this.getAttribute("id")]) return;

    var isStartNull = isPositionNull(this._start);
    var isEndNull = isPositionNull(this._end);

    if (!(isStartNull && isEndNull)) {
      var start_ = isStartNull ? this._end : this._start;
      var end_ = isEndNull ? this._start : this._end;
      var start = { line: start_.line - 1, ch: start_.column - 1 };
      var end = { line: end_.line - 1, ch: end_.column - 1 }
      _editors[this.getAttribute("id")].setSelection(start, end, { scroll: false });
      _editors[this.getAttribute("id")].scrollIntoView({ from: start, to: end }, 200);
      _editors[this.getAttribute("id")].focus();
      this._start = null;
      this._end = null;
    }
  }





  // PROPERTY: SOURCE

  get source() {
    return this._source;
  }

  set source(updated) {
    var oldSource = this._source;
    this._source = updated;

    if (updated !== oldSource) {
      this._updateSource();
    }
  }


  // PROPERTY: THEME

  get theme() {
    return this._theme;
  }
  set theme(updated) {
    var oldTheme = this._theme;
    this._theme = updated;

    if (updated !== oldTheme) {
      this._updateTheme();
    }
  }


  // PROPERTY: CURSOR

  get selection() {
    return { start: this._start, end: this._end };
  }
  set selection(updated) {
    var oldStart = this._start;
    var oldEnd = this._end;
    this._start = updated.start;
    this._end = updated.end;

    var isSame = isPositionEqual(updated.start, oldStart) && isPositionEqual(updated.end, oldEnd);
    if (!isSame) { this._updateCursor(); }
  }


  // PROPERTY: IMPORT END

  get importEnd() {
    return this._importEnd;
  }
  set importEnd(updated) {
    this._importEnd = updated;
  }


  // PROPERTY: HINT

  get hint() {
    if (!_editors[this.getAttribute("id")]) return null;

    return getHint(_editors[this.getAttribute("id")], this._importEnd);
  }


}

(function () {

  // POLYFILL

  window.requestIdleCallback =
    window.requestIdleCallback ||
    function (cb) {
      var start = Date.now();
      return setTimeout(function () {
        cb({
          didTimeout: false,
          timeRemaining: function () {
            return Math.max(0, 50 - (Date.now() - start));
          }
        });
      }, 1);
    }

  window.cancelIdleCallback =
    window.cancelIdleCallback ||
    function (id) {
      clearTimeout(id);
    }

  window.customElements.define('code-editor', CodeEditorV2);
})()


  // DEBOUNCER




  // EDITOR

//   function CodeEditor() {
//     this._editor = null;
//     this._theme = 'light';
//     this._source = null;
//     this._start = null;
//     this._end = null;
//     this._importEnd = 0;

//     this._init = this._init.bind(this);
//     this._updateTheme = this._updateTheme.bind(this);
//     this._updateSource = this._updateSource.bind(this);
//     this._updateCursor = this._updateCursor.bind(this);

//     return Reflect.construct(HTMLElement, [], this.constructor);
//   }

//   CodeEditor.prototype = Object.create(HTMLElement.prototype, {
//     constructor: {
//       value: CodeEditor
//     },

//     connectedCallback: {
//       value: function () {
//         this._init();
//       }
//     },

//     disconnectedCallback: {
//       value: function () {
//         this._editor = null;
//         this._theme = 'dark';
//         this._source = null;
//         this._start = null;
//         this._end = null;
//         this._importEnd = 0;
//       }
//     },


//     // INIT EDITOR

//     _init: {
//       value: function () {

//         var sendChangeEvent = debounce((function () {
//           var previous = this._source;
//           this._source = _editors[this.getAttribute("id")].getValue();
//           if (previous === this._source) return;
//           this.dispatchEvent(new Event('change'));
//         }).bind(this));

//         var sendSaveEvent = debounce((function () {
//           this.dispatchEvent(new Event('save'));
//         }).bind(this));

//         var sendHintEvent = (function () {
//           this.dispatchEvent(new Event('hint'));
//         }).bind(this);

//         this._editor = CodeMirror(this, {
//           mode: "elm",
//           lineNumbers: true,
//           keyMap: "sublime",
//           matchBrackets: true,
//           autoCloseBrackets: true,
//           styleActiveLine: true,
//           theme: this._theme,
//           value: this._source,
//           tabSize: 2,
//           indentWithTabs: false,
//           extraKeys: {
//             "Tab": handleTab,
//             "Shift-Tab": handleUntab,
//             "Cmd-S": function (cm) { sendSaveEvent(); },
//             "Ctrl-Enter": function (cm) { sendSaveEvent(); }
//           }
//         });

//         _editors[this.getAttribute("id")].on('changes', sendChangeEvent);
//         _editors[this.getAttribute("id")].focus();
//         requestIdleCallback((function () {
//           // Make sure Elm is ready to receive messages.
//           _editors[this.getAttribute("id")].on('cursorActivity', sendHintEvent)
//         }).bind(this));

//         this._updateSource();
//         this._updateCursor();
//       }
//     },


//     // UPDATE EDITOR

//     _updateSource: {
//       value: function () {
//         if (!this._editor) return;

//         _editors[this.getAttribute("id")].setValue(this._source);
//       }
//     },

//     _updateTheme: {
//       value: function () {
//         if (!this._editor) return;

//         _editors[this.getAttribute("id")].setOption('theme', this._theme);
//       }
//     },

//     _updateCursor: {
//       value: function () {
//         if (!this._editor) return;

//         var isStartNull = isPositionNull(this._start);
//         var isEndNull = isPositionNull(this._end);

//         if (!(isStartNull && isEndNull)) {
//           var start_ = isStartNull ? this._end : this._start;
//           var end_ = isEndNull ? this._start : this._end;
//           var start = { line: start_.line - 1, ch: start_.column - 1 };
//           var end = { line: end_.line - 1, ch: end_.column - 1 }
//           _editors[this.getAttribute("id")].setSelection(start, end, { scroll: false });
//           _editors[this.getAttribute("id")].scrollIntoView({ from: start, to: end }, 200);
//           _editors[this.getAttribute("id")].focus();
//           this._start = null;
//           this._end = null;
//         }
//       }
//     },


//     // PROPERTY: SOURCE

//     source: {
//       get: function () {
//         return this._source;
//       },
//       set: function (updated) {
//         var oldSource = this._source;
//         this._source = updated;

//         if (updated !== oldSource) {
//           this._updateSource();
//         }
//       }
//     },


//     // PROPERTY: THEME

//     theme: {
//       get: function () {
//         return this._theme;
//       },
//       set: function (updated) {
//         var oldTheme = this._theme;
//         this._theme = updated;

//         if (updated !== oldTheme) {
//           this._updateTheme();
//         }
//       }
//     },


//     // PROPERTY: CURSOR

//     selection: {
//       get: function () {
//         return { start: this._start, end: this._end };
//       },
//       set: function (updated) {
//         var oldStart = this._start;
//         var oldEnd = this._end;
//         this._start = updated.start;
//         this._end = updated.end;

//         var isSame = isPositionEqual(updated.start, oldStart) && isPositionEqual(updated.end, oldEnd);
//         if (!isSame) { this._updateCursor(); }
//       }
//     },


//     // PROPERTY: IMPORT END

//     importEnd: {
//       get: function () {
//         return this._importEnd;
//       },
//       set: function (updated) {
//         this._importEnd = updated;
//       }
//     },


//     // PROPERTY: HINT

//     hint: {
//       get: function () {
//         if (!this._editor) return null;

//         return getHint(this._editor, this._importEnd);
//       }
//     }

//   });

//   // HELPERS

//   window.customElements.define('code-editor', CodeEditor);

// })();
