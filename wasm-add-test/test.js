const fs = require("node:fs");

async function main() {
    // Read the compiled WebAssembly file
    const wasmBytes = fs.readFileSync("./test.wasm");

    // Instantiate the WebAssembly module
    const { instance } = await WebAssembly.instantiate(
        wasmBytes,
        {}
    );

    // Access the exported D function
    const { add } = instance.exports;

    // Call the D function from JavaScript
    const result = add(10, 20);

    console.log("10 + 20 =", result);
}

main().catch(console.error);