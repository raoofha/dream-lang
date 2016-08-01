class Display
  constructor:-> @_subs = []
  subscribe: (f)-> @_subs.push f
  update: ->
    @_subs.forEach (sub)-> sub()
    $content = document.getElementById("content")
    $content.empty()
    $content.appendChild(main())
module.exports = new Display
