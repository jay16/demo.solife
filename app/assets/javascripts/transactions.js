(function() {
  window.Transactions = {
    search: function(input) {
      var count, date_begin, keyword;
      keyword = $(input).val();
      if (!keyword.trim()) {
        $(".transaction").removeClass("hidden");
        $(".over").addClass("hidden");
        return $(".search-result").text("");
      } else {
        date_begin = new Date();
        count = 0;
        return $(".transaction").each(function() {
          var date_end, keywords, search_duration, text;
          keywords = $(this).data("keywords");
          if (keywords.indexOf(keyword) >= 0) {
            $(this).removeClass("hidden");
            count += 1;
          } else {
            $(this).addClass("hidden");
          }
          date_end = new Date();
          search_duration = (date_end.getTime() - date_begin.getTime()) / 1000;
          text = "找到约" + count + "条结果(用时" + search_duration + "秒)";
          return $(".search-result").text(text);
        });
      }
    },
    showAllTransactions: function(input) {
      var is_checked;
      is_checked = $(input).attr("checked");
      if (is_checked === "checked") {
        return $(".transaction").removeClass("hidden");
      } else {
        return $(".over").addClass("hidden");
      }
    }
  };

  $(function() {
    return $('input#search').bind("change keyup input", function() {
      return Transactions.search(this);
    });
  });

}).call(this);
