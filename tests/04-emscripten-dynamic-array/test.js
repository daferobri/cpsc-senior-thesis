const moduleFactory =
    typeof require === "function"
        ? require("./main.js")
        : createModule;

function assertEqual(actual, expected, label) {
    if (actual !== expected) {
        throw new Error(`${label}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
    }
}

async function main() {
    const wasm = await moduleFactory();
    const call = (name, resultType = "number", args = []) =>
        wasm.ccall(name, resultType, args.map(() => "number"), args);

    function checkInvalidIndices(getter, resultType, length, fallback) {
        // Negative index, index exactly at length, and a very large index.
        for (const index of [-1, length, 2147483647]) {
            assertEqual(call(getter, resultType, [index]), fallback,
                `${getter} rejects index ${index}`);
        }
    }

    // Run twice on the same module to verify reuse after freeing.
    for (let round = 1; round <= 2; round++) {
        assertEqual(call("getNumLength"), 0, "integer array starts empty");
        checkInvalidIndices("getNum", "number", 0, -1);
        assertEqual(call("testNumFreeMemory"), 1, "free empty integer array");
        assertEqual(call("testNumArray"), 1, "integer container edge cases and append");
        assertEqual(call("getNumLength"), 99, "integer length after append");
        for (let i = 0; i < 99; i++) {
            assertEqual(call("getNum", "number", [i]), i + 1,
                `integer element ${i} survives resizing`);
        }
        checkInvalidIndices("getNum", "number", 99, -1);
        assertEqual(call("getNumLength"), 99, "invalid reads preserve integer length");
        assertEqual(call("testNumFreeMemory"), 1, "free integer array");
        assertEqual(call("testNumFreeMemory"), 1, "free integer array twice");
        assertEqual(call("getNumLength"), 0, "integer length after free");
        checkInvalidIndices("getNum", "number", 0, -1);

        assertEqual(call("getStringLength"), 0, "string array starts empty");
        checkInvalidIndices("getString", "string", 0, "");
        assertEqual(call("testStringFreeMemory"), 1, "free empty string array");
        assertEqual(call("testStringArray"), 1, "string container edge cases and append");
        assertEqual(call("getStringLength"), 99, "string length after append");
        for (let i = 0; i < 99; i++) {
            assertEqual(call("getString", "string", [i]), "Hello",
                `string element ${i} survives resizing`);
        }
        checkInvalidIndices("getString", "string", 99, "");
        assertEqual(call("getStringLength"), 99, "invalid reads preserve string length");
        assertEqual(call("testStringFreeMemory"), 1, "free string array");
        assertEqual(call("testStringFreeMemory"), 1, "free string array twice");
        assertEqual(call("getStringLength"), 0, "string length after free");
        checkInvalidIndices("getString", "string", 0, "");

        console.log(`PASS: dynamic array round ${round}`);
    }
    console.log("PASS: all dynamic array tests");
}

main().catch((error) => {
    console.error(error);
    if (typeof process !== "undefined") {
        process.exitCode = 1;
    } else {
        // Surface failures as an uncaught error in the browser.
        setTimeout(() => { throw error; }, 0);
    }
});
