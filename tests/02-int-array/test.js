const fs = require("node:fs");

async function main() {
    const bytes = fs.readFileSync("./array.wasm");

    const { instance } = await WebAssembly.instantiate(bytes);

    const wasm = instance.exports;

    console.log("Test success:", wasm.testArray() === 1);
    console.log("Length:", wasm.getLength());

    for (let i = 0; i < wasm.getLength(); i++) {
        console.log(`Element ${i}:`, wasm.getElement(i));
    }
}

main().catch(console.error);