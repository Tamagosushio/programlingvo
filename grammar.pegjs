Start
  = _ p:Program _ {
    const prettier = require("prettier");
    prettier.format(p, {parser:"babel"}).then((code) => {
      console.log(code);
    });
    return eval(p);
  }

Program
  = _ stmts:(
      s:StatementEndsWithBlock _ {return s;}
    / s:CommentStatement _ {return s;}
    / s:StatementNeedsSemicolon _ ";" _ {
        if(s == null) return null;
        else return `${s};`;
      }
    )* e:Expression? _ {
      const code = stmts.filter(s => s != null).join("\n");
      const returnCode = e ? `return (${e});` : "";
      return `(() => {\n${code}${returnCode}\n})()`;
    }

Block
  = "{" _ stmts:(
      s:StatementEndsWithBlock _ {return s;}
    / s:CommentStatement _ {return s;}
    / s:StatementNeedsSemicolon _ ";" _ {
        if(s == null) return null;
        else return `${s};`;
      }
    )* _ "}" {
      const code = stmts.filter(s => s != null).join("\n");
      return `{\n${code}\n}`;
    }

StatementNeedsSemicolon
  = DoWhileStatement / VariableDeclaration / ReturnStatement / ContinueStatement / BreakStatement / Expression
StatementEndsWithBlock
  = Block / IfThenElseStatement / ForStatement / WhileStatement

CommentStatement
  = "//" content:(![\n\r] .)* {
    return null;
  }
IfThenElseStatement
  = "se" _ "("_ e:Expression _")" _ "tiam" _ trueBody:Block _ "alie" _ falseBody:Block {
    return `if(${e})${trueBody}else${falseBody}`;
  }
ForStatement
  = "por" _ "(" _ init:(VariableDeclaration / Expression)? _ ";" _ cond:Expression? _ ";" _ update:Expression? _ ")" _ body:(
      b:Block {return b;}
      / s:StatementNeedsSemicolon _ ";" _ {return s;}
    ) {
    let bodyCode;
    if(typeof(body) === "string" && body.trim().startsWith("{") && body.trim().endsWith("}")){
      bodyCode = body;
    }else if(body == null){
      bodyCode = `{}`;
    }else{
      bodyCode = `{ ${body}; }`;
    }
    return `for (${init ?? ""}; ${cond ?? ""}; ${update ?? ""}) ${bodyCode}`;
  }
WhileStatement
  = "dum" _ "(" _ cond:Expression _ ")" _ body:(
      b:Block {return b;}
      / s:StatementNeedsSemicolon _ ";" _ {return s;}
    ) {
    let bodyCode;
    if(typeof(body) === "string" && body.trim().startsWith("{") && body.trim().endsWith("}")){
      bodyCode = body;
    }else if(body == null){
      bodyCode = `{}`;
    }else{
      bodyCode = `{ ${body}; }`;
    }
    return `while (${cond}) ${bodyCode}`;    
  }
DoWhileStatement
  = "fari" _ body:Block _ "dum" _ "(" _ cond:Expression _ ")" {
    return `do ${body} while(${cond})`;
  }
ReturnStatement
  = "redonas" __ e:Expression {
    return `return ${e}`;
  }
ContinueStatement
  = "dauxrigas" {
    return `continue`;
  }
BreakStatement
  = "rompas" {
    return "break";
  }
VariableDeclaration
  = "var" __ name:Identifier _ "=" _ value:Expression {
    return `let ${name} = ${value}`;
  }

Expression = LambdaExpression / AssignmentExpression / OrExpression

AssignmentExpression
  = name:MemberExpression _ op:AssignmentOperator _ value:Expression {
    return `${name} ${op} ${value}`;
  }
AssignmentOperator
  = "=" / "*=" / "/=" / "%=" / "+=" / "-="

LambdaExpression
  = i:Identifier? _ "@" _ body:(Block / Expression) {
    return `${i ?? "()"} => ${body}`;
  }

OrExpression
  = head:AndExpression tail:(_ OrOperator _ AndExpression)* {
    return tail.reduce((acc, x) => `(${acc}) || (${x[3]})`, head);
  }
AndExpression
  = head:BitExpression tail:(_ AndOperator _ BitExpression)* {
    return tail.reduce((acc, x) => `(${acc}) && (${x[3]})`, head);
  }
BitExpression
  = head:EqualExpression tail:(_ BitOperator _ EqualExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
EqualExpression
  = head:RelatExpression tail:(_ EqualOperator _ RelatExpression)? {
    return tail === null ? head : `(${head}) ${tail[1]} (${tail[3]})`;
  }
RelatExpression
  = head:ShiftExpression tail:(_ RelatOperator _ ShiftExpression)? {
    return tail === null ? head : `(${head}) ${tail[1]} (${tail[3]})`;
  }
ShiftExpression
  = head:AddExpression tail:(_ ShiftOperator _ AddExpression)? {
    return tail === null ? head : `(${head}) ${tail[1]} (${tail[3]})`;
  }
AddExpression
  = head:MultiExpression tail:(_ AddOperator _ MultiExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
MultiExpression
  = head:NotExpression tail:(_ MultiOperator _ NotExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
NotExpression
  = ops:(NotOperator _)* e:UpdateExpression? {
    return ops.reduceRight((acc, op) => `(${op[0]}${acc})`, e);
  }
UpdateExpression
  = i:CallExpression _ op:UpdateOperator? {return `${i}${op ?? ""}`;}
  / op:UpdateOperator? _ i:CallExpression {return `${op ?? ""}${i}`;}
CallExpression
  = callee:MemberExpression tail:(_ Argument)* {
    if(callee === "$vidigas") return `console.log${tail.map(x => x[1]).join("")}`;
    else if(callee === "$enigas") return `require("readline-sync").question${tail.map(x => x[1]).join("")}`;
    else if(callee === "$analizasDecimalon") return `parseFloat${tail.map(x => x[1]).join("")}`;
    return tail.reduce((acc, x) => `${acc}${x[1]}`, callee);
  }
MemberExpression
  = base:Term tail:(_ MemberAccess)* {
    return tail.reduce((acc, x) => `${acc}${x[1]}`, base);
  }

MemberAccess
  = "." idx:[0-9]+ {
    return `[${idx.join("")}]`;
  } / "[" _ idx:Expression _ "]" {
    return `[${idx}]`;
  }
Argument
  = "(" _ e:Expression? _ ")" {
    return `(${e ?? ""})`;
  }

// 演算子定義
OrOperator = "aux" / "||"
AndOperator = "kaj" / "&&"
BitOperator = "&" / "^" / "|"
EqualOperator = "==" / "!="
RelatOperator = ">=" / ">" / "<=" / "<"
ShiftOperator = ">>>" / ">>" / "<<"
AddOperator = "+" / "-"
MultiOperator = "*" / "/" / "%"
UpdateOperator = "++" / "--"
NotOperator = "ne" / "!" / "~"

// 項
Term
  = Paren / String / SignedNumber / Boolean / Undefined / Null / IfThenElseTerm / ArrayLiteral / Identifier

ArrayLiteral
  = "[" _ elements:(Expression (_ "," _ Expression)*)? _ ","? _ "]" {
    const allElements = elements
      ? [elements[0], ...(elements[1].map(x => x[3]))]
      : [];
    return `[${allElements.join(", ")}]`;
  }

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
SignedNumber
  = sign:("+" / "-")? num:Number {
    return `${sign ?? ""}${num}`;
  }
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
  = ("var" / "nedifinito" / "nulo" / "vero" / "malvero" / "ne" / "kaj" / "aux" / "se" / "tiam" / "alie" / "por" / "dum" / "fari") !IdentifierContinue
// 変数名の先頭文字
IdentifierStart = [A-Za-z_]
// 変数名の後続文字
IdentifierContinue = [0-9A-Za-z_]

__ = [ \t\n\r]+
_  = [ \t\n\r]*
