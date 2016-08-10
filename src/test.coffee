compiler = require "./compiler"
fs = require "fs"
beautify = require('js-beautify').js_beautify

code = fs.readFileSync "./src/compiler.dream", "utf8"


global.range = (n)-> [0...n]
global.js = global
String::forEach = (f)->
  for ch in @
    f ch

# mcode  = "(function (module,exports,window,js){"
# mcode += compiler.compile code,{module: true}
# mcode += "})(module,module.exports,undefined,global);"
# eval mcode
# compiler_dream = module.exports
# console.log beautify compiler_dream.compile code

switch process.argv[2]
  when "1"
    fs.writeFileSync "./dist/c.js", beautify compiler.compile code, {module: true}

    dreamCompiler = require "./c"
    code2 = dreamCompiler.compile code
    console.log beautify code2
  else
    console.log beautify(compiler.compile code,{module: true})
