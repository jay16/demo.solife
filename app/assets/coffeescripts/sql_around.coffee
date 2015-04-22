window.SqlAround =
  monitor: (textarea) ->
    value = $(textarea).val()
    if $.trim(value).length
      $("#submit").removeAttr("disabled")
    else
      $("#submit").attr("disabled", "disabled")

  postWithAjax: ->
    value = $("#textarea").val()
    $.ajax(
      type: "post"
      url: "/sql/parse/insert_with_values"
      data: { "sql": value }
      #dataType: "json"
      success: (data) ->
        $("#panel").html(data)
      error: ->
        alert("error:post with ajax!")
    );

$ ->
  $("#textarea").bind "change keyup input", ->
    SqlAround.monitor(this)

  $("#submit").click ->
    SqlAround.postWithAjax()
