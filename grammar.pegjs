start
  = _ statements:statementList _ {
    return {
      type: "program",
      body: statements
    };
  }

statementList
  = head:statement tail:(_ statement)* {
    return [head, ...tail.map(t => t[1])];
  }

statement = variableDeclaration / printStatement

variableDeclaration
  = "entjero" __ name:identifier _ "=" _ value:expression _ ";" {
    return {
      type: "varDecl", name, value
    };
  }

printStatement
  = "vidigi" _ "(" _ value:expression _ ")" _ ";" {
    return {
      type: "print", value
    };
  }

expression
  = head:term tail:(_ "+" _ expression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }

// 項
term = number / identifier

// 整数値
number
  = n:[0-9]+ {
    return {
      type: "number",
      value: parseInt(n.join(""), 10)
    };
  }

// 変数名
identifier
  = head:IdentifierStart tail:IdentifierContinue* {
    return {
      type: "identifier",
      name: [head, ...tail].join("")
    };
  }

// 変数名の先頭文字
IdentifierStart = [A-Za-z_]
// 変数名の後続文字
IdentifierContinue = [0-9A-Za-z_]

__ = [ \t\n\r]+
_ = [ \t\n\r]*
