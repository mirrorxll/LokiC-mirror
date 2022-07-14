// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");
require("trix");
require("@rails/actiontext");
require("datatables.net-bs4");
require('froala-editor/js/froala_editor.min')
require("froala-editor/js/plugins/align.min.js")
require("froala-editor/js/plugins/char_counter.min.js")
require("froala-editor/js/plugins/code_beautifier.min.js")
require("froala-editor/js/plugins/code_view.min.js")
require("froala-editor/js/plugins/colors.min.js")
require("froala-editor/js/plugins/emoticons.min.js")
require("froala-editor/js/plugins/entities.min.js")
require("froala-editor/js/plugins/file.min.js")
require("froala-editor/js/plugins/font_family.min.js")
require("froala-editor/js/plugins/font_size.min.js")
require("froala-editor/js/plugins/fullscreen.min.js")
require("froala-editor/js/plugins/help.min.js")
require("froala-editor/js/plugins/image.min.js")
require("froala-editor/js/plugins/image_manager.min.js")
require("froala-editor/js/plugins/inline_class.min.js")
require("froala-editor/js/plugins/inline_style.min.js")
require("froala-editor/js/plugins/line_breaker.min.js")
require("froala-editor/js/plugins/line_height.min.js")
require("froala-editor/js/plugins/link.min.js")
require("froala-editor/js/plugins/lists.min.js")
require("froala-editor/js/plugins/paragraph_format.min.js")
require("froala-editor/js/plugins/paragraph_style.min.js")
require("froala-editor/js/plugins/print.min.js")
require("froala-editor/js/plugins/quick_insert.min.js")
require("froala-editor/js/plugins/quote.min.js")
require("froala-editor/js/plugins/save.min.js")
require("froala-editor/js/plugins/table.min.js")
require("froala-editor/js/plugins/special_characters.min.js")
require("froala-editor/js/plugins/url.min.js")
require("froala-editor/js/plugins/video.min.js")
require("froala-editor/js/third_party/embedly.min.js")
require("froala-editor/js/third_party/font_awesome.min.js")
require("froala-editor/js/third_party/image_tui.min.js")
require("froala-editor/js/third_party/spell_checker.min.js")

import 'bootstrap';
import Rails from "@rails/ujs";
import cronstrue from 'cronstrue';
import datepicker from 'bootstrap-datepicker';
import multipleSelect from 'multiple-select';
import Chart from 'chart.js/auto';
import 'select2'

import '../stylesheets/application';

global.Chart = Chart;
global.toastr = require("toastr")
window.FroalaEditor = require('froala-editor');
window.Rails = Rails;
window.jQuery = $;
window.$ = $;
window.cronValidator = require('cron-validator');
window.cronstrue = cronstrue;

document.addEventListener('turbolinks:load', () => {
  // Datepicker for Tasks-Deadline filter field (selects only date)
  $('input[type=datetime]').datepicker({
    format: 'yyyy-mm-dd'
  });

  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover({sanitize: false});

  $('body').on('click', function (e) {
    if ($(e.target).data('toggle') !== 'popover' && $(e.target).parents('.popover.fade.show').length === 0)
      $('[data-toggle="popover"]').popover('hide');
  });

  window.setTimeout(function() {
    $(".headerAlert, .headerNotice").fadeTo(500, 0).slideUp(500, function(){
      $(this).remove();
    });
  }, 15000);
});
