(function() {
  window.Openfind = {
    chk_url: function(input, btn_id) {
      var regexp, regstr, url, val;
      val = $.trim($(input).val());
      url = $.trim($("input[type='hidden'][name='url']").val());
      regstr = "^" + url.replace("//", "\\/\\/");
      console.log(regstr);
      regexp = new RegExp(regstr);
      console.log(regexp.test(val));
      if (regexp.test(val)) {
        $("#warn").html("");
        $("#warn").addClass("hidden");
        return $(btn_id).removeAttr("disabled");
      } else {
        $("#warn").html("输入链接的域名不正确...");
        $("#warn").removeClass("hidden");
        return $(btn_id).attr("disabled", "disabled");
      }
    }
  };

  $(function() {
    $("#membersForm input[name='members[url]']").bind("change keyup input", function() {
      return Openfind.chk_url(this, "#membersSubmit");
    });
    return $("#templateForm input[name='template[url]']").bind("change keyup input", function() {
      return Openfind.chk_url(this, "#templateSubmit");
    });
  });

}).call(this);
