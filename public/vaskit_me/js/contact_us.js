$(document).ready(function(){
  $(".contents_box").on("click",function(e){
    e.preventDefault();
    $("#user_title").focus();
  })
  $("#user_title, #user_detail, #user_contact").on("change",function(){
    $(this).addClass("input_completed");
  })
  $("#user_detail").on("change",function(){
    $("#submit_btn").addClass("submit_ready");
  })
  $("#contact_us_form").on("submit",function(){
    var form_data = $(this).serialize();
    $.ajax({
      url:"contact_us.php",
      type:"post",
      data:form_data,
      async:false,
      success:function(result){
        $("#form_submitted").addClass("submit_completed");
        $(".submit_completed").on("click",function(){
          $(this).removeClass("submit_completed");
          $("#contact_us_form").each(function(){
            this.reset();
          });
        });
      }
    });
    return false;
  })
});
