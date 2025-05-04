Start
  = _ p:Program _ {
    return eval(p);
  }


Program
  = vars:(VariableDeclaration _ ";" _)* e:Expression {
    if(vars.length === 0) return e;
    const varsCode = vars.reduce((acc, x) => `${acc}${x[0]}; `, "");
    const returnCode = `return ${e};`;
    return `(() => { ${varsCode}${returnCode} })()`;
  }

VariableDeclaration
  = "entjero" __ name:Identifier _ "=" _ value:Expression {
    return `const ${name} = ${value}`;
  }

Expression = OrExpression

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
    return tail===null ? head: `(${head}) ${tail[1]} (${tail[3]})`;
  }
RelatExpression
  = head:AddExpression tail:(_ RelatOperator _ AddExpression)? {
    return tail===null ? head: `(${head}) ${tail[1]} (${tail[3]})`;
  }
AddExpression
  = head:MultiExpression tail:(_ AddOperator _ MultiExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }
MultiExpression
  = head:Term tail:(_ MultiOperator _ MultiExpression)* {
    return tail.reduce((acc, x) => `(${acc}) ${x[1]} (${x[3]})`, head);
  }

// 演算子定義
OrOperator = "aux" / "||"
AndOperator = "kaj" / "&&"
EqualOperator = "==" / "!="
RelatOperator = ">=" / ">" / "<=" / "<"
AddOperator = "+" / "-"
MultiOperator = "*" / "/" / "%"

// 項
Term = Number / Identifier

// 数
Number = Integer / Float

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
  = ("vera"/"falsa") !IdentifierContinue {
    return text();
  }

// 変数名
Identifier
  = head:IdentifierStart tail:IdentifierContinue* {
    return "$" + text();
  }

// 予約語
ReservedWord = ("entjero"/"vera"/"falsa"/"kaj"/"aux") !IdentifierContinue
// 変数名の先頭文字
IdentifierStart = [A-Za-z_]
// 変数名の後続文字
IdentifierContinue = [0-9A-Za-z_]

__ = [ \t\n\r]+
_ = [ \t\n\r]*
