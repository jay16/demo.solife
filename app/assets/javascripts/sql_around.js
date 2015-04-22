(function() {
  window.SqlAround = {
    monitor: function(textarea) {
      var value;
      value = $(textarea).val();
      if ($.trim(value).length) {
        return $("#submit").removeAttr("disabled");
      } else {
        return $("#submit").attr("disabled", "disabled");
      }
    },
    postWithAjax: function() {
      var value;
      value = $("#textarea").val();
      return $.ajax({
        type: "post",
        url: "/sql/parse/insert_with_values",
        data: {
          "sql": value
        },
        success: function(data) {
          return $("#panel").html(data);
        },
        error: function() {
          return alert("error:post with ajax!");
        }
      });
    }
  };

  $(function() {
    $("#textarea").bind("change keyup input", function() {
      return SqlAround.monitor(this);
    });
    return $("#submit").click(function() {
      return SqlAround.postWithAjax();
    });
  });

}).call(this);
