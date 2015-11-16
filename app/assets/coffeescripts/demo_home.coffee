#encoding: utf-8
window.DemoHome =
  timerShowSkeleton: undefined

  showSkeleton: (width) ->
    [].forEach.call $("*"), (a) ->
      a.style.outline = (if width > 0 then (width + "px solid #" + (~~(Math.random() * (1 << 24))).toString(16)) else "none")

  toggleSkeleton: () ->
    if typeof ($.timerShowSkeleton) is "undefined" or $.timerShowSkeleton is null
      $.timerShowSkeleton = self.setInterval("DemoHome.showSkeleton(1)", 500)
    else
      $.timerShowSkeleton = window.clearInterval($.timerShowSkeleton)
      DemoHome.showSkeleton 0


$ ->
  pathname = window.location.pathname
  $(".post-href").each ->
    href = $(this).attr("href")
    $(this).attr "href", (pathname + href).replace("//", "/")  unless /^http:\/\/|^https:\/\//.test(href)

  poetry = "凡是遥远的地方,对我们来说都有一种诱惑,不是诱惑于美丽,就是诱惑于传说,即便远方的风景,并不如人意,我们也无需在乎,因为这实在是一个,迷人的错,到远方去 到远方去,熟悉的地方没有景色"
  
  $('.site-name').css 'height', $('.site-name').css('height')
  $(".typed-quotes").typed
    strings: poetry.split(",")
    typeSpeed: 100
    contentType: "text"
    loop: true
    backDelay: 1000
    showCursor: true
    cursorChar: "|"

