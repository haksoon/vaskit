// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 150;
}

function scrollDistanceFromBottom(argument) {
  return $(document).height() - ($(window).height() + $(window).scrollTop());
}

function get_image_url(data, model_name, extention){
	
	try {
		var image_url = ""; //static url
		image_url = "/assets/"+model_name+"/"+data.id+"/"+extention+"/";
		var image_file_name = data.image_file_name;
		if(image_file_name.indexOf(".") == -1){
			image_file_name = image_file_name + ".";
		} 
	  	image_url += image_file_name;
	  	return image_url;
	}
	catch(err) {
	    return "/images/ask/card_a_upload.png";
	}
}

function notify(flash_message){
	// jQuery: reference div, load in message, and fade in
    var flash_div = $("#flash");
    flash_div.html(flash_message);
    flash_div.attr('class', 'flash_ajax');
    flash_div.fadeIn("fast");
      
    // use Javascript timeout function to delay calling
    // our jQuery fadeOut, and hide
    setTimeout(function(){
    	flash_div.fadeOut("fast", function(){
        	flash_div.html("");
        	flash_div.attr('class', 'flash_html');
        	flash_div.hide();
      	})
    }, 2000);
}

function back_button(){
	if (parent.history.length == 1){
		window.location = "/";
	}else{
		parent.history.back();
	}
}

function truncate(string){
   if (string.length > 40)
      return string.substring(0,40)+'...';
   else
      return string;
};


_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

function get_past_time(time){
	var start = new Date(time),
    end   = new Date(),
    diff  = new Date(end - start),
    month  = Math.floor(diff/1000/60/60/24/30),
   	week = Math.floor(diff/1000/60/60/24/7),
    day  = Math.floor(diff/1000/60/60/24),
    hour = Math.floor(diff/1000/60/60);
    ret = 0;
    
    if (month != 0){
    	return month + "개월 전";
    }else if(week != 0){
    	return week + "주 전";
    }else if(day != 0){
    	return day + "일 전";
    }else if(hour != 0){
    	return hour + "시간 전";
    }else{
    	return "방금 전";
    }
}


$( document ).ready(function() {
	//ie 에서 placeholder 
	(function($) {
	  $.fn.placeholder = function() {
	    if(typeof document.createElement("input").placeholder == 'undefined') {
	      $('[placeholder]').focus(function() {
	        var input = $(this);
	        if (input.val() == input.attr('placeholder')) {
	          input.val('');
	          input.removeClass('placeholder');
	        }
	      }).blur(function() {
	        var input = $(this);
	        if (input.val() == '' || input.val() == input.attr('placeholder')) {
	          input.addClass('placeholder');
	          input.val(input.attr('placeholder'));
	        }
	      }).blur().parents('form').submit(function() {
	        $(this).find('[placeholder]').each(function() {
	          var input = $(this);
	          if (input.val() == input.attr('placeholder')) {
	            input.val('');
	          }
	      })
	    });
	  }
	}
	})( jQuery );
	$.fn.placeholder();
	/////////////////////////////////
});