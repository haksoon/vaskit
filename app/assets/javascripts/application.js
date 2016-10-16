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

// 뒤로가기 관련 코드
$(document).ready(function(){
  progressStart();
  search_bar_hide();
  window.scrollTo(0,0);
  $(window).unbind("popstate");
  history.replaceState(null, null, null);
  $(window).bind("popstate", function(e){
    if (!!$("#main_header").length) main_header_button();
    if (is_ask_image_opened) {
      ask_image_off();
    } else if (is_category_opened || is_user_opened || is_search_input_opened) {
      if (is_category_opened) category_off();
      if (is_user_opened) user_off();
      if (is_search_input_opened) search_input_off();
    } else if (is_report_popup_opened) {
      hide_report_popup();
    } else if (is_alram_opened) {
      card_detail_off(opened_ask_id);
      user_on();
      is_alram_opened = false;
    } else if (is_card_opened) {
      card_detail_off(opened_ask_id);
    } else if (is_search_deal_opened) {
      hide_search_deal_popup();
    } else if (is_image_edit_opened) {
      confirm("이미지 편집을 취소하실건가요?") ? hide_image_edit_popup() : history.pushState(null, null, null);
    } else if (is_app_popup_opened) {
      hide_app_popup();
    } else if (is_video_opened) {
      video_off();
    }
  });
  $(document).keydown(function(e){
    if(e.target.nodeName != "INPUT" && e.target.nodeName != "TEXTAREA"){
      if(e.keyCode === 27){
        if (is_ask_image_opened) {
          back_button();
        } else if (is_category_opened || is_user_opened || is_search_input_opened) {
          if (is_category_opened) back_button();
          if (is_user_opened) back_button();
          if (is_search_input_opened) back_button();
        } else if (is_report_popup_opened) {
          back_button();
        } else if (is_card_opened) {
          back_button();
        } else if (is_search_deal_opened) {
          back_button();
        } else if (is_image_edit_opened) {
          confirm("이미지 편집을 취소하실건가요?") ? hide_image_edit_popup() : history.pushState(null, null, null);
        } else if (is_app_popup_opened) {
          hide_app_popup();
        }
      }
    }
  });

  if (window.HybridApp) {
    HybridApp.getGCM("hello world");
  }
})
$(window).load(function(){
  progressEnd();
});
$(window).scroll(function(){
  if($(this).scrollTop() < 0) {
    $("#wrap_dummy_back").show();
  } else {
    $("#wrap_dummy_back").hide();
  }
});

// Device Check
// var ua = window.navigator.userAgent.toLowerCase();
// var isWinPhone = ua.indexOf('windows phone') !== -1;
// var isIOS = !isWinPhone && !!ua.match(/ipad|iphone|ipod/);
// var isAndroid = ua.indexOf('android') !== -1;
// var isIE = !!ua.match(/msie|trident\/7|edge/);

var ua = window.navigator.userAgent.toLowerCase();
var isAndroidApp       = false,
    isIOSApp           = false,
    isWinPhone         = false,
    isIOS              = false,
    isAndroid          = false,
    isWindowPC         = false,
    isMacPC            = false,
    isLinuxPC          = false;
var isMobile           = false,
    isPC               = false;
var isIE = !!ua.match(/msie|trident\/7|edge/);

if (window.HybridApp) {
  isAndroidApp = true;
  isIOSApp = false;
  isMobile = true;
} else if (ua.match(/windows phone/)) {
  isWinPhone = true;
  isMobile = true;
} else if (ua.match(/iphone|ipod|ipad/)) {
  isIOS = true;
  isMobile = true;
} else if (ua.match(/android/) && !isAndroid) {
  isAndroid = true;
  isMobile = true;
} else if (ua.match(/win|windows/) && !isWinPhone) {
  isWindowPC = true;
  isPC = true;
} else if (ua.match(/mac|macIntel/) && !isIOS) {
  isMacPC = true;
  isPC = true;
} else if (ua.match(/linux/)) {
  isLinuxPC = true;
  isPC = true;
} else if (ua.match(/Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i)) {
  isMobile = true;
}

// App GCM information settings
function setGCM(key, device_id, app_ver) {
  $.cookie('gcm_key' , key, { expires : 30000, path : '/' });
  $.cookie('device_id' , device_id, { expires : 30000, path : '/' });
  $.cookie('app_ver', app_ver, { expires : 30000, path : '/' });
};

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

function imgError(image, alter_url){
  image.onerror = "";
  if (alter_url == null) alter_url = "/images/custom/card_image_preview.png";
  image.src = alter_url;
  console.log('이미지 교체...');
  return true;
}

function notify(msg){
  var flash_div = $("#flash");
  var flash_msg = $("#flash_msg");
  flash_div.stop().animate({"top":"-50px"},50,function(){
    flash_msg.html("").html(msg);
    flash_div.show().animate({"top":"0px"},250,function(){
      flash_div.delay(3000).animate({"top":"-50px"},500,function(){
        flash_div.hide();
        flash_msg.html("");
      });
    });
  });
  flash_div.unbind("touchmove click").bind("touchmove click", function(){
    $(this).stop().animate({"top":"-50px"},250,function(){
      $(this).css({"height":"50px"});
    });
    return false;
  });
}

function visitor_notify(message) {
  notify(message);
  setTimeout("notify('<i class=\"fa fa-spinner fa-spin\"></i>&nbsp;&nbsp;회원가입 화면으로 이동합니다&middot;&middot;&middot;')",1500);
  setTimeout('window.location.assign("/landing")',2500);
}


function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

var back_button_clicked = false;
function back_button(){
  if (!back_button_clicked) {
    history.back();
    back_button_clicked = true;
    setTimeout(function(){
      back_button_clicked = false;
    },1000);
  } else {
    return false;
  }
}

function header_back_button(){
  var referrer = document.createElement("a");
  referrer.href = document.referrer;
  if (parent.history.length == 1 || referrer.host != document.location.host || is_show_opened) {//|| referrer.href == document.location.href) {
    go_url("/");
  } else {
    back_button();
  }
}

function window_back_button(){
  try {
    window.close();
  } finally {
    back_button();
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
   if (string.length > 30)
      return string.substring(0,30)+'&middot;&middot;&middot;';
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


// 스크롤 관련
function search_bar_hide(){
  // 스크롤 다운시 검색창 및 질문버튼 숨기기
  var didScroll;
  var lastScrollTop = 0;
  var delta = 20;
  var navbarHeight = $(".search_bar_area").outerHeight();

  $(window).scroll(function(event){
    didScroll = true;
  });

  setInterval(function() {
    if (didScroll) {
      hasScrolled();
      didScroll = false;
    }
  }, 250);

  function hasScrolled() {
      var st = $(this).scrollTop();
      if (st > lastScrollTop && st > navbarHeight){
        $("#search").css({"top":"0px"});
        $("#app_banner").css({"right":"30%"});
        $(".home-float-btn-area").css({"bottom":"-85px"});
      } else if ((st < lastScrollTop && Math.abs(lastScrollTop - st) > delta) || st < 50) {
          if(st + $(window).height() <= $(document).height() ) {
            $("#search").css({"top":"50px"});
            $("#app_banner").css({"right":"50%"});
            $("#home-float-btn-tooltip").show();
            $(".home-float-btn-area").css({"bottom":"15px"}).animateCss("bounce");
          }
      }
      lastScrollTop = st;
  }
}

function disableScroll() {
  $("body").css("overflow","hidden");
  $("#menu_bg_full, #menu_bg, #menu_bg_pc, #image_edit_popup_bg, #app_popup_bg, #video_overlay_bg").bind("touchmove", function(e){
    return false;
  });
}

function enableScroll() {
  $("body").css("overflow","auto");
  $("#menu_bg_full, #menu_bg, #menu_bg_pc, #image_edit_popup_bg, #app_popup_bg, #video_overlay_bg").unbind("touchmove");
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
function graph_animation(ask_id, left_ratio, right_ratio) {
  var left_ratio_full = left_ratio / 80 * 100;
  var right_ratio_full = right_ratio / 80 * 100;
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

function share_facebook(ask_id) {
  var share_url = $("#share_url_"+ask_id).val();
  if (window.HybridApp) {
    HybridApp.shareFacebook(share_url);
  } else {
    if (typeof(FB) != 'undefined' && FB != null ) {
      FB.init({
        appId      : '<%=Facebook::CONFIG["app_id"]%>',
        status     : true,
        xfbml      : true,
        version    : 'v2.5' // or v2.0, v2.1, v2.2, v2.3
      });
    }
    FB.ui({
      method: 'share',
      href: share_url,
    }, function(response){});
  }

  share_log("facebook", ask_id);
}

function share_katalk(ask_id) {
  var ask = $.grep(asks, function(obj) { return obj.id === ask_id })[0];
  var left_deal_title = ask.left_ask_deal.title;
  var right_deal_title = ask.right_ask_deal.title;
  var share_url = $("#share_url_"+ask_id).val();
  var image_url = "http://vaskit.kr/images/logo/share_800x600.png";
  var label = "둘중에뭐사지? 골라주세요!\n\n"+left_deal_title+"\nvs\n"+right_deal_title+",\n당신의 선택은?\n\n"+share_url;
  share_log("katalk", ask_id);

  try{
    Kakao.init("91c2c2e69d89a8617cfedd3e61b041ca");
    Kakao.Link.sendTalkLink({
      label: label,
      image: {
        src:  image_url,
        width: '800',
        height: '600'
      },
      webButton: {
        text: "Let's VASKIT!",
        url: share_url
      }
    });
  } catch(err) {
  }
}

function copy_url(ask_id) {
  var share_url = $("#share_url_"+ask_id).val();
  function copyfieldvalue(e, id){
    if (document.execCommand("copy")) {
      var field = document.getElementById(id);
      field.focus();
      field.setSelectionRange(0, field.value.length);
      document.execCommand("copy");
      notify('주소가 복사되었습니다!');
    } else {
      prompt('아래의 주소를 복사해주세요!', share_url);
    }
  }

  copyfieldvalue(event, "share_url_"+ask_id);

  share_log("url", ask_id);
}

// AJS추가 : just for fun...
console.log("%c개발자형을 구합니다!","color:#ee6e01; font-size:4em; font-weight:bold; background-color: #ffe4a9; padding: 0 10px;");

function progressStart() {
  $("#progress_bar").clearQueue().css("display","block").animate({width:"90%"},1000,function(){
    $("#progress_bar").animate({width:"94%"},2000,function(){
      $("#progress_bar").animate({width:"98%"},8000);
    });
  });
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


// doubletap 이벤트 생성
(function($){
	"use strict";

	var tapTimer,
		moved     = false,   // flag to know if the finger had moved while touched the device
		threshold = 250;     // ms

	$.event.special.doubleTap = {
	      setup    : setup,
        teardown : teardown,
        handler  : handler
	};

  $.event.special.tap = {
        setup    : setup,
        teardown : teardown,
        handler  : handler
  };

	function setup(data, namespaces){
	  var elm = $(this);

		if (elm.data('tap_event') == true) return;

		elm.bind('touchend.tap', handler).bind('touchmove.tap', function(){
	    moved = true;
    }).data('tap_event', true);
	}

	function teardown(namespaces) {
    $(this).unbind('touchend.tap touchmove.tap');
  }

	function handler(event){
		if( moved ){ // reset
			moved = false;
			return false;
		}

		var elem   	  = event.target,
  			$elem 	  = $(elem),
  			lastTouch = $elem.data('lastTouch') || 0,
  			now 	    = event.timeStamp,
  			delta 	  = now - lastTouch;

		// double-tap condition
		if ( delta > 20 && delta < threshold ) {
			clearTimeout(tapTimer);
			return $elem.data('lastTouch', 0).trigger('doubleTap');
		} else {
      $elem.data('lastTouch', now);
    }

		tapTimer = setTimeout(function(){
			$elem.trigger('tap');
		}, threshold);
	}
})(jQuery);

// extension: scrollEnd detection
$.fn.scrollEnd = function(callback, timeout) {
  $(this).scroll(function(){
    var $this = $(this);
    if ($this.data('scrollTimeout')) {
      clearTimeout($this.data('scrollTimeout'));
    }
    $this.data('scrollTimeout', setTimeout(callback,timeout));
  });
};


$( document ).ready(function() {
  $("select").on("focus",function(){
    $(this).css("color","#666");
  }).on("blur",function(){
    if( $(this).val() == "" || $(this).val() == null ) {
      $(this).css("color","#ccc");
    } else {
      $(this).css("color","#666");
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
