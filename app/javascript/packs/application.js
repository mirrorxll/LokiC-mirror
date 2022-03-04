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

import 'bootstrap';
import '../stylesheets/application';
import './froala';
import Rails from "@rails/ujs";
import cronstrue from 'cronstrue';
import datepicker from 'bootstrap-datepicker';
import multipleSelect from 'multiple-select';
import Chart from 'chart.js/auto';

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
});

// document.addEventListener('turbolinks:load', () => {
//   // let myChartBar = $('#myChartBar');
//   //
//   // if(!myChartBar.length) return false;
//
//   let ctx = document.getElementById('myChartBar').getContext('2d');
//   console.log('44444444444444444444444444');
//   let myChart = new Chart(ctx, {
//     type: 'bar',
//     options: { indexAxis: 'y' },
//     data:
//     {
//         labels: JSON.parse(ctx.canvas.dataset.labels),
//         datasets: JSON.parse(ctx.canvas.dataset.data)
//     }
//   });
// })

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
