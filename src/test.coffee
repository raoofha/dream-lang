
compiler = require "./compiler"
fs = require "fs"
beautify = require('js-beautify').js_beautify

code = fs.readFileSync "./src/compiler.dream", "utf8"

#console.log JSON.stringify (compiler.parse code), null, 4
#console.log beautify(compiler.compile code,{module: true})

global.range = (n)-> [0...n]
global.js = global

# mcode  = "(function (module,exports,window,js){"
# mcode += compiler.compile code,{module: true}
# mcode += "})(module,module.exports,undefined,global);"
# eval mcode
# compiler_dream = module.exports
# console.log beautify compiler_dream.compile code

fs.writeFileSync "./dist/c.js", beautify compiler.compile code, {module: true}

dreamCompiler = require "./c"
code2 = dreamCompiler.compile code
console.log beautify code2
