$(document).ready(function(){
  $(".contents_box").on("click",function(e){
    e.preventDefault();
  })
  $("#faq_help .question").on("click",function(){
    $("#faq_help .question").not(this).removeClass("on");
    $("#faq_help .question").not(this).next().removeClass("on");
    $(this).toggleClass("on");
    $(this).next().toggleClass("on");
  })
  $("#faq_help .answer").on("click",function(){
    $("#faq_help .question").removeClass("on");
    $(this).removeClass("on");
  })
  $("#help_more").on("click",function(){
    $("#menu_btn_list>ul>a").removeClass("screen_on");
    $("#menu_btn_list>ul>a").eq(4).addClass("screen_on");
    $("#contents_area").load("contact_us.html");
  })

});
