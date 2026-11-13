const assert = require("node:assert/strict");
const createModule = require("./aa.js");

const cases = [
    "empty map and unchanged output on a miss",
    "insert, lookup, and update without increasing length",
    "zero, negative keys, and integer limits",
    "collisions and wraparound",
    "growth preserves entries and updates",
    "freeMemory is repeatable and the map can be reused",
];

const tests = ["linear", "quadratic"].flatMap(kind =>
    cases.map(name => `${kind}: ${name}`)
);

async function main() {
    const wasm = await createModule();
    let failures = 0;

    for (const [id, name] of tests.entries()) {
        try {
            const line = wasm.ccall("testInsertAndFind", "number", ["number"], [id]);
            assert.equal(line, 0, `D check failed at test.d:${line}`);
            console.log(`PASS: ${name}`);
        } catch (error) {
            failures++;
            console.error(`FAIL: ${name}\n${error.stack || error}`);
        }
    }

    console.log(`${tests.length - failures}/${tests.length} tests passed`);
    if (failures) process.exitCode = 1;
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
