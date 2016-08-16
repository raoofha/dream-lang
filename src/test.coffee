compiler = require "./dream"
beautify = require('js-beautify').js_beautify

console.log beautify compiler.compile """
# s
a
  #!abcd
     azxcv
   azxcv
    zxcv
   zvzxcv
  #!abcd
  azxcv
   azxcv
    zxcv
   zvzxcv
b
c
d
"""
#console.log beautify compiler.compile """
#a
##! asdfsdf zczx zxzx
##! asdfsdf zczx zxzx
# zxzxcvcv
#   zvxcvx
#b
##!asdfsdf zczx zxzx
#  zxzxcvcv
#  zvxcvx
#"""
#console.log beautify compiler.compile """
#if (= (typeof node) "string")
#  set! rootnode (parse node)
#  set! csource (compile rootnode)
#  if (and opts opts.module)
#    set! defs (.map (rootnode.value.filter fn (n) (= (aget (aget n.value 0) :value) "def"))
#                    (fn (n) (mung (aget (aget n.value 1) :value))))
#    return (+ "module.exports = (function (window,global,js,console){" csource
#              "return {" (defs.join) "};})(undefined,undefined,global,console);")
#  else
#    return csource
#"""
#console.log beautify compiler.compile """
#switch ch
#  a b
#  c d
#  else e
#switch ch
#  a b
#  c d
#switch ch
#  a b
#  c d
#  else
#    switch ch
#      a b
#      c d
#      else
#        e
#"""
#console.log beautify compiler.compile """
#if aa
#  bb
#else
#  ll
#  
#"""
#console.log beautify compiler.compile """
#if aa
#  bb
#  cc
#else if dd
#  ee
#  ff
#else if gg
#  hh
#  ii
#else
#  jj
#  kk
#  ll
#  
#"""
#console.log beautify compiler.compile "+ 23 23"
# console.log beautify compiler.compile """
# if true
#   aa
#   bb
#   if false
#     cc
#     dd
#     ee
#   else if dd
#     ff
#     if gg
#       ii
#     else if ll
#       kk
#     else
#       mm
#     nn
#     if gg
#       ii
#     else if ll
#       kk
#     else
#       mm
#     nn
# else if pp
#   qq
#   qq
# else
#   ww
#   xx
# 
# if (= body.length 1)
#   set! body (aget body 0)
# else
#   set! body {:value (.concat [{:value "do" :type "Symbol"}] body) :type "Line"}
# if (= n.value.length 1)
#   set! n (aget n.value 0)
#   node.value.push n
# else if (> n.value.length 1)
#     set! n.type "List"
#     node.value.push n
# def- rewriteSwitch (node)
#   if (= node.type "Line")
#     if (= (aget (aget node.value 0) :value) "switch")
#       .forEach (node.value.splice 2)
#         fn(n i)
#           def j (n.value.findIndex fn (n) (= n.type "Line"))
#           def body (n.value.splice j)
#           if (= body.length 1)
#             set! body (aget body 0)
#           else
#             set! body {:value (.concat [{:value "do" :type "Symbol"}] body) :type "Line"}
#           if (= n.value.length 1)
#             set! n (aget n.value 0)
#             node.value.push n
#           else if (> n.value.length 1)
#               set! n.type "List"
#               node.value.push n
#           # else
#           #  set! n {:value n.value :type "List"}
#           node.value.push body
#     node.value.forEach fn(n) (rewriteSwitch n)
# switch node.type
#   # "Program" (programNode node opts)
#   "Symbol" (mung node.value)
#   "String" "Keyword" node.value
#   "Bool" "Nil" "Number" (js.JSON.stringify node.value)
#   "RegExp" (regNode node)
#   "Map" (mapNode node)
#   "Array" (arrayNode node)
#   "Comment" ""
# """
# console.log beautify compiler.compile """
# if (= (typeof node) "string")
#   set! rootnode (parse node)
#   set! csource (compile rootnode)
#   if (and opts opts.module)
#     set! defs (.map (rootnode.value.filter fn (n) (= (aget (aget n.value 0) :value) "def"))
#                     (fn (n) (mung (aget (aget n.value 1) :value))))
#     return (+ "module.exports = (function (window,global,js,console){" body
#               "return {" (defs.join) "};})(undefined,undefined,global,console);")
#   else
#     return csource
# + 323 23
# if true (console.log "yeh") (console.log "no")
# (if true (console.log "yeh") (console.log "no"))
# if q
#   try
#     console.log (dream.eval q)
#     console.log (dream.eval q)
#   catch e
#     console.log e.message
#     console.log e.message
# (try (console.log "asdf") (console.log "qwrr") (catch e (console.log e) (console.log e)) (finally (console.log "q")))
# try
#   console.log "abcd"
#   console.log "efgh"
#   throw "err"
# catch e
#   console.log e
# finally
#   console.log "efgh"
# 
# 
#   
# """
###
compiler = require "./dream"
fs = require "fs"
beautify = require('js-beautify').js_beautify

source = fs.readFileSync "./src/dream.dream", "utf8"
console.log beautify compiler.compile source, {module: true}
###

###
switch process.argv[2]
  when "1"
    c1 = compiler.compile source, {module: true}
    #fs.writeFileSync "./dist/dream.js", beautify compiler.compile source, {module: true}
    #dreamCompiler = require "./dream"
    dreamCompiler = eval "(function(module,exports,console,window,js){" + c1 + "})(module,module.exports,console,undefined,global);module.exports;"
    c2 = dreamCompiler.compile source, {module: true}
    if c1 is c2
      console.log "yeh"
    else
      console.log "oh no"
  when "2"
    #c1 = compiler.compile source, {module: true}
    dreamCompiler = require "../dist/dream"
    #dreamCompiler = eval "(function(module,exports){" + c1 + "})(module,module.exports);module.exports;"
    #console.log c1,dreamCompiler
    c2 = dreamCompiler.compile source, {module: true}
    console.log beautify c2
  else
    console.log beautify(compiler.compile source,{module: true})
###
