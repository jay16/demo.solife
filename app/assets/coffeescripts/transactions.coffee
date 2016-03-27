#encoding: utf-8
window.Transactions =
  # search transaction with keywords 
  search: (input) ->
    keyword = $(input).val()
    # when keyword is empty then show normal
    if !keyword.trim()
      $(".transaction").removeClass("hidden")
      $(".over").addClass("hidden")
      $(".search-result").text("")
    else
      date_begin = new Date()
      count = 0
      $(".transaction").each ->
        keywords = $(this).data("keywords") 
        if keywords.indexOf(keyword) >= 0
          $(this).removeClass("hidden")
          count += 1
        else
          $(this).addClass("hidden")

        date_end = new Date()
        search_duration = (date_end.getTime() - date_begin.getTime())/1000
        text = "找到约"+count+"条结果(用时" + search_duration+ "秒)"
        $(".search-result").text(text)


  showAllTransactions: (input) ->
    is_checked = $(input).attr("checked")

    if is_checked == "checked"
      $(".transaction").removeClass("hidden")
    else
      $(".over").addClass("hidden")

$ ->
  # detect the change
  $('input#search').bind "change keyup input", ->
    Transactions.search(this)
  
