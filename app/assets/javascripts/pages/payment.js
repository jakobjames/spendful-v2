var $form

$(function() {
  
  $form = $('#payment-form')
  
  $('#payment-form').submit(function(e){
    
    var $form = $(this)
    
    $form.find('button').prop('disabled', true)
    
    Stripe.createToken($form, stripeResponseHandler)
    
    e.preventDefault()

  })
  
})

var stripeResponseHandler = function(status, response) {
  
  if (response.error) {
    // Show the errors on the form
    $form.find('.payment-errors').show().text(response.error.message)
    $form.find('button').prop('disabled', false)
    window.scrollTo(0, 0)
  } else {
    // token contains id, last4, and card type
    var token = response.id;
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="stripeToken" />').val(token));
    // and submit
    $form.get(0).submit();
  }
}
