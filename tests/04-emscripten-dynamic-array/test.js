const moduleFactory =
    typeof require === "function"
        ? require("./main.js")
        : createModule;

async function main() {
    const wasm = await moduleFactory();

    // ===== Integer Array Tests =====
    console.log("=== Integer Array Tests ===");

    const numPushSuccess = wasm.ccall(
        "testNumArray",
        "number",
        [],
        []
    );

    console.log("Push success:", numPushSuccess === 1);

    const numLength = wasm.ccall(
        "getNumLength",
        "number",
        [],
        []
    );

    console.log("Length:", numLength);

    for (let i = 0; i < numLength; i++) {
        const element = wasm.ccall(
            "getNum",
            "number",
            ["number"],
            [i]
        );

        console.log(`Element ${i}:`, element);
    }

    const numFreeSuccess = wasm.ccall(
        "testNumFreeMemory",
        "number",
        [],
        []
    );

    console.log("Free memory:", numFreeSuccess === 1);

    // ===== String Array Tests =====
    console.log("\n=== String Array Tests ===");

    const stringPushSuccess = wasm.ccall(
        "testStringArray",
        "number",
        [],
        []
    );

    console.log("Push success:", stringPushSuccess === 1);

    const stringLength = wasm.ccall(
        "getStringLength",
        "number",
        [],
        []
    );

    console.log("Length:", stringLength);

    for (let i = 0; i < stringLength; i++) {
        const element = wasm.ccall(
            "getString",
            "string",
            ["number"],
            [i]
        );

        console.log(`Element ${i}:`, element);
    }

    const stringFreeSuccess = wasm.ccall(
        "testStringFreeMemory",
        "number",
        [],
        []
    );

    console.log("Free memory:", stringFreeSuccess === 1);
}

main().catch(console.error);