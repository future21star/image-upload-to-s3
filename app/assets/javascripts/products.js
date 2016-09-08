var ready = function() {  
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    var progressBar  = $("<div class='bar'></div>");
    var barContainer = $("<div class='progress'></div>").append(progressBar);
    barContainer.css('margin-top', '30px').css('margin-left', '5px');

    fileInput.after(barContainer);
    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('url'),
      type:            'POST',
      autoUpload:       true,
      formData:         form.data('form-data'),
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: false,
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        progressBar.css('width', progress + '%')
      },
      start: function (e) {
        submitButton.prop('disabled', true);

        progressBar.
          css('background', 'green').
          css('display', 'block').
          css('width', '0%').
          text("Loading...");
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);
        progressBar.text("Uploading done");

        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = '//' + form.data('host') + '/' + key;

        // create hidden field
        var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url })
        var image_div = $($('.app-link.article-icon.field')[parseInt(fileInput.prop("id")[fileInput.prop("id").length - 2])]);
        image_div.css("background", 'url(' + url + ')');
        image_div.css("background-size", "80px 80px");
        var img_src = $("<img />", { class:"uploaded_image", src: url});
        img_src.css("display","none");
        progressBar.css("display", "none");
        image_div.append(img_src);
        $(image_div.find(".del_photo")).css("display","block");
        image_div.append(input);

        $('img.image-view-src').prop('src', url);
      },
      fail: function(e, data) {
        submitButton.prop('disabled', false);

        progressBar.
          css("background", "red").
          text("Failed");
      }
    });
  });
  $("img#remove_image").click(function(){
    $(this).parent().parent().find("input").remove();
    var remove_input = $('<input type="hidden" class="remove" name="remove" value="1"></input>');
    $(".directUpload").append(remove_input);
    $(".directUpload").submit();
  });
  $('.add-image').unbind('click').bind("click",function(){
    if (parseInt($(".add-image-value").prop("value")) < 10)
    {
      var click_button = $('.file_upload_submit')[$(".add-image-value").prop("value")];
      $(click_button).click();
      $(".add-image-value").prop("value", parseInt($(".add-image-value").prop("value")) + 1);
    }
  });
  $('div.app-link.article-icon.field').click(function(){

    $('img.image-view-src').prop('src', $($(this).find(".uploaded_image")).prop("src"));
  });
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);

