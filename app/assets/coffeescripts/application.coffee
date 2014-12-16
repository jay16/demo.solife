#encoding: utf-8
window.App =
  showLoading: ->
    $(".loading").removeClass("hidden")
  showLoading: (text) ->
    $(".loading").html(text)
    $(".loading").removeClass("hidden")
  hideLoading:->
    $(".loading").addClass("hidden")
    $(".loading").html("loading...")
  # checkbox operation
  checkboxState: (self) ->
    state = $(self).attr("checked")
    if(state == undefined || state == "undefined")
      return false
    else
      return true

  checkboxChecked: (self) ->
      $(self).attr("checked", "true")

  checkboxUnChecked: (self) ->
      $(self).removeAttr("checked")

  checkboxState1: (self) ->
    state = $(self).attr("checked")
    if(state == undefined || state == "undefined")
      $(self).attr("checked", "true")
      return true
    else
      $(self).removeAttr("checked")
      return false

  reloadWindow: ->
    window.location.reload()

  cpanelNavbarInit: ->
    pathname = window.location.pathname
    klass = "." + pathname.split("/").join("-")
    console.log(klass)
    $(klass).siblings("li").removeClass("active")
    $(klass).addClass("active")

  resizeWindow: ->
    w = window
    d = document
    e = d.documentElement
    g = d.getElementsByTagName("body")[0]
    x = w.innerWidth or e.clientWidth or g.clientWidth
    y = w.innerHeight or e.clientHeight #|| g.clientHeight;

    nav_height    = 80 || $("nav:first").height()
    footer_height = 100 || $("footer:first").height()
    main_height   = y - nav_height - footer_height
    if main_height > 300
      $("#main").css
        height: main_height + "px"

  initBootstrapNavbarLi: ->
    # navbar-nav active menu
    pathname = window.location.pathname
    navbar_right_lis = $("#navbar_right_lis").val() || 1
    navbar_lis = $(".navbar-nav:first li, .navbar-right li:lt("+navbar_right_lis+")")
    is_match = false
    navbar_lis.each ->
      href = $(this).children("a:first").attr("href")
      if pathname is href
        $(this).addClass("active")
        is_match = true
      else
        $(this).removeClass("active")

    if !is_match
      _a_href = ""
      _a_val  = ""
      $_li    = $("a:first")
      navbar_lis.each ->
        $a_first = $(this).children("a:first")
        href = $a_first.attr("href")
        if pathname.startsWith(href) and _a_href.length < href.length
          _a_href = href
          _a_val  = $a_first.text()
          $_li    = $(this)

      $_li.addClass("active")
      $("#breadcrumb").removeClass("hidden")
      $(".first-level a").attr("href", _a_href)
      _second_path = pathname.replace(_a_href, "")

      if $.trim(_a_val).length
        _a_val  = _a_val.replace("我的", "")
      else if _a_href is "/account/renewal"
        _a_val  = "续期"
      $(".first-level a").html(_a_val)

      if _second_path.match(/^\/\d+$/)
        _second_val = _a_val + "[明细]"
      else if _second_path.match(/^\/new$/)
        _second_val = "[新建]" + _a_val
      else if _second_path.match(/^\/\d+\/edit$/)
        _second_val = "[编辑]" + _a_val
      else if _second_path.match(/^\/\w+\/order$/)
        _second_val = "订单" 
      else if _second_path.match(/^\/\w+\/order_item$/)
        _second_val = "商品"
      $(".second-level").html(_second_val) 


  initBootstrapPopover: ->
    $("body").popover
      selector: "[data-toggle=popover]"
      container: "body"

  initBootstrapTooltip: ->
    $("body").tooltip
      selector: "[data-toggle=tooltip]"
      container: "body"

# NProgress
NProgress.configure
  speed: 500
#$.getScript "/javascripts/js_util.js", ->
#  console.log("load /javascripts/js_util.js successfully.")
$ ->
  NProgress.start()
  App.resizeWindow()
  NProgress.set(0.2)
  App.initBootstrapPopover()
  NProgress.set(0.4)
  App.initBootstrapTooltip()
  NProgress.set(0.8)
  App.initBootstrapNavbarLi()
  NProgress.done(true)
