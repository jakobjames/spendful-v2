var $form;$(function(){$form=$("#payment-form"),$("#payment-form").submit(function(e){var r=$(this);r.find("button").prop("disabled",!0),Stripe.createToken(r,stripeResponseHandler),e.preventDefault()})});var stripeResponseHandler=function(e,r){if(r.error)$form.find(".payment-errors").show().text(r.error.message),$form.find("button").prop("disabled",!1),window.scrollTo(0,0);else{var n=r.id;$form.append($('<input type="hidden" name="stripeToken" />').val(n)),$form.get(0).submit()}};