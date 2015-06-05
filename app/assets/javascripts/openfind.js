(function() {
  window.Openfind = {
    chk_url: function(input) {
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
        return $(input).parent().siblings("input[type='submit']").removeAttr("disabled");
      } else {
        $("#warn").html("输入链接的域名不正确！请联系管理员");
        $("#warn").removeClass("hidden");
        return $(input).parent().siblings("input[type='submit']").attr("disabled", "disabled");
      }
    }
  };

  $(function() {
    $("#memberForm input[name='url']").bind("change keyup input", function() {
      return Openfind.chk_url(this);
    });
    return $("#templateForm input[name='url']").bind("change keyup input", function() {
      return Openfind.chk_url(this);
    });
  });

}).call(this);
