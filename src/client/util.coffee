HTMLElement::hide = -> @style.display = "none"
HTMLElement::empty= ->
  while @firstChild
    @firstChild.remove()
HTMLElement::addClass = (classname)-> @className += " " + classname
HTMLElement::removeClass = (classname)-> @className = @className.replace(new RegExp '(\\s|^)'+classname+'(\\s|$)', "")

Object.values = (o)->
  ret = []
  i = 0
  for k,v of o
    ret[i] = v
    i++
  ret
