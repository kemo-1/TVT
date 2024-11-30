import gleam from "vite-gleam";

import { VitePWA } from 'vite-plugin-pwa'


export default {
    plugins: [gleam(), VitePWA({
        workbox: {
            globPatterns: ['**/*.{js,css,html,ico,png,svg}']
        }, injectRegister: 'script-defer', registerType: 'autoUpdate'
    })
    ],
    build: {
        rollupOptions: {
            input: 'index.html',
            output: {
                dir: './dist',
                entryFileNames: 'assets/gleam_vite.js',
            }
        }
    }
}