
const parser = require("./parser");

const code = `
entjero x = 10;
entjero y = 20;
funkcio duobligi = a => b => a*10 + b%2 + a*b;
entjero hasilo = duobligi(x)(y);
hasilo
`

const ast = parser.parse(code);
console.dir(ast, {depth: null});

