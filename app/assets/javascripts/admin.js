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

function drag_n_drop_img(target) {
  if ((('draggable' in target) || ('ondragstart' in target && 'ondrop' in target)) && 'FormData' in window && 'FileReader' in window) {
    $(target).on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
                e.preventDefault();
                e.stopPropagation();
              })
              .on('dragover dragenter', function(e) { $(this).addClass('bg-primary'); })
              .on('dragleave dragend drop', function(e) { $(this).removeClass('bg-primary'); })
              .on('drop', function(e) {
                var file_input = $(this).parentsUntil(this, ".form-group").find("input[type='file']");
                file_input.prop('files', e.originalEvent.dataTransfer.files);
                file_input.next().attr("checked", true);
              });
  }
}

function preview_thumbnail(file_input) {
  if (file_input.files && file_input.files[0]) {
    var reader = new FileReader();
    reader.onload = function(e) {
      file_input.parentElement.getElementsByTagName("img")[0].src = e.target.result;
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
