// Import Tiptap and Starter Kit
import { Editor } from '@tiptap/core';
import { StarterKit } from '@tiptap/starter-kit';

// Create a Web Component class that extends HTMLElement
export class TiptapEditor extends HTMLElement {
    editorContainer: HTMLDivElement;
    editor: Editor;
    constructor() {
        super();

        // Attach a shadow DOM to the element
        this.attachShadow({ mode: 'open' });
    }

    connectedCallback() {
        // Create a container for Tiptap inside the shadow DOM
        this.editorContainer = document.createElement('div');
        this.shadowRoot?.appendChild(this.editorContainer);

        // Initialize Tiptap editor when the element is connected to the DOM
        this.editor = new Editor({
            element: this.editorContainer,
            extensions: [StarterKit],
            content: this.getAttribute('content') || '', // Initial content from the attribute or empty
        });
    }

    disconnectedCallback() {
        // Clean up when the component is removed from the DOM
        if (this.editor) {
            this.editor.destroy();
        }
    }

    // Method to get the content from the editor
    get content() {
        return this.editor.getJSON();
    }

    // Method to set the content in the editor
    set content(value) {
        this.editor.commands.setContent(value);
    }
}

// Define the custom element
