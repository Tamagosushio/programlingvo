
const parser = require("./parser");

const code = `
entjero a = 10;
entjero b = 20;
b
`

console.log("purse!");
const ast = parser.parse(code);
console.dir(ast, {depth: null});

