
compiler = require "./compiler"
fs = require "fs"
beautify = require('js-beautify').js_beautify

code = fs.readFileSync "./src/compiler.dream", "utf8"

#console.log JSON.stringify (compiler.parse code), null, 4
console.log beautify(compiler.compile code)
