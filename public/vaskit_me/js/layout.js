$(document).ready(function(){
  $("#bar").css("height","100%").css("width","0%").animate({width:"100%"},2000).animate({height:"0%"},500);
  $("#loading_moment").delay(2000).fadeOut(500);

  // Hide Header on on scroll down
  var didScroll;
  var lastScrollTop = 0;
  var delta = 5;
  var navbarHeight = $("header").outerHeight();

  $(window).scroll(function(event){
      didScroll = true;
  });

  $(window).resize(function(){
    if (document.body.clientWidth < 1024) {
      setInterval(function() {
        if ($(window).scrollTop() + $(window).height() == $(document).height()) {
          $("header").removeClass('nav-up');
          $("#vaskit_btn_area").removeClass('nav-up');
        } else if (didScroll) {
          hasScrolled();
          didScroll = false;
        }
      }, 250);
    }
  }).resize();

  function hasScrolled() {
      var st = $(this).scrollTop();

      if(Math.abs(lastScrollTop - st) <= delta)
          return;

      if (st > lastScrollTop && st > navbarHeight){
          $("header").addClass('nav-up');
          $("#vaskit_btn_area").addClass('nav-up');
      } else {
          if(st + $(window).height() < $(document).height() ) {
              $("header").removeClass('nav-up');
              $("#vaskit_btn_area").removeClass('nav-up');
          }
      }
      lastScrollTop = st;
  }

  // 메뉴버튼 할당
  function menuClick(url) {
    $("#menu_btn_list>ul>a").removeClass("screen_on");
    $(window).scrollTop(0);
    $("#bar").css("height","100%").css("width","0%").animate({width:"100%"},500).animate({height:"0%"},400);
    $("#contents_area").fadeOut(200);
    $("#loading_moment").fadeIn(200);
    setTimeout(function(){
      $("#loading_moment").fadeOut(500);
      $("#contents_area").hide().load(url).fadeIn(500).removeClass("index");
    },200);
  }
  $("#menu_btn_list>ul>a").eq(0).on("click",function(){ menuClick("about_vaskit.html"); $(this).addClass("screen_on"); });
  $("#menu_btn_list>ul>a").eq(1).on("click",function(){ menuClick("about_team.html"); $(this).addClass("screen_on"); });
  $("#menu_btn_list>ul>a").eq(2).on("click",function(){ menuClick("member_wanted.html"); $(this).addClass("screen_on"); });
  $("#menu_btn_list>ul>a").eq(3).on("click",function(){ menuClick("faq_help.html"); $(this).addClass("screen_on"); });
  $("#menu_btn_list>ul>a").eq(4).on("click",function(){ menuClick("contact_us.html"); $(this).addClass("screen_on"); });

  // 모바일 메뉴버튼 여닫기
  $("#menu_btn_box").on("click",function(){
    $(this).addClass("menu_opened");
    $("#menu_btn_box_close").addClass("menu_opened");
    $("#menu_btn_list").addClass("menu_opened");
    $("#blur_screen").addClass("on");
    scrollDisabled();
  });
  $("#menu_btn_box_close,#menu_btn_list a,#blur_screen").on("click",function(){
    $("#menu_btn_box").removeClass("menu_opened");
    $("#menu_btn_box_close").removeClass("menu_opened");
    $("#menu_btn_list").removeClass("menu_opened");
    $("#blur_screen").removeClass("on");
    scrollDisabled();
  });


  // Blur Screen 스크롤 방지 스크립트
  function scrollDisabled() {
    if ($("#blur_screen").hasClass("on") || $("#mobile_landscape").hasClass("on")) {
      $(window).bind("mousewheel.disableScroll DOMMouseScroll.disableScroll touchmove.disableScroll", function(e){e.preventDefault()});
    } else {
      $(window).unbind("mousewheel.disableScroll DOMMouseScroll.disableScroll touchmove.disableScroll");
    }
  }

  // 가로 화면 막기
  $(window).resize(function(){
    // if (document.body.clientWidth < 800) {
      // var landscape = setInterval(function() {
        var screen_width = $("#mobile_landscape").width();
        var screen_height = $("#mobile_landscape").height();
        if (screen_width > screen_height) {
          if (document.body.clientWidth < 800) {
            $("#mobile_landscape").addClass("on");
            scrollDisabled();
          }
        } else {
          $("#mobile_landscape").removeClass("on");
          scrollDisabled();
        }
      // }, 250);
    // }
  }).resize();


  // SNS 셋트 링크 설정 > 링크 수정
  $("#facebook").attr("href","http://facebook.com/vaskit.kr").attr("target","_blank");
  $("#naver_blog").attr("href","     ").attr("target","_blank");
  $("#kakao_story").attr("href","     ").attr("target","_blank");


});
