app = {
    show:(msg)-> bootbox.alert(msg)
    error:(err)-> bootbox.alert("خطا: "+err)
    postSync: (url,data)->
        app.ajax({type:"post",url,async:false,data})
    getSync: (url,data)->
        app.ajax({type:"get",url,async:false,data})
    post:(url,data,cb)->
        app.ajax({type:"post",url,async:true,data},cb)
    ajax:({type,url,async,data},cb=->)->
        xhr = new XMLHttpRequest
        xhr.open(type, url, async)
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8")
        xhr.send(JSON.stringify(data))
        xhr.onload = (e)->
            loading.hide()
            if xhr.readyState is 4 and xhr.status is 200
                #cb(null,JSON.parse(xhr.responseText))
                r = JSON.parse(xhr.responseText)
                if r.error
                    #cb(r.error.toString(),null)
                    app.error(r.error.toString())
                else
                    cb(null,r)
                #cb(null,(xhr.responseText))
            else
                #cb("خطا در اتصال به سرور",JSON.parse(xhr.responseText))
                app.error("خطا در اتصال به سرور")
                #cb("خطا در اتصال به سرور",(xhr.responseText))
        xhr.onerror = (e)-> cb(e,xhr)
        xhr
}


