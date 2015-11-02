(function() {
  var checkTemplate;

  checkTemplate = function(element) {
    var membersForm;
    return membersForm = new Vue({
      el: element,
      data: {
        btn_disabled: true,
        warning_text: "",
        official_url: "",
        input_url: ""
      },
      methods: {
        checkUrl: function(e) {
          var regexp;
          regexp = new RegExp("^" + this.official_url);
          if (regexp.test(this.input_url)) {
            this.btn_disabled = false;
            return this.warning_text = "";
          } else {
            this.btn_disabled = true;
            return this.warning_text = "输入链接的域名不正确...";
          }
        }
      }
    });
  };

  Vue.directive("disable", function(value) {
    return this.el.disabled = !!value;
  });

  checkTemplate("#membersForm");

  checkTemplate("#templateForm");

}).call(this);
