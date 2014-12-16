(function() {
  window.App = {
    showLoading: function() {
      return $(".loading").removeClass("hidden");
    },
    showLoading: function(text) {
      $(".loading").html(text);
      return $(".loading").removeClass("hidden");
    },
    hideLoading: function() {
      $(".loading").addClass("hidden");
      return $(".loading").html("loading...");
    },
    checkboxState: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        return false;
      } else {
        return true;
      }
    },
    checkboxChecked: function(self) {
      return $(self).attr("checked", "true");
    },
    checkboxUnChecked: function(self) {
      return $(self).removeAttr("checked");
    },
    checkboxState1: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        $(self).attr("checked", "true");
        return true;
      } else {
        $(self).removeAttr("checked");
        return false;
      }
    },
    reloadWindow: function() {
      return window.location.reload();
    },
    cpanelNavbarInit: function() {
      var klass, pathname;
      pathname = window.location.pathname;
      klass = "." + pathname.split("/").join("-");
      console.log(klass);
      $(klass).siblings("li").removeClass("active");
      return $(klass).addClass("active");
    },
    resizeWindow: function() {
      var d, e, footer_height, g, main_height, nav_height, w, x, y;
      w = window;
      d = document;
      e = d.documentElement;
      g = d.getElementsByTagName("body")[0];
      x = w.innerWidth || e.clientWidth || g.clientWidth;
      y = w.innerHeight || e.clientHeight;
      nav_height = 80 || $("nav:first").height();
      footer_height = 100 || $("footer:first").height();
      main_height = y - nav_height - footer_height;
      if (main_height > 300) {
        return $("#main").css({
          height: main_height + "px"
        });
      }
    },
    initBootstrapNavbarLi: function() {
      var $_li, is_match, navbar_lis, navbar_right_lis, pathname, _a_href, _a_val, _second_path, _second_val;
      pathname = window.location.pathname;
      navbar_right_lis = $("#navbar_right_lis").val() || 1;
      navbar_lis = $(".navbar-nav:first li, .navbar-right li:lt(" + navbar_right_lis + ")");
      is_match = false;
      navbar_lis.each(function() {
        var href;
        href = $(this).children("a:first").attr("href");
        if (pathname === href) {
          $(this).addClass("active");
          return is_match = true;
        } else {
          return $(this).removeClass("active");
        }
      });
      if (!is_match) {
        _a_href = "";
        _a_val = "";
        $_li = $("a:first");
        navbar_lis.each(function() {
          var $a_first, href;
          $a_first = $(this).children("a:first");
          href = $a_first.attr("href");
          if (pathname.startsWith(href) && _a_href.length < href.length) {
            _a_href = href;
            _a_val = $a_first.text();
            return $_li = $(this);
          }
        });
        $_li.addClass("active");
        $("#breadcrumb").removeClass("hidden");
        $(".first-level a").attr("href", _a_href);
        _second_path = pathname.replace(_a_href, "");
        if ($.trim(_a_val).length) {
          _a_val = _a_val.replace("我的", "");
        } else if (_a_href === "/account/renewal") {
          _a_val = "续期";
        }
        $(".first-level a").html(_a_val);
        if (_second_path.match(/^\/\d+$/)) {
          _second_val = _a_val + "[明细]";
        } else if (_second_path.match(/^\/new$/)) {
          _second_val = "[新建]" + _a_val;
        } else if (_second_path.match(/^\/\d+\/edit$/)) {
          _second_val = "[编辑]" + _a_val;
        } else if (_second_path.match(/^\/\w+\/order$/)) {
          _second_val = "订单";
        } else if (_second_path.match(/^\/\w+\/order_item$/)) {
          _second_val = "商品";
        }
        return $(".second-level").html(_second_val);
      }
    },
    initBootstrapPopover: function() {
      return $("body").popover({
        selector: "[data-toggle=popover]",
        container: "body"
      });
    },
    initBootstrapTooltip: function() {
      return $("body").tooltip({
        selector: "[data-toggle=tooltip]",
        container: "body"
      });
    }
  };

  NProgress.configure({
    speed: 500
  });

  $(function() {
    NProgress.start();
    App.resizeWindow();
    NProgress.set(0.2);
    App.initBootstrapPopover();
    NProgress.set(0.4);
    App.initBootstrapTooltip();
    NProgress.set(0.8);
    App.initBootstrapNavbarLi();
    return NProgress.done(true);
  });

}).call(this);
