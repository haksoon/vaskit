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

// Facebook Pixel Code
!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
document,'script','https://connect.facebook.net/en_US/fbevents.js');

fbq('init', '521318198062554');
fbq('track', "PageView");
// End Facebook Pixel Code

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 500;
}

function scrollDistanceFromBottom(argument) {
  return $(document).height() - ($(window).height() + $(window).scrollTop());
}

function go_url(url) {
  window.location.assign(url);
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
	    return "/images/custom/card_image_preview.png";
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

function visitor_notify(message) {
  notify(message);
  setTimeout("notify('<i class=\"fa fa-spinner fa-spin\"></i>&nbsp;회원가입 화면으로 이동합니다&middot;&middot;&middot;')",1500);
  setTimeout('window.location.assign("/landing")',2500);
}


function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

//AJS추가(수정) - 상세화면 내부유입의 경우 창 닫기, 상세화면 외부유입의 경우 메인 페이지로 이동, 그 외의 경우 모두 뒤로 가기로 작동하도록 로직 수정
function back_button(){
  var referrer_href = /vaskit.kr\/[\S]*/
  var ask_href = /\/asks\/\d*$/
  if ( ask_href.test(window.location.pathname) && parent.history.length == 1 && referrer_href.test(document.referrer) ) {
    window.close();
  } else if ( ask_href.test(window.location.pathname) && ( parent.history.length >= 1 || referrer_href.test(document.referrer) == false ) ){
		document.location.href = "/";
	} else {
		parent.history.back();
	}
}

function share_log(channel, ask_id){
	$.ajax({
        url: "/share_logs.json",
        type: 'POST',
        async: false,
        data: {"channel" : channel, "ask_id" : ask_id},
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
    hour = Math.floor(diff/1000/60/60),
    min = Math.floor(diff/1000/60);
    ret = 0;

    if (month != 0){
    	return month + "개월 전";
    }else if(week != 0){
    	return week + "주 전";
    }else if(day != 0){
    	return day + "일 전";
    }else if(hour != 0){
    	return hour + "시간 전";
    }else if(min != 0){
      if(min<60 && min>=50) {
        return "50분 전";
      }else if(min<50 && min>=40){
        return "40분 전";
      }else if(min<40 && min>=30){
        return "30분 전";
      }else if(min<30 && min>=20){
        return "20분 전";
      }else if(min<20 && min>=10){
        return "10분 전";
      }else{
      	return "방금 전";
      }
    }else{
    	return "방금 전";
    }
}

// var keys = {37: 1, 38: 1, 39: 1, 40: 1};
//
// function preventDefault(e) {
//   e = e || window.event;
//   if (e.preventDefault)
//       e.preventDefault();
//   e.returnValue = false;
// }
//
// function preventDefaultForScrollKeys(e) {
//     if (keys[e.keyCode]) {
//         preventDefault(e);
//         return false;
//     }
// }

function disableScroll() {
  // if (window.addEventListener) // older FF
  //     window.addEventListener('DOMMouseScroll', preventDefault, false);
  // window.onwheel = preventDefault; // modern standard
  // window.onmousewheel = document.onmousewheel = preventDefault; // older browsers, IE
  // window.ontouchmove  = preventDefault; // mobile
  // document.onkeydown  = preventDefaultForScrollKeys;
  $("body").css("overflow","hidden");
  // $("#menu_bg").bind('touchmove', function(e){e.preventDefault()});
}

function enableScroll() {
  // if (window.removeEventListener)
  //     window.removeEventListener('DOMMouseScroll', preventDefault, false);
  // window.onmousewheel = document.onmousewheel = null;
  // window.onwheel = null;
  // window.ontouchmove = null;
  // document.onkeydown = null;
  $("body").css("overflow","auto");
	// $("#menu_bg").unbind('touchmove');
}

// AJS추가 : 각 카드 이미지에 마우스 올릴 경우 확대되도록 애니메이션 효과 부여
// 모바일의 경우 호버 액션은 실행되지 않도록 제어
function hover_action(ask_id){
  if ( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
    $("#ask_"+ask_id).find(".card_image_expander").addClass("img_hover");
    return false;
  } else {
    $("#ask_"+ask_id).find(".card_image").hover(
      function(){
        $(this).addClass("img_hover");
        $(this).parent().children(".card_image_expander").addClass("img_hover");
      },
      function(){
        $(this).removeClass("img_hover");
        $(this).parent().children(".card_image_expander").removeClass("img_hover");
      }
    );
    $("#ask_"+ask_id).find(".card_image_overlay").hover(
      function(){
        $(this).addClass("img_hover");
        $(this).prev().children(".card_image").addClass("img_hover");
        $(this).prev().children(".card_image_expander").addClass("img_hover");
      },
      function(){
        $(this).removeClass("img_hover");
        $(this).prev().children(".card_image").removeClass("img_hover");
        $(this).prev().children(".card_image_expander").removeClass("img_hover");
      }
    );
    $("#ask_"+ask_id).find(".vote_btn").hover(
      function(){
        $(this).prev().children(".card_image").addClass("img_hover");
        $(this).prev().children(".card_image_expander").addClass("img_hover");
        $(this).prev().children(".card_image_hover").fadeIn(100);
        // $(this).parent().parent().parent().parent().find(".card_detail_table").slideDown(200);
      },
      function(){
        $(this).prev().children(".card_image").removeClass("img_hover");
        $(this).prev().children(".card_image_expander").removeClass("img_hover");
        $(this).prev().children(".card_image_hover").fadeOut(100);
        // $(this).parent().parent().parent().find(".card_detail_table").clearQueue().delay(500).slideUp(200);
      }
    );
  }
};

// AJS추가 : 투표 참여시 그래프 애니메이션 효과 부여
function graph_animation(ask_id) {
  var timing = 30,
      l_bar = $("#left_bar_"+ask_id),
      l_num = $("#left_num_"+ask_id),
      l_tim = timing * left_ratio,
      r_bar = $("#right_bar_"+ask_id),
      r_num = $("#right_num_"+ask_id),
      r_tim = timing * right_ratio;
  // var percent_number_step = $.animateNumber.numberStepFactories.append('%');

  // l_bar.css("width","3px").velocity({"width":left_ratio+"%"}, l_tim);
  // l_num.animateNumber({ number: left_ratio_full, numberStep: percent_number_step }, l_tim);
  l_bar.css("width","3px").animate({"width":left_ratio+"%"}, l_tim);
  $({ val : 0 }).animate({ val : left_ratio_full }, {
    duration: l_tim,
    step: function() { l_num.text(Math.round(this.val)+"%") },
    complete: function() { l_num.text(Math.round(this.val)+"%") }
  });

  // r_bar.css("width","3px").velocity({"width":right_ratio+"%"}, r_tim);
  // r_num.animateNumber({ number: right_ratio_full, numberStep: percent_number_step }, r_tim);
  r_bar.css("width","3px").animate({"width":right_ratio+"%"}, r_tim);
  $({ val : 0 }).animate({ val : right_ratio_full }, {
    duration: r_tim,
    step: function() { r_num.text(Math.round(this.val)+"%") },
    complete: function() { r_num.text(Math.round(this.val)+"%") }
  });
}

// AJS추가 : 제품명 툴팁박스 추가
function tooltip_box(ask_id) {
  if ( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
    $("#ask_"+ask_id).find("p.output_field").on("click",function(){
      var tooltip_width = $(this).width();
      $(this).next().css("width",tooltip_width).clearQueue().toggleClass("tooltip_open");
    })
  } else {
    $("#ask_"+ask_id).find("p.output_field").hover(
      function(){
        var tooltip_width = $(this).width();
        $(this).next().css("width",tooltip_width).clearQueue().addClass("tooltip_open");
      }, function(){
        $(this).next().clearQueue().delay(500).removeClass("tooltip_open");
      }
    );
  }
}

// AJS추가 : 해쉬태그 하이라이트 별도 함수로 지정
function hash_tagging(origin_string, target_element) {
  var hash_tags = origin_string.match(/#([0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]*)/g);
  if (hash_tags != null) hash_tags.sort(function(a,b){ return b.length - a.length; }); // 긴 순서대로 정렬
  $.each(hash_tags, function( index, hash_tag ) {
    hash_tag = hash_tag.replace(",","");
    target_element.highlight(hash_tag, { element:'a', className: 'hash_tag '+index});
    hash_tag = hash_tag.replace('#', '').replace("?","");
    $.each( target_element.find(".hash_tag."+index), function( index2, element ){
      // if ( $(element).parent().prop('nodeName') == "SPAN"){
        $(element).attr({href:"/?keyword="+hash_tag+"&type=hash_tag"})
      // }
    });
  });
}

function link_tagging(origin_string, target_element, img_preview) {
  var links = origin_string.match(/((http(s)?:\/\/)|(www))([\S]*)/g);
  if (links != null) {
    links.sort(function(a,b){ return b.length - a.length; }); // 긴 순서대로 정렬
    var link_tags = [];
    var img_tags = [];
    var img_reg = /\.(jpg|jpeg|gif|bmp|png)/;
    $.each(links, function(index, link) {
      if (img_reg.test(link)) {
        img_tags[img_tags.length] = link;
      } else {
        link_tags[link_tags.length] = link;
      }
    });
    if (img_preview) {
      $.each(img_tags, function( index, img ) {
        target_element.highlight(img, {element:'img', className: 'img '+index});
        $.each( target_element.find(".img."+index), function( index2, element ){
          $(element).attr({src:img, style:"width:100%;"});
        });
      });
    }
    $.each(links, function( index, link ) {
      target_element.highlight(link, {element:'a', className: 'link '+index});
      $.each( target_element.find(".link."+index), function( index2, element ){
        $(element).attr({href:link, target:"_blank"});
      });
    });
  }
}

// AJS추가 : 텍스트 라인 세기
// void function $getLines($){
//     function countLines($element){
//         var lines          = 0;
//         var greatestOffset = void 0;
//         $element.find('character').each(function(){
//             if(!greatestOffset || this.offsetTop > greatestOffset){
//                 greatestOffset = this.offsetTop;
//                 ++lines;
//             }
//         });
//         return lines;
//     }
//     $.fn.getLines = function $getLines(){
//         var lines = 0;
//         var clean = this;
//         var dirty = this.clone();
//         (function wrapCharacters(fragment){
//             var parent = fragment;
//             $(fragment).contents().each(function(){
//                 if(this.nodeType === Node.ELEMENT_NODE){
//                     wrapCharacters(this);
//                 }
//                 else if(this.nodeType === Node.TEXT_NODE){
//                     void function replaceNode(text){
//                         var characters = document.createDocumentFragment();
//                         text.nodeValue.replace(/[\s\S]/gm, function wrapCharacter(character){
//                             characters.appendChild($('<character>' + character + '</>')[0]);
//                         });
//                         parent.replaceChild(characters, text);
//                     }(this);
//                 }
//             });
//         }(dirty[0]));
//         clean.replaceWith(dirty);
//         lines = countLines(dirty);
//         dirty.replaceWith(clean);
//         return lines;
//     };
// }(jQuery);

// AJS추가 : just for fun...
console.log("%c개발자형을 구합니다!","color:#ee6e01; font-size:4em; font-weight:bold; background-color: #ffe4a9; padding: 0 10px;");
// console.log("%c이 문구를 보고 계신 바로 당신만을 애타게 찾고 있었습니다!\n3개월 전만 해도 회계사였는데 여기까지 혼자 공부하면서 왔습니다 ㅠ\n이제는 도움이 필요합니다. 도와주세요...", "font-size:1.5em; color:#666;");

function progressStart() {
  $("#progress_bar").clearQueue().css("display","block").animate({width:"90%"},1000);
}
function progressEnd() {
  $("#progress_bar").stop().animate({width:"100%"},100,function(){
    $("#progress_bar").delay(300).animate({height:"0px"},100,function(){
      $("#progress_bar").css({width:"0%", height:"5px", display:"none"});
    });
  });
}

// animateCSS
$.fn.extend({
    animateCss: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).removeClass('animated ' + animationName);
        });
    },
    animateCssColor: function (animationName, color) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        var origin_color = $(this).css("color");
        $(this).css("color",color).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).css("color",origin_color).removeClass('animated ' + animationName);
        });
    },
    animateCssHide: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).hide().removeClass('animated ' + animationName);
        });
    },
    animateCssRemove: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).remove();
        });
    }
});

$.fn.selectRange = function(start, end) {
  return this.each(function() {
    if(this.setSelectionRange) {
      this.focus();
      this.setSelectionRange(start, end);
    } else if(this.createTextRange) {
      var range = this.createTextRange();
      range.collapse(true);
      range.moveEnd('character', end);
      range.moveStart('character', start);
      range.select();
    }
  });
};

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
