import consumer from "./consumer";

$(document).on('turbolinks:load', function () {
    let report_tracking_hour = $('#report_tracking_hour');

    if(!report_tracking_hour.length) return false;

    let developer_id = report_tracking_hour.attr('developer_id');
    let week_id = report_tracking_hour.attr('week_id');

    consumer.subscriptions.create("ImportTrackingReportChannel", {
        connected() { console.log('connect'); },
        disconnected() { console.log('disconnected'); },
        received(data) {
            $.ajax({
                url: `${window.location.origin}/tracking_hours/dev_hours?developer=${developer_id}&week=${week_id}`,
                dataType: 'script'
            })
        }
    });
});
