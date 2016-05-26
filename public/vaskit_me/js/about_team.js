$(document).ready(function(){
  $("#about_team a").on("click",function(e){
    e.preventDefault();
  });

  function scrolling(objectName) {
    $(window).on("scroll",function(){
      var scroll = $(window).scrollTop();
      var windowHeight = $(window).height();
      var objectTop = objectName.offset().top;
      var objectHeight = objectName.height();
      if (objectTop + objectHeight > scroll + windowHeight * 0.5 && objectTop < scroll + windowHeight * 0.5 ) {
        $(objectName).addClass("scroll");
      } else {
        $(objectName).removeClass("scroll");
      }
    })
  }
  
  scrolling($(".team_intro_1"));
  scrolling($(".team_intro_2"));
  scrolling($(".team_intro_3"));
  scrolling($(".team_motto").eq(0));
  scrolling($(".team_motto").eq(1));
  scrolling($(".team_motto").eq(2));
  scrolling($(".team_motto_quote"));
  scrolling($(".team_member").eq(0));
  scrolling($(".team_member").eq(1));
  scrolling($(".team_member").eq(2));
  scrolling($(".team_member").eq(3));
  scrolling($(".row").eq(0));
  scrolling($(".row").eq(1));
  scrolling($(".row").eq(2));
  scrolling($(".row").eq(3));
  scrolling($(".row").eq(4));
  scrolling($(".row").eq(5));
  scrolling($(".row").eq(6));
});
