if not window.global
    modules = {}
    module = {exports:{}}
    process = {}
    window.global = window
    require = (m)->
        if m[0] is '.'
            u = m.substring(2)+".js"
            if modules[u]
                return modules[u]
            else
                str = "(function (module){"
                str += app.ajax({url: u , type:"get",async:false}).responseText
                str += "})(module)"
                eval(str)
                modules[u] = module.exports
        else
            if modules[m]
                return modules[m]
            else
                pack = JSON.parse app.ajax({url: "node_modules/#{m}/package.json" , type:"get",async:false}).responseText
                global.__dirname = "node_modules/"+m
                if not pack.main
                    pack.main = "index.js"
                else if pack.main.substring(pack.main.length-3) isnt ".js"
                    pack.main += ".js"
                str = "(function (module,exports,global){"
                str += app.ajax({url: "node_modules/#{m}/#{pack.main}" , type:"get",async:false}).responseText
                str += "})(module,module.exports,window)"
                eval(str)
                modules[u] = module.exports
