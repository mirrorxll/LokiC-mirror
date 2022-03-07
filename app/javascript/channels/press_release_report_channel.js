import consumer from "./consumer";

$(document).on('turbolinks:load', function () {
  let press_release_reports = $('#press_release_report');

  if(!press_release_reports.length) return false;

  consumer.subscriptions.create("PressReleaseReportChannel", {
    connected() { console.log('connect'); },
    disconnected() { console.log('disconnected'); },
    received(data) {
      $.ajax({
               url: `/press_release_report/show_report`,
               method: 'post',
               dataType: 'script',
               data: { clients_names: data['clients_names'],
                       for_bar: data['for_bar'],
                       clients_counts: data['clients_counts'],
                       max_week: data['max_week'] }
             })
    }
  });
});

