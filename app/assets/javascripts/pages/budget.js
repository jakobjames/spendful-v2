$(function(){
  
  $(".transactions").hide()
  
  $(document)
    .on("click", "a.add-item, a.add-transaction, a.edit-transaction, a.edit-item", function(e){
      
      var $trigger = $(this),
          $modal = $("<div></div>").addClass("modal hide fade")

      $modal
        .load($trigger.attr("href") + " .form-box > *", function(d, s){
	        $(".modal input.date")
	          .datepicker({
          		dateFormat: "dd/mm/yy"
            })
        })
        .appendTo("body")
        .modal()
        .modal("show")
        .on("hidden", function(){
          
          $(".modal input.date").datepicker("destroy")
          $(this).remove()
          
        })
        if ($trigger.hasClass("add-transaction") || $trigger.hasClass("edit-transaction")){
          $modal.attr("data-transactions", $trigger.parents(".item").data("id"))
        }
      
      e.preventDefault()
      
    })
    .on("submit", ".modal form", function(e){
      
      var $form = $(this),
          data = $form.serialize()
      
      $.ajax({
        type: $form.attr("method"),
        url: $form.attr("action"),
        data: data,
        complete: function(a, r){
          
          var $response = $(a.responseText),
              $modal = $form.parents(".modal")
          
          $modal.html("").append($response.find(".form-box > *"))
          
          if (a.status == 201){
            $modal.modal("hide")
            $("#content > .container").load(window.location + " #content > .container", function(e){
              $(".transactions").hide()
              if ($modal.data("transactions")){
                var $item = $(".item[data-id='"+$modal.data("transactions")+"']")
                $item.find(".transactions").show()
                $item.find(".toggle-transactions").addClass("active")
              }
            })
            
          }
          
        }
      })
      
      e.preventDefault()
      
    })
    .on("click", ".toggle-transactions", function(e){
      
      $(".toggle-transactions.active")
        .not(this)
        .toggleClass("active")
        .parents(".item")
        .find(".transactions")
          .toggle()
      
      $(this)
        .toggleClass("active")
        .parents(".item")
        .find(".transactions")
          .toggle()
      
      e.preventDefault()
      
    })
  
})
