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
//= require_tree ./application

// init Template
_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

// 안드로이드 브라우저 재접속시 AJAX 캐시로 인해 json 데이터가 렌더링되는 문제점 방지
$.ajaxSetup({ cache: false });

 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용
 $(window).load(function() {
  if (window.HybridApp) {
    try {
      HybridApp.getGCM('hello world');
    } catch(err) {
      return false;
    }
  }
});

function setGCM(key, device_id, app_ver) {
  $.cookie('gcm_key', null);
  $.cookie('device_id', null);
  $.cookie('app_ver', null);
  var html = '<div class="no_result">' +
             '<div class="align_middle" style="color: #fff;">' +
             '<img src="/images/logo/logo_landing.png" style="width: 180px; margin-bottom: -60px;">' +
             '<br>완전히 달라진 VASKIT!' +
             '<br>앱을 업데이트해주세요 🙈' +
             '</div>' +
             '</div>';
  $('body').html(html);
}

function getIOSApp() {} // 앱스토어 1.0.3 버전 검수용
// 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용 // 구버전 앱 실행 방지용

// Device Check
var userApp = false;               // 앱이면 true, 앱이 아니면 false, AOS/iOS는 window.HybridApp으로 판별
var userDevice = {
        isAndroid     : false,    // 금액입력필드 키보드 타입 조정
        isIOS         : false,    // 해시태그 입력필드 마진 조정
        isWinPC       : false,
        isMacPC       : false,
        isLinuxPC     : false,
        isMobile      : false,
        isPC          : false     // 앱 프로모션 배너
    },
    userBrowser = {
        isNaver       : false,
        isDaum        : false,
        isKakao       : false,
        isFacebook    : false,
        isIE          : false,
        isEdge        : false,
        isOpera       : false,
        isChrome      : false,
        isFirefox     : false,
        isSafari      : false
    };

function setUserDevice() {
  var ua = window.navigator.userAgent.toLowerCase();
  if (ua.match(/iphone|ipod|ipad/)) {
    userDevice.isIOS             = true;
    userDevice.isMobile          = true;
  } else if (ua.match(/android/)) {
    userDevice.isAndroid         = true;
    userDevice.isMobile          = true;
  } else if (ua.match(/win|windows/)) {
    userDevice.isWinPC           = true;
    userDevice.isPC              = true;
  } else if (ua.match(/mac|macIntel/)) {
    userDevice.isMacPC           = true;
    userDevice.isPC              = true;
  } else if (ua.match(/linux/)) {
    userDevice.isLinuxPC         = true;
    userDevice.isPC              = true;
  }

  if (ua.match(/VASKIT_IOS_APP/i)) {
    userApp                      = true;
    userDevice.isIOS             = true;
    userDevice.isMobile          = true;
    userBrowser.isSafari         = true;
  } else if (ua.match(/VASKIT_AOS_APP/i)) {
    userApp                      = true;
    userDevice.isAndroid         = true;
    userDevice.isMobile          = true;
    userBrowser.isChrome         = true;
  } else if (ua.match(/NAVER/i)) {
    userBrowser.isNaver          = true;
  } else if (ua.match(/Daum/)) {
    userBrowser.isDaum           = true;
  } else if (ua.match(/KAKAOTALK|KAKAOSTORY/i)) {
    userBrowser.isKakao          = true;
  } else if (ua.match(/Facebook|FB/i)) {
    userBrowser.isFacebook       = true;
  } else if (ua.match(/MSIE|Trident/i)) {
    userBrowser.isIE             = true;
  } else if (ua.match(/Edge/i)) {
    userBrowser.isEdge           = true;
  } else if (ua.match(/Opera|OPR|OPiOS/i)) {
    userBrowser.isOpera          = true;
  } else if (ua.match(/Chrome|CriOS/i)) {
    userBrowser.isChrome         = true;
  } else if (ua.match(/Firefox|FxiOS/i)) {
    userBrowser.isFirefox        = true;
  } else if (ua.match(/Safari/i)) {
    userBrowser.isSafari         = true;
  }
}

// App Check & Push Setting
function setUserApp() {
  // App에서 호출
  userApp                        = true;
  userDevice.isMobile            = true;
  getUserToken();
}

function getUserToken() {
  setTimeout(function() {
    if (window.HybridApp) {
      HybridApp.getUserToken('hello world');             // AOS
    } else {
      window.location.href = 'vaskit://getUserToken';    // iOS
    }
  }, 2000);
}

function setUserToken(gcm_key, device_id, app_ver) {
  // App에서 호출
  $.ajax({
    url: '/user_gcm_keys.json',
    dataType: 'json',
    type: 'POST',
    data: { gcm_key: gcm_key, device_id: device_id, app_ver: app_ver }
  });
}

function setAppStatusBar(type) {
  // type => { normal, dark, orange }
  // textColor => { 0: white, 1: black }
  var r, g, b, a, textColor;
  if (type == 'dark') {
    r = 51;
    g = 51;
    b = 51;
    a = 1;
    textColor = 0;
  } else if (type == 'orange') {
    r = 255;
    g = 120;
    b = 0;
    a = 1;
    textColor = 0;
  } else if (type == 'white') {
    r = 255;
    g = 255;
    b = 255;
    a = 1;
    textColor = 1;
  } else {
    r = 249;
    g = 249;
    b = 249;
    a = 1;
    textColor = 1;
  }

  setTimeout(function() {
    if (window.HybridApp) {
      HybridApp.setAppStatusBar(r, g, b, a * 255, textColor);        // AOS
    } else {
      window.location.href = 'vaskit://setAppStatusBar/////'+r/255+'/////'+g/255+'/////'+b/255+'/////'+a+'/////'+textColor;    // iOS
    }
  }, 250);
}

function visitor_check() {
  if (current_user === null) {
    notify('더 진행하시려면 로그인을 해주세요!');
    go_url('landing');
    return true;
  } else {
    return false;
  }
}

// 탭 이동
function show_seg(seg_id) {
  var url;

  if ($('#seg_'+seg_id).hasClass('on')) {
    // 동일 탭으로 이동할 경우
    if ($('#seg_'+seg_id+' .wrapper.main').hasClass('prev')) {
      // 보조 컨테이너가 열려있는 경우 메인으로 돌아감
      $('#seg_'+seg_id+' .wrapper.main').removeClass('prev');
      $('#seg_'+seg_id+' .wrapper.sub').removeClass('prev').addClass('next').transitionRemove();
    } else {
      // 메인 컨테이너가 열려있는 경우 상단으로 돌아감
      if (seg_id === 1 || seg_id ===2) {
        $('#seg_'+seg_id+' .wrapper.main .container.main').css('-webkit-overflow-scrolling', 'initial').animate({ scrollTop: 0 }, 250, function() {
          $(this).css('-webkit-overflow-scrolling', 'touch');
        });
      } else if (seg_id === 4) {
        $('#seg_'+seg_id+' .wrapper.main .inner').not('.prev').not('.next').css('-webkit-overflow-scrolling', 'initial').animate({ scrollTop: 0 }, 250, function() {
          $(this).css('-webkit-overflow-scrolling', 'touch');
        });
      }
    }
  } else {
    // 다른 탭으로 이동할 경우

    // 현재 열려있는 모든 컨테이너를 비활성화함
    $('.seg.on').removeClass('on');
    $('.tab.on').removeClass('on');

    if (seg_id === 1) {
      url = '/';
      $('#main_view').removeClass('seg2 seg4').addClass('seg1');
    } else if (seg_id === 2) {
      url = '/search';
      $('#main_view').removeClass('seg1 seg4').addClass('seg2');
    } else if (seg_id === 4) {
      url = '/users';
      $('#main_view').removeClass('seg1 seg2').addClass('seg4');
    }

    // 사용자가 이동하기 원하는 탭을 활성화함
    $('.seg#seg_'+seg_id).addClass('on');
    $('.tab.seg'+seg_id).addClass('on');

    return url;
  }
}

function seg_init(seg_id) {
  if (seg_id === 1) {
    set_recent_asks();
    ga('send', 'event', '컬렉션탭', '컬렉션탭 진입', 1);
  } else if (seg_id === 2) {
    ga('send', 'event', '검색탭', '검색탭 진입', 1);
  } else if (seg_id === 4) {
    user_profile_on();
    ga('send', 'event', '마이탭', '마이탭 진입', current_user.string_id, 1);
  }
}


// Full View
function open_full_view(html) {
  var new_viewer = '<div class="viewer full off new"></div>';
  $('#main_view').append(new_viewer);
  new_viewer = $('#main_view').find('.viewer.new');
  new_viewer.html(html).removeClass('new');
  setTimeout(function() {
    new_viewer.removeClass('off');
  }, 50);
  return new_viewer;
}

function close_full_view() {
  $('#main_view').children('.viewer').not('.menu').last().addClass('off').transitionRemove();
}

function create_wrapper(html, is_full) {
  var target_seg = $('#seg_'+currentSeg);
  var prev_wrappers = target_seg.find('.wrapper');
  var new_wrapper = is_full ? '<div class="wrapper sub full next new"></div>' : '<div class="wrapper sub next new"></div>';

  target_seg.append(new_wrapper);
  new_wrapper = target_seg.find('.wrapper.new');
  new_wrapper.html(html).removeClass('new');
  setTimeout(function() {
    if (is_full) { $('#footer').addClass('hide'); } else { $('#footer').removeClass('hide'); }
    prev_wrappers.addClass('prev');
    new_wrapper.removeClass('next');
  }, 50);
  return new_wrapper;
}

function remove_wrapper() {
  var target_seg = $('#seg_'+currentSeg);
  var prev_wrappers = target_seg.find('.wrapper');
  var now_wrapper = prev_wrappers.eq(prev_wrappers.length-1);
  var last_wrapper = prev_wrappers.eq(prev_wrappers.length-2);

  if (last_wrapper.hasClass('full')) {
    $('#footer').addClass('hide');
  } else {
    $('#footer').removeClass('hide');
  }
  last_wrapper.removeClass('prev');
  now_wrapper.addClass('next').transitionRemove();
}

$.fn.scroll_to = function(destination) {
  var current_wrapper;
  if ($('#main_view').find('.viewer.full').length > 0) {
    current_wrapper = $('#main_view').find('.viewer.full').last();
  } else {
    current_wrapper = $('#main_view').find('.seg.on').find('.wrapper').last();
  }
  var current_container = current_wrapper.find('.container.main');
  var current_inner = current_container.find('.inner').not('.prev').not('.next').not('.top').not('.bottom');
  var top = 0;
  var bottom, st_now;
  if (current_inner.length > 0) {
    bottom = current_inner.prop('scrollHeight');
    st_now = current_inner.scrollTop();
  } else {
    bottom = current_container.prop('scrollHeight');
    st_now = current_container.scrollTop();
  }

  if (destination === null || destination === undefined) {
    destination = st_now > 0 ? top : bottom;
  } else if (destination === true) {
    destination = top;
  } else if (destination === false) {
    destination = bottom;
  }

  if (current_inner.length > 0) {
    current_inner.clearQueue().css('-webkit-overflow-scrolling', 'initial').animate({ scrollTop: destination }, 250, function() {
      current_inner.css('-webkit-overflow-scrolling', 'touch');
    });
  } else {
    current_container.clearQueue().css('-webkit-overflow-scrolling', 'initial').animate({ scrollTop: destination }, 250, function() {
      current_container.css('-webkit-overflow-scrolling', 'touch');
    });
  }
};

function nearBottomOfContainer(element) {
  // return element.scrollHeight - element.scrollTop - element.offsetHeight < 500;
  return element.prop('scrollHeight') - (element.scrollTop() + element.height()) < 50;
}

function removeIOSRubberEffect(element) {
  if (userDevice.isIOS) {
    window.event.cancelBubble = true;
    var vp_height = element.height(),
        vp_scroll = element.prop('scrollHeight'),
        vp_top = element.scrollTop(),
        vp_bottom = vp_top + vp_height;
    if (vp_height == vp_scroll) {
      element.on('touchmove', function() {
        return false;
      });
    } else {
      element.off('touchmove');
      if (vp_top === 0) {
        element.scrollTop(1);
      } else if (vp_bottom === vp_scroll) {
        element.scrollTop(vp_top-1);
      }
    }
  }
}

function fixViewportHeight() {
  var event;

  if (document.createEvent) {
    event = document.createEvent('HTMLEvents');
    event.initEvent('resize', true, true);
  } else {
    event = document.createEventObject();
    event.eventType = 'resize';
  }

  event.eventName = 'resize';

  if (document.createEvent) {
    window.dispatchEvent(event);
  } else {
    window.fireEvent('on' + event.eventType, event);
  }
}

// iOS web 키패드 이슈
var iOSKeypadCheck;
function removeIOSKeyPadEffectOnFocus(e) {
  if (userDevice.isIOS) {
    var wh = window.innerHeight;
    var st = 0;
    var th = wh;
    iOSKeypadCheck = setInterval(function() {
      st = document.body.scrollTop;     // 키패드 높이
      if (st > 0) {
        th = wh - st;
        if (!userApp) th += 10;
        $('html, body').css({ height: th });
        window.scrollTo(0, 0);
      }
    }, 1);
    setTimeout(function() {
      clearInterval(iOSKeypadCheck);
    }, 500);
  }
}

function removeIOSKeyPadEffectOnBlur(e) {
  if (userDevice.isIOS) {
    clearInterval(iOSKeypadCheck);
    setTimeout(function() {
      var th = window.innerHeight;
      $('html, body').css({ height: th });
      window.scrollTo(0, 0);
    }, 50);
  }
}

// Template Load
function load_template(title, callback) {
  if ($('#'+title+'_template').length === 0) {
    $.ajax({
      url: '/templates/'+title,
      dataType: 'HTML',
      method: 'GET',
      async: false,
      success: function(data) {
        $('.template_scripts').append(data);
        if (typeof callback === 'function') callback();
      },
      beforeSend: function() {
        loadingStart();
      },
      complete: function() {
        loadingEnd();
      }
    });
  } else {
    if (typeof callback === 'function') callback();
  }
}

// 노티스, 로딩바
function notify(msg, onclick){
  var notice_div = $('.notice_div');
  var notice_msg = $('.notice_msg');
  notice_div.stop().animate({ top: '-50px' }, 50, function() {
    notice_msg.html('').html(msg);
    notice_div.attr('onclick', onclick).animate({ top: '0px' }, 250, function() {
      notice_div.delay(3000).animate({ top: '-50px' }, 500, function() {
        notice_div.attr('onclick', 'return false;');
        notice_msg.html('');
      });
    });
  });
  notice_div.unbind('touchmove click').bind('touchmove click', function() {
    $(this).stop().animate({ top: '-50px' }, 250, function() {
      $(this).css({ height: '50px' });
    });
    return false;
  });
}

function loadingStart() {
  var loading_bar = $('.loading_bar');
  var loading_div = $('.loading_div');
  loading_div.removeClass('hidden');
  loading_bar.clearQueue().animate({ width: '90%' }, 1000, function() {
    loading_bar.animate({ width: '94%' }, 2000, function() {
      loading_bar.animate({ width: '98%' }, 8000);
    });
  });
}

function loadingEnd() {
  var loading_bar = $('.loading_bar');
  var loading_div = $('.loading_div');
  loading_bar.stop().animate({ width: '100%' }, 100, function() {
    loading_bar.delay(300).animate({ height: '0px' }, 100, function() {
      loading_bar.css({ width: '0%', height: '5px' });
      loading_div.addClass('hidden');
    });
  });
}

function loadingProgress() {
  var loading_div = $('.loading_div');
  var loading_bar = $('.loading_bar');
  var xhr = new window.XMLHttpRequest();
  xhr.upload.addEventListener('progress', function (e) {
      if (e.lengthComputable) {
          var percentComplete = e.loaded / e.total * 100 / 4 * 3;
          loading_div.removeClass('hidden');
          loading_bar.clearQueue().animate({ width: percentComplete + '%' }, 250);
      }
  }, false);
  xhr.addEventListener('progress', function (e) {
      if (e.lengthComputable) {
          var percentComplete = e.loaded / e.total * 100 / 4 * 1 + 75;
          loading_bar.clearQueue().animate({ width: percentComplete + '%' }, 250, function() {
            loading_bar.delay(300).animate({ height: '0px' }, 100, function() {
              loading_bar.css({ width: '0%', height: '5px' });
              loading_div.addClass('hidden');
            });
          });
      }
  }, false);
  return xhr;
}

// Alarm Check
var alarm_check_counter;
function alarm_check(last_alarm_count) {
  var alarm_count = last_alarm_count === undefined ? 0 : last_alarm_count;
  $.ajax({
    url: '/users/alarm_check.json',
    dataType: 'json',
    type: 'GET',
    error: function() {
      return false;
    },
    success: function(data) {
      current_user = data.current_user;
      alarm_count = data.alarm_count;
      if (current_user === null) {
        $('#login_tab').addClass('visitor');
      } else {
        $('#login_tab').removeClass('visitor');
      }
      if (alarm_count > 0) { $('.tab_badge').addClass('on').animateCss('wobble'); } else { $('.tab_badge').removeClass('on'); }
      if (last_alarm_count !== undefined && alarm_count > last_alarm_count) {
        user_alarms_on();
        if (!window.HybridApp) { notify('새로운 알림이 도착했습니다!', "go_seg(4); $('#footer').removeClass('hide'); open_user_alarms();"); }
      }
    },
    beforeSend: function() {
      clearInterval(alarm_check_counter);
    },
    complete: function() {
      alarm_check_counter = setInterval(function() { alarm_check(alarm_count); }, 60000);
    }
  });
}

// Image Load
function get_image_url(data, model_name, extention) {
	try {
		var image_url = 'http://vaskit.kr/assets/'+model_name+'/'+data.id+'/'+extention+'/';
    var image_file_name = data.image_file_name;
    if (image_file_name.indexOf('.') == -1) image_file_name += '.';
	  image_url += image_file_name;
	  return image_url;
	} catch(err) {
	  return '/images/custom/card_image_preview.png';
	}
}

function imgError(image, alter_url) {
  image.onerror = '';
  if (alter_url === undefined) alter_url = '/images/custom/card_image_preview.png';
  image.src = alter_url;
  return true;
}

function get_avatar(data) {
	try {
		var avatar_url = 'http://vaskit.kr/assets/users/'+data.id+'/original/';
    var avatar_file_name = data.avatar_file_name;
    if (avatar_file_name.indexOf('.') == -1) avatar_file_name += '.';
	  avatar_url += avatar_file_name;
	  return avatar_url;
	} catch(err) {
	  return '/images/custom/user_profile_preview.png';
	}
}


// 해쉬태그, 링크 하이라이트
function taggingKeywords(origin_string, img_hidden) {
  if (origin_string === null) return origin_string;

  var html_tmp = document.createElement('div');
  var html_txt = document.createTextNode(origin_string);
  html_tmp.id = 'taggingTmp';
  html_tmp.appendChild(html_txt);
  document.body.appendChild(html_tmp);
  html_tmp = $('#taggingTmp');

  var hash_tags = origin_string.match(/#([0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]+)/g);
  if (hash_tags !== null) {
    hash_tags.sort(function(a, b) { return b.length - a.length; });
    $.each(hash_tags, function(index, hash_tag) {
      hash_tag = hash_tag.replace(',', '');
      var keyword = hash_tag.replace('#', '').replace('?', '');
      html_tmp.highlight(hash_tag, {element: 'a', className: 'hash_tag ' + index});
      html_tmp.find('.hash_tag.' + index).html('').attr({
        href: '/search?type=hash_tag&keyword='+encodeURIComponent(keyword),
        onclick: "go_url('search_result', {type: 'hash_tag', keyword: '" + keyword + "'}); return false;",
        keyword: keyword
      });
    });
    $.each(html_tmp.find('.hash_tag'), function(index, element){
      var keyword = '#' + $(element).attr('keyword');
      $(element).append(keyword);
    });
  }
  var links = origin_string.match(/((http(s)?:\/\/)|(www))([\S]*)/g);
  if (links !== null) {
    links.sort(function(a, b) { return b.length - a.length; });
    var link_tags = [];
    var img_tags = [];
    var img_reg = /\.(jpg|jpeg|gif|bmp|png)/;
    $.each(links, function(index, link){
      if (img_reg.test(link)) {
        img_tags[img_tags.length] = link;
      } else {
        link_tags[link_tags.length] = link;
      }
    });
    if (img_tags.length > 0) {
      if (!img_hidden) {
        $.each(img_tags, function(index, link) {
          html_tmp.highlight(link, {element: 'a', className: 'link_img ' + index});
          html_tmp.find('.link_img.' + index).html('').attr({
            href: link,
            target: '_blank',
            onclick: 'window.event.cancelBubble = true;'
          }).append('<img>');
          html_tmp.find('.link_img.' + index + ' img').attr({
            src: link,
            onerror: 'imgError(this);'
          });
        });
        $.each(html_tmp.find('.link_img'), function(index, element) {
          var link = $(element).attr('href');
          $(element).append(link);
        });
      }
    }
    if (link_tags.length > 0) {
      $.each(link_tags, function(index, link) {
        html_tmp.highlight(link, {element: 'a', className: 'link_url ' + index});
        html_tmp.find('.link_url.' + index).html('').attr({
          href: link,
          target: '_blank',
          onclick: 'window.event.cancelBubble = true;'
        });
      });
      $.each(html_tmp.find('.link_url'), function(index, element) {
        var link = $(element).attr('href');
        $(element).append(link);
      });
    }
  }

  var html_output = html_tmp.html();
  html_tmp.remove();

  return html_output.replace(new RegExp(/^\s*/g), '')                             // 앞 공백 제거
                    .replace(new RegExp(/\s*$/g), '')                             // 뒷 공백 제거
                    .replace(new RegExp(/\r?\n/g), '<br>');       // 줄바꿈 처리
}

// Form 필수 입력값 체크
function form_check(form) {
  var fields = $.map(form.find('[required]'), function(value, index) { return [value]; });
  var check_boxs = $.map(form.find('[required][type=checkbox]'), function(value, index) { return [value]; });
  if ( fields.every(function (item, index) { return item.value.length > 0; }) && check_boxs.every(function (item, index) { return item.checked === true; }) ) {
    form.find('.submit_btn').addClass('ready');
  } else {
    form.find('.submit_btn').removeClass('ready');
  }
}

// 각종 표기법
function truncate(string, range) {
  if (range === undefined) range = 30;
  if (string.length > range)
    return string.substring(0, range)+'&middot;&middot;&middot;';
  else
    return string;
}

// 금액 필드 콤마찍기
function fieldWithBlank(text) {
  return (text === undefined || text === null || text.length === 0) ? '-' : text;
}

function fieldWithLink(link) {
  var tmpLink = document.createElement('a');
  tmpLink.href = link;
  tmpLink.text = tmpLink.host;
  tmpLink.target = '_blank';
  $(tmpLink).attr('onclick', 'window.event.cancelBubble = true;');
  return tmpLink;
}

function numberWithCommas(x) {
  if (x !== null && x !== undefined) x = x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  return x;
}

function inputNumberWithCommas(obj) {
  obj.value = comma(uncomma(obj.value));
  function comma(str) {
    str = String(str);
    return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
  }
  function uncomma(str) {
    str = String(str);
    return str.replace(/[^\d]+/g, '');
  }
}

function get_user_ages(birthday) {
  try {
    var ret = '';
    if (birthday === null || birthday === undefined || birthday === '') {
      ret = '기타';
    } else {
      var current_user_year = parseInt(birthday.split('-')[0]);
      var current_year = new Date().getFullYear();
      var user_age = current_year - current_user_year + 1;

      user_age = Math.floor(user_age/10) * 10;
      ret = user_age + '대';
    }
    return ret;
  } catch(err) {
    return '기타';
  }
}

function get_past_time(time) {
  if (time === null) return '';
  var start = new Date(time),
      end = new Date(),
      diff = new Date(end - start),
      month = Math.floor(diff / 1000 / 60 / 60 / 24 / 30),
      week = Math.floor(diff / 1000 / 60 / 60 / 24 / 7),
      day = Math.floor(diff / 1000 / 60 / 60 / 24),
      hour = Math.floor(diff / 1000 / 60 / 60),
      min = Math.floor(diff / 1000 / 60);

  if (month !== 0) {
      return month + '개월 전';
  } else if (week !== 0) {
      return week + '주 전';
  } else if (day !== 0) {
      return day + '일 전';
  } else if (hour !== 0) {
      return hour + '시간 전';
  } else if (min !== 0) {
      if (min < 60 && min >= 50) {
          return '50분 전';
      } else if (min < 50 && min >= 40) {
          return '40분 전';
      } else if (min < 40 && min >= 30) {
          return '30분 전';
      } else if (min < 30 && min >= 20) {
          return '20분 전';
      } else if (min < 20 && min >= 10) {
          return '10분 전';
      } else {
          return '방금 전';
      }
  } else {
      return '방금 전';
  }
}

// AJS추가 : just for fun...
// console.log('%c개발자형을 구합니다!', 'color: #FF7800; font-size: 4em; font-weight: bold; background-color: #ffe4a9; padding: 0 10px;');

// animateCSS
$.fn.extend({
  animateCss: function (animationName, callback) {
      var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
      $(this).addClass('animated ' + animationName).one(animationEnd, function() {
          $(this).removeClass('animated ' + animationName);
          if (typeof callback === 'function') callback();
      });
  },
  animateCssColor: function (animationName, color) {
      var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
      var origin_color = $(this).css('color');
      $(this).css('color',color).addClass('animated ' + animationName).one(animationEnd, function() {
          $(this).css('color',origin_color).removeClass('animated ' + animationName);
      });
  },
  animateCssHide: function (animationName, callback) {
      var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
      $(this).addClass('animated ' + animationName).one(animationEnd, function() {
          $(this).hide().off(animationEnd).removeClass('animated ' + animationName);
          if (typeof callback === 'function') callback();
      });
  },
  animateCssEmpty: function (animationName, callback) {
      var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
      $(this).addClass('animated ' + animationName).one(animationEnd, function() {
          $(this).empty().off(animationEnd).removeClass('animated ' + animationName);
          if (typeof callback === 'function') callback();
      });
  },
  animateCssRemove: function (animationName, callback) {
      var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
      $(this).addClass('animated ' + animationName).one(animationEnd, function() {
          $(this).remove();
          if (typeof callback === 'function') callback();
      });
  },
  transitionHide: function (callback) {
      var transitionEnd = 'webkitTransitionEnd mozTransitionEnd MSTransitionEnd oTransitionEnd transitionend';
      $(this).one(transitionEnd, function() {
          $(this).hide().off(transitionEnd);
          if (typeof callback === 'function') callback();
      });
  },
  transitionEmpty: function (callback) {
      var transitionEnd = 'webkitTransitionEnd mozTransitionEnd MSTransitionEnd oTransitionEnd transitionend';
      $(this).one(transitionEnd, function() {
          $(this).empty().off(transitionEnd);
          if (typeof callback === 'function') callback();
      });
  },
  transitionRemove: function (callback) {
      var transitionEnd = 'webkitTransitionEnd mozTransitionEnd MSTransitionEnd oTransitionEnd transitionend';
      $(this).one(transitionEnd, function() {
          $(this).remove();
          if (typeof callback === 'function') callback();
      });
  }
});

// textarea 내부 선택하기
$.fn.selectRange = function(start, end) {
  return this.each(function() {
    if (this.setSelectionRange) {
      this.focus();
      this.setSelectionRange(start, end);
    } else if (this.createTextRange) {
      var range = this.createTextRange();
      range.collapse(true);
      range.moveEnd('character', end);
      range.moveStart('character', start);
      range.select();
    }
  });
};

// input, textarea 값 복사하기
function copyfieldvalue(event, input_id){
  var input = document.getElementById(input_id);
  if (document.execCommand('copy')) {
    input.focus();
    input.setSelectionRange(0, input.value.length);
    document.execCommand('copy');
    input.blur();
    return true;
  } else if (window.clipboardData) {
    window.clipboardData.setData('Text', input.value);
    return true;
  } else {
    return false;
  }
}

// localStorage 지원 여부
function check_localStorage() {
  try {
    return 'localStorage' in window && window.localStorage !== null;
  } catch(err) {
    return false;
  }
}
