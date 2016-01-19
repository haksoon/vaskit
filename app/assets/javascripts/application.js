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


function get_photo_url(data, model_name, extention){
	var photo_url = "http://dur3dypb2y9ha.cloudfront.net"; //static url
	photo_url = "http://dur3dypb2y9ha.cloudfront.net/assets/"+model_name+"/"+data.id+"/"+extention+"/";
	var photo_file_name = data.photo_file_name;
	if(photo_file_name.indexOf(".") == -1){
		photo_file_name = photo_file_name + ".";
	} 
  	photo_url += photo_file_name;
  	return photo_url;
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


// $(function() {
    // FastClick.attach(document.body);
// });


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