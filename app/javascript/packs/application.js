// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import 'bootstrap'
import "@fortawesome/fontawesome-free/js/all";
import '../stylesheets/application'
import './summernote'
import Rails from "@rails/ujs";
import cronstrue from 'cronstrue'
import './froala'

window.Rails = Rails;
window.jQuery = $;
window.$ = $;
window.cronValidator = require('cron-validator')
window.cronstrue = cronstrue

document.addEventListener('turbolinks:load', () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover({sanitize: false})

  $('body').on('click', function (e) {
    if ($(e.target).data('toggle') !== 'popover' && $(e.target).parents('.popover.fade.show').length === 0)
      $('[data-toggle="popover"]').popover('hide');
  });
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
