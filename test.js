
const parser = require("./parser");

const code = `
entjero a = 10;
entjero b = 20;
vidigi(a + b);
vidigi(a+5);
vidigi(1+2);
vidigi(a);
vidigi(67);
`

console.log("purse!");
const ast = parser.parse(code);
console.dir(ast, {depth: null});

