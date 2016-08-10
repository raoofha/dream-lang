compiler = require "./compiler"
fs = require "fs"
beautify = require('js-beautify').js_beautify

source = fs.readFileSync "./src/compiler.dream", "utf8"


global.range = (n)-> [0...n]
global.js = global
String::forEach = (f)->
  for ch in @
    f ch

# msource  = "(function (module,exports,window,js){"
# msource += compiler.compile source,{module: true}
# msource += "})(module,module.exports,undefined,global);"
# eval msource
# compiler_dream = module.exports
# console.log beautify compiler_dream.compile source

switch process.argv[2]
  when "1"
    fs.writeFileSync "./dist/c.js", beautify compiler.compile source, {module: true}

    dreamCompiler = require "./c"
    code1 = dreamCompiler.compile source, {module: true}
    console.log beautify code1
  when "2"
    fs.writeFileSync "./dist/c.js", beautify compiler.compile source, {module: true}

    dreamCompiler = require "./c"
    code2 = dreamCompiler.compile source, {module: true}
    b = beautify code2
    fs.writeFileSync "./dist/c2.js", b
    console.log code1 is code2
    console.log code1.length, code2.length
  when "3"
    code1 = compiler.compile source, {module: true}
    fs.writeFileSync "./dist/c.js", code1
    dreamCompiler = require "./c"
    code2 = dreamCompiler.compile source, {module: true}
    #fs.writeFileSync "./dist/c2.js", source2
    console.log code1 is code2
    console.log code1.length, code2.length
    #console.log beautify(source) is beautify(source2)
  else
    console.log beautify(compiler.compile source,{module: true})
