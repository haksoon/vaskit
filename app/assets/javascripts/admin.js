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
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require_tree ./admin

// init Template
_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

function preview_thumbnail(file_input, thumbnail_image) {
  if (file_input.files && file_input.files[0]) {
    var reader = new FileReader();
    reader.onload = function(e) {
      thumbnail_image.attr("src", e.target.result);
      file_input.nextElementSibling.checked = true;
    };
    reader.readAsDataURL(file_input.files[0]);
  } else {
    file_input.nextElementSibling.checked = false;
  }
}

function form_check(form) {
  var submit_btn = form.find("input[type=submit]");

  var fields = $.map(form.find(".required_form").not("[type=checkbox]"), function(value, index) { return [value]; });
  var check_boxs = $.map(form.find(".required_form[type=checkbox]"), function(value, index) { return [value]; });

  if (fields.every(function (field, index) { return field.value.length > 0; }) && check_boxs.every(function (check_box, index) { return check_box.checked === true; })) {
    submit_btn.removeAttr("disabled");
  } else {
    submit_btn.attr("disabled", true);
  }
}
