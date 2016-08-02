
lexer = require "./lexer"
fs = require "fs"

code = fs.readFileSync "./src/lexer.dream", "utf8"

console.log JSON.stringify (lexer.tokenize code), null, 4
