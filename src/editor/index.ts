// Define the custom element
export class MyComponent extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: 'open' }); // Shadow DOM for encapsulation
    }

    connectedCallback() {
        // Create a div element with text
        const div = document.createElement('div');
        div.textContent = 'Hello, this is a custom web component!';
        this.shadowRoot?.appendChild(div);
    }
}

// Register the custom element
