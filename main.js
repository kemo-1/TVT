import { main } from './src/kemotvt.gleam'
import { MyComponent } from './src/editor/index'
document.addEventListener("DOMContentLoaded", () => {
    const dispatch = main({});
    customElements.define('my-component', MyComponent);
}); 