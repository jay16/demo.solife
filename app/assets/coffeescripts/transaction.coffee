window.Transactions =
  show: (transaction_id) ->
    $.ajax
      url: "/transactions/" + transaction_id
      success: (data) ->
        $("#myModalContent").html data
        $("#myModal").modal "show"
        return
    return
  plus: ->
    $quantity = $("#quantity")
    count = parseInt($quantity.attr("value"))
    $quantity.attr("value", count + 1)
  minus: ->
    $quantity = $("#quantity")
    count = parseInt($quantity.attr("value"))
    if(count > 1) then $quantity.attr("value", count - 1) else $quantity.addClass("disabled")
