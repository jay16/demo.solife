(function() {
  window.DemoHome = {
    timerShowSkeleton: void 0,
    showSkeleton: function(width) {
      return [].forEach.call($("*"), function(a) {
        return a.style.outline = (width > 0 ? width + "px solid #" + (~~(Math.random() * (1 << 24))).toString(16) : "none");
      });
    },
    toggleSkeleton: function() {
      if (typeof DemoHome.timerShowSkeleton === "undefined" || DemoHome.timerShowSkeleton === null) {
        return DemoHome.timerShowSkeleton = self.setInterval("DemoHome.showSkeleton(1)", 500);
      } else {
        DemoHome.timerShowSkeleton = window.clearInterval(DemoHome.timerShowSkeleton);
        return DemoHome.showSkeleton(0);
      }
    }
  };

  $(function() {
    var pathname, poetry;
    pathname = window.location.pathname;
    $(".post-href").each(function() {
      var href;
      href = $(this).attr("href");
      if (!/^http:\/\/|^https:\/\//.test(href)) {
        return $(this).attr("href", (pathname + href).replace("//", "/"));
      }
    });
    poetry = "凡是遥远的地方,对我们来说都有一种诱惑,不是诱惑于美丽,就是诱惑于传说,即便远方的风景,并不如人意,我们也无需在乎,因为这实在是一个,迷人的错,到远方去 到远方去,熟悉的地方没有景色";
    $('.site-name').css('height', $('.site-name').css('height'));
    return $(".typed-quotes").typed({
      strings: poetry.split(","),
      typeSpeed: 100,
      contentType: "text",
      loop: true,
      backDelay: 1000,
      showCursor: true,
      cursorChar: "|"
    });
  });

}).call(this);
