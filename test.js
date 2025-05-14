const fs = require("fs");
const parser = require("./parser");
const code = fs.readFileSync("./input.espr", "utf-8");

const tracer = {
  trace: (event) => {
    const {type, rule, location} = event;
    console.log(`${type} ${rule} at ${location.start.offset}`);
  },
};

try{
  const ast = parser.parse(code);
  console.dir(ast, {depth: null});
}catch(e){
  console.error(e.message);
}

