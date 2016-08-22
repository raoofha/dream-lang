dream : yet another js transpiler
----------------------------------------------
it can compile itself but not much to expect from **v0.0.0**

**dream** is a small language between clojurescript and coffeescript
```
def hello(name)
  console.log "hello" name
# or
def hello(name) (console.log "hello" name)
# ------------------------------------------
if true
  (foo)
else
  (bar)
# or
(if true (foo) (bar))
# ------------------------------------------
switch node.value
  "String" (stringNode)
  "Keyword" "Bool"
    js.JSON.stringify node.value
  else
    (callNode)
# or
(switch node.value
  "String" (stringNode)
  ("Keyword" "Bool") (js.JSON.stringify node.value)
  (callNode))
# ------------------------------------------
set! i 0
while (< i node.value.length)
  (foo)
  if (bar)
    break
  += i 1
# ------------------------------------------ 
# comments begins with a # and a space
#!this is
  a block
  comment
# ------------------------------------------
set! node.value (node.value.replace #"\\"g "\\\\")
# or
set! node.value (node.value.replace #re"\\\\"g "\\\\")
```
todo
------
- test
- special syntax for require
- infix operator
- deconstructor
- default parameters
- macros
- editors tools
- optional typing
```
def- foo : String? (arg1 : Number? arg2 : Any) 
```
- ...
