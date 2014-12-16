#encoding: utf-8
window.Sinatra=
  selfAjax: (type, url, dom) ->
    $.ajax(
      type: type 
      url: url
      success: (data) ->
        $(dom).remove() if $.trim(dom).length
      error: ->
        alert("error - with ajax!")
    )
  operateWithAjax: (operate, url, dom, alert) ->
    if confirm(alert) is true
      Sinatra.selfAjax(operate, url, dom)

