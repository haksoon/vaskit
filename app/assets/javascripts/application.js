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


// ga
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-75373901-1', 'auto');
ga('send', 'pageview');
// ga

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
	    return "/images/ask/card_image_preview.png";
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

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function back_button(){
	if (parent.history.length == 1){
		// window.location = "/";
    window.close();
	}else{
		parent.history.back();
	}
}

function share_log(channel){
	$.ajax({
        url: "/share_logs.json",
        type: 'POST',
        async: false,
        data: {"channel" : channel},
        dataType: 'json',
        error: function(){
            return false;
        },
        success: function(data){
        },
	    beforeSend: function(){
        }
	});
}

function get_user_ages(birthday){
  try {
    var ret = "";
    if (birthday == null || birthday == ""){
      ret = "기타";
    }else{
      var current_user_year = parseInt(birthday.split("-")[0]);
      var current_year = (new Date).getFullYear();
      var user_age = current_year - current_user_year + 1;

      user_age = Math.floor(user_age/10) * 10;
      ret = user_age + "대";
    }
    return ret;
  }catch(err) {
      return "기타";
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


var keys = {37: 1, 38: 1, 39: 1, 40: 1};

function preventDefault(e) {
  e = e || window.event;
  if (e.preventDefault)
      e.preventDefault();
  e.returnValue = false;
}

function preventDefaultForScrollKeys(e) {
    if (keys[e.keyCode]) {
        preventDefault(e);
        return false;
    }
}

function disableScroll() {
  if (window.addEventListener) // older FF
      window.addEventListener('DOMMouseScroll', preventDefault, false);
  window.onwheel = preventDefault; // modern standard
  window.onmousewheel = document.onmousewheel = preventDefault; // older browsers, IE
  window.ontouchmove  = preventDefault; // mobile
  document.onkeydown  = preventDefaultForScrollKeys;
}

function enableScroll() {
    if (window.removeEventListener)
        window.removeEventListener('DOMMouseScroll', preventDefault, false);
    window.onmousewheel = document.onmousewheel = null;
    window.onwheel = null;
    window.ontouchmove = null;
    document.onkeydown = null;
}

// AJS추가 : 각 카드 이미지에 마우스 올릴 경우 확대되도록 애니메이션 효과 부여
function hover_action(){
  $(".card_image").hover(
    function(){
      $(this).addClass("img_hover");
      $(this).next().addClass("img_hover");
    },
    function(){
      $(this).removeClass("img_hover");
      $(this).next().removeClass("img_hover");
    }
  );
  $(".card_image_overlay").hover(
    function(){
      $(this).addClass("img_hover");
      $(this).prev().children("img").addClass("img_hover");
      $(this).prev().children("p").addClass("img_hover");
    },
    function(){
      $(this).removeClass("img_hover");
      $(this).prev().children("img").removeClass("img_hover");
      $(this).prev().children("p").removeClass("img_hover");
    }
  );
};

// AJS추가 : 투표 참여시 그래프 애니메이션 효과 부여
function graph_animation(ask_deal_id) {
  var timing = 30
  var target_ask = "#ask_deal_"+ask_deal_id

  $(target_ask).find("#main_vote_count").find(".vote-result-bar-left").css("width","3px").animate({width:left_ratio+"%"}, timing * left_ratio);
  $(target_ask).find("#main_vote_count").find(".vote-result-bar-right").css("width","3px").animate({width:right_ratio+"%"}, timing * right_ratio);

  var num_left_width = 0;
  var left_ratio_increase = setInterval( function() {
    if(num_left_width < left_ratio_full) {
      num_left_width++;
      $(target_ask).find(".vote-result-num-left").text(num_left_width+"%");
    } else {
      clearInterval(left_ratio_increase);
    }
  }, timing * left_ratio / left_ratio_full );

  var num_right_width = 0;
  var right_ratio_increase = setInterval( function() {
    if(num_right_width < right_ratio_full) {
      num_right_width++;
      $(target_ask).find(".vote-result-num-right").text(num_right_width+"%");
    } else {
      clearInterval(right_ratio_increase);
    }
  }, timing * right_ratio / right_ratio_full );
}

$( document ).ready(function() {
  $("select").on("change",function(){
    if( $(this).val() != "" ) {
      $(this).css("color","#666");
    } else {
      $(this).css("color","#ccc");
    }
  });
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
