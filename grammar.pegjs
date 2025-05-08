Start
  = _ p:Program _ {
    const prettier = require("prettier");
    prettier.format(p, {parser:"babel"}).then((code) => {
      console.log(code);
    });
    return eval(p);
  }

Program
  = statements:(Statement _ ";" _)* e:Expression? _ {
    // console.log("statements: ", statements);
    // console.log("return: ", e);
    const code = statements.reduce((acc, x) => `${acc} ${x[0]};\n`, "");
    const returnCode = e ? `return (${e});` : "";
    return `(() => {\n${code}${returnCode}\n})()`;
  }

Statement = Block / IfThenElseStatement / ForStatement / WhileStatement / DoWhileStatement / VariableDeclaration / Expression

Block
  = "{" _ stmts:(Statement _ ";" _)* _ "}" {
    return `{\n${stmts.map(s => s[0]).join(";\n")};\n}`;
  }

IfThenElseStatement
  = "se" _ "("_ e:Expression _")" _ "tiam" _ trueBody:Statement _ "alie" _ falseBody:Statement {
    return `if(${e})${trueBody}else${falseBody}`;
  }
ForStatement
  = "por" _ "(" _ init:(Expression / VariableDeclaration)? _ ";" _ cond:Expression? _ ";" _ update:Expression? _ ")" _ body:Statement {
    const initCode = init ?? "";
    const condCode = cond ?? "";
    const updateCode = update ?? "";
    return `for (${initCode}; ${condCode}; ${updateCode}) ${body}`;
  }
WhileStatement
  = "dum" _ "(" _ cond:Expression _ ")" _ body:Statement {
    return `while (${cond}) ${body}`;
  }
DoWhileStatement
  = "fari" _ body:Statement _ "dum" _ "(" _ cond:Expression _ ")" {
    return `do ${body} while(${cond})`;
  }

Expression = LambdaExpression / AssignmentExpression / OrExpression

VariableDeclaration
  = "var" __ name:Identifier _ "=" _ value:Expression {
    return `let ${name} = ${value}`;
  }
AssignmentExpression
  = name:Identifier _ "=" _ value:Expression {
    return `${name} = ${value}`;
  }

LambdaExpression
  = i:Identifier _ "@" _ e:Expression {
    return `${i} => ${e}`;
  }
OrExpression
  = head:AndExpression tail:(_ OrOperator _ AndExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
AndExpression
  = head:EqualExpression tail:(_ AndOperator _ EqualExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
EqualExpression
  = head:RelatExpression tail:(_ EqualOperator _ RelatExpression)? {
    return tail === null ? head : `(${head}) ${tail[1]} (${tail[3]})`;
  }
RelatExpression
  = head:AddExpression tail:(_ RelatOperator _ AddExpression)? {
    return tail === null ? head : `(${head}) ${tail[1]} (${tail[3]})`;
  }
AddExpression
  = head:MultiExpression tail:(_ AddOperator _ MultiExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
MultiExpression
  = head:CallExpression tail:(_ MultiOperator _ CallExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
CallExpression
  = callee:Term tail:(_ Argument)* {
    return tail.reduce((acc, x) => `${acc}${x[1]}`, callee);
  }

Argument
  = "(" _ e:Expression _ ")" {
    return `(${e})`;
  }

// 演算子定義
OrOperator = "aux" / "||"
AndOperator = "kaj" / "&&"
EqualOperator = "==" / "!="
RelatOperator = ">=" / ">" / "<=" / "<"
AddOperator = "+" / "-"
MultiOperator = "*" / "/" / "%"

// 項
Term
  = Paren / String / Number / Identifier / Boolean / Undefined / Null / IfThenElseTerm / Identifier


IfThenElseTerm
  = "se" __ a:Expression __ "tiam" __ b:Expression __ "alie" __  c:Expression {
    return `${a} ? ${b} : ${c}`;
  }

// 丸括弧
Paren
  = "(" _ e:Expression _ ")" {
    return `(${e})`;
  }

// 文字列
String
  = "\"" chars:Char* "\"" {
    return `"${chars.join("")}"`;
  }
// 文字
Char
  = EscapedChar / NormalChar
// エスケープ文字
EscapedChar
  = "\\" c:. {
    return "\\" + c;
  }
// 普通の文字
NormalChar
  = !["\\] . {
    return text();
  }

// 数
Number = Float / Integer
// 小数値
Float
  = Integer "." [0-9]+ {
    return text();
  }
// 整数値
Integer
  = [1-9] [0-9]* {
    return text();
  } / "0"

// 真偽値
Boolean
  = bool:("vero" / "malvero") !IdentifierContinue {
    return text()==="vero" ? "true" : "false";
  }

// undefined値
Undefined
  = "nedifinito" !IdentifierContinue{
    return "undefined";
  }

// null値
Null
  = "nulo" !IdentifierContinue{
    return "null";
  }

// 変数名
Identifier
  = !ReservedWord head:IdentifierStart tail:IdentifierContinue* {
    return "$" + text();
  }

// 予約語
ReservedWord
  = ("var" / "nedifinito" / "nulo" / "vero" / "malvero" / "kaj" / "aux" / "se" / "tiam" / "alie" / "por" / "dum" / "fari") !IdentifierContinue
// 変数名の先頭文字
IdentifierStart = [A-Za-z_]
// 変数名の後続文字
IdentifierContinue = [0-9A-Za-z_]

__ = [ \t\n\r]+
_  = [ \t\n\r]*
