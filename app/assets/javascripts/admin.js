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
//= require bootstrap-sprockets
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
                var file_input = $(this).parentsUntil(this, '.form-group').find('input[type=file]');
                var dropped_files = e.originalEvent.dataTransfer.files;
                if (dropped_files[0].type.match(/image/i) !== null) {
                  file_input.prop('files', dropped_files);
                  file_input.next().attr('checked', true);
                } else {
                  alert('이미지 파일만 허용됩니다');
                }
              });
  }
}

function preview_thumbnail(file_input) {
  if (file_input.files && file_input.files[0]) {
    var reader = new FileReader();
    reader.onload = function(e) {
      file_input.parentElement.getElementsByTagName('img')[0].src = e.target.result;
      file_input.nextElementSibling.checked = true;
    };
    reader.readAsDataURL(file_input.files[0]);
  } else {
    file_input.nextElementSibling.checked = false;
  }
}

function preview_link(link_type, link_input, js_input, preview_div, preview_checkbox) {
  var host = 'http://' + window.location.host;
  var preview_frame = preview_div.find('iframe');
  if (link_type == 'VASKIT') {
    var link = link_input.val();

    if (link.match(host) !== null) {
      link_input.attr('readonly', true);
      js_input.removeClass('hidden').attr('placeholder', '로딩중...');
      preview_div.removeClass('hidden');
      preview_frame.attr('src', link).load(function(){
        js_input.attr('placeholder', '로딩완료!');
        preview_checkbox.prop('checked', true);
        var odjDoc = this.contentWindow || this.contentDocument;
        setTimeout(function(){
          var js_function = odjDoc.get_js_function();
          if (js_function === '') {
            js_input.attr('placeholder', '메인화면입니다').val('');
          } else {
            js_input.removeAttr('placeholder').val(js_function);
          }
          form_check(link_input);
        }, 1000);
      });
    } else {
      link_input.val(host).focus();
      alert('내부 링크를 입력해주세요');
    }
  } else {
    var content_id = link_input.val();
    var href;
    if (link_type == 'ask_id') {
      href = host + '/asks/' + content_id;
    } else if (link_type == 'facebook') {
      href = 'https://www.facebook.com/plugins/video.php?href=https%3A%2F%2Fwww.facebook.com%2Fvaskit.kr%2Fvideos%2F' + content_id;
    } else if (link_type == 'youtube') {
      href = 'https://www.youtube.com/embed/' + content_id;
    }
    if (content_id !== '') {
      preview_div.removeClass('hidden');
      preview_frame.attr('src', href);
      preview_checkbox.prop('checked', true);
    } else {
      preview_div.addClass('hidden');
      preview_frame.attr('src', '');
      link_input.val('').focus();
      preview_checkbox.prop('checked', false);
    }
  }
}

function preview_link_reset(link_type, link_input, js_input, preview_div, preview_checkbox) {
  var host = 'http://' + window.location.host;
  link_input.val(host).removeAttr('readonly');
  js_input.val('').addClass('hidden');
  preview_div.addClass('hidden');
  preview_checkbox.prop('checked', false);
  form_check(link_input);
}

function form_check(target) {
  var form = target[0].tagName.toLowerCase() == 'form' ? target : target.parentsUntil(this, 'form');
  var submit_btn = form.find('input[type=submit]');

  var fields = $.map(form.find('.required_form').not('[type=checkbox]'), function(value, index) { return [value]; });
  var check_boxs = $.map(form.find('.required_form[type=checkbox]'), function(value, index) { return [value]; });

  if (fields.every(function (field, index) { return field.value.length > 0; }) && check_boxs.every(function (check_box, index) { return check_box.checked === true; })) {
    submit_btn.removeAttr('disabled');
  } else {
    submit_btn.attr('disabled', true);
  }
}
