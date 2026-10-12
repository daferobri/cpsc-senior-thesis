const createModule = require("./array.js");

async function main() {
    const wasm = await createModule();

    const result = wasm.ccall(
        "testAllocation",
        "number",
        [],
        []
    );

    console.log("Result:", result);
}

main().catch(console.error);