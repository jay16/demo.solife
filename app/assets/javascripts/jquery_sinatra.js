(function() {
  window.Sinatra = {
    selfAjax: function(type, url, dom) {
      return $.ajax({
        type: type,
        url: url,
        success: function(data) {
          if ($.trim(dom).length) {
            return $(dom).remove();
          }
        },
        error: function() {
          return alert("error - with ajax!");
        }
      });
    },
    operateWithAjax: function(operate, url, dom, alert) {
      if (confirm(alert) === true) {
        return Sinatra.selfAjax(operate, url, dom);
      }
    }
  };

}).call(this);
