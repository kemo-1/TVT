import { main } from './src/kemotvt.gleam'
import { TiptapEditor } from './src/editor/index'
document.addEventListener("DOMContentLoaded", () => {
    const dispatch = main({});

});
customElements.define('tiptap-editor', TiptapEditor);