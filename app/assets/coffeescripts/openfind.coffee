window.Openfind =
  chk_url: (input, btn_id) ->
    val = $.trim($(input).val())
    url = $.trim($("input[type='hidden'][name='url']").val())
    regstr = "^"+url.replace("//","\\/\\/")
    console.log(regstr)
    regexp = new RegExp(regstr)
    console.log(regexp.test(val))

    if(regexp.test(val))
      $("#warn").html("")
      $("#warn").addClass("hidden")
      $(btn_id).removeAttr("disabled")
    else
      $("#warn").html("输入链接的域名不正确...")
      $("#warn").removeClass("hidden")
      $(btn_id).attr("disabled", "disabled")

$ ->
  $("#membersForm input[name='members[url]']").bind "change keyup input", ->
    Openfind.chk_url(this, "#membersSubmit")
  $("#templateForm input[name='template[url]']").bind "change keyup input", ->
    Openfind.chk_url(this, "#templateSubmit")
