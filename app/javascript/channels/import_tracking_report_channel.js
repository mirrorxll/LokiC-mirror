import consumer from "./consumer";

$(document).on('turbolinks:load', function () {
    let report_tracking_hour = $('#report_tracking_hour');

    if(!report_tracking_hour.length) return false;

    consumer.subscriptions.create("ImportTrackingReportChannel", {
        connected() { console.log('connect'); },
        disconnected() { console.log('disconnected'); },
        received(data) {
            let developers_hours = $('#developers-hours');
            developers_hours.html('');
            for (const elem in data){
                var id_row = data[elem].id;
                developers_hours.append(`     
                    <div class="text-center" id="row_${id_row}">
                        <div class="row">
                            <div class="col-1">${data[elem].hours}</div>
                            <div class="col-3">${data[elem].type_of_work}</div>
                            <div class="col-2">${data[elem].client}</div>
                            <div class="col-2">${data[elem].date}</div>
                            <div class="col-3 text-left">${data[elem].comment}</div>
                            <div class="col-1">
                                <a style="color:black;" data-remote="true" rel="nofollow" data-method="delete" href="/tracking_hours/${id_row}/exclude_row"><svg class="svg-inline--fa fa-minus fa-w-14" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="minus" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" data-fa-i2svg=""><path fill="currentColor" d="M416 208H32c-17.67 0-32 14.33-32 32v32c0 17.67 14.33 32 32 32h384c17.67 0 32-14.33 32-32v-32c0-17.67-14.33-32-32-32z"></path></svg><!-- <i class="fas fa-minus fas fa-minus"></i> --></a>
                            </div>
                        </div>
                        <hr>
                    </div>`)
            }
        }
    });
});
