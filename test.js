const fs = require('fs');
const parser = require("./parser");
const code = fs.readFileSync("./input.espr", "utf-8");

console.log(code);
const ast = parser.parse(code);
console.dir(ast, {depth: null});

