(function() {
  window.Transactions = {
    show: function(transaction_id) {
      $.ajax({
        url: "/transactions/" + transaction_id,
        success: function(data) {
          $("#myModalContent").html(data);
          $("#myModal").modal("show");
        }
      });
    },
    plus: function() {
      var $quantity, count;
      $quantity = $("#quantity");
      count = parseInt($quantity.attr("value"));
      return $quantity.attr("value", count + 1);
    },
    minus: function() {
      var $quantity, count;
      $quantity = $("#quantity");
      count = parseInt($quantity.attr("value"));
      if (count > 1) {
        return $quantity.attr("value", count - 1);
      } else {
        return $quantity.addClass("disabled");
      }
    }
  };

}).call(this);
