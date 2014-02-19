$(function(){
	
	$("#flash")
		.hide()
		.slideDown("fast", function(){
			$(this).animate({
					opacity: 1
				}, 4000, function(){
					$(this).slideUp()
				})
	  })
	
})
