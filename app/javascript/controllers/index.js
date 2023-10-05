// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

$("#account").click(function() {
  $("#user-menu").addClass("open-user-menu")
})
$("#btnClose").click(function() {
  $("#user-menu").removeClass("open-user-menu")
})

$(document).ready(function() {
  $("#send-data-button").click(function() {

    var selectedOrderIds = $("input[name='order_ids[]']:checked").map(function(){
      return $(this).val();
    }).get();

    var reason = prompt("Enter the reason: ");

    $.ajax({
      url: "/admin/orders/batch_cancel",
      type: "GET",
      dataType: "json",
      data: { selectedOrderIds: selectedOrderIds, reason: reason },
      success: function(data) {
        console.log(data);
        alert("Cancel success")
        location.reload();
      },
      error: function() {
        console.error("Error fetching data.");
        alert("Cancel faild")
      }
    });
  });
});
