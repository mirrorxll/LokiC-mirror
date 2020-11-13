import consumer from "./consumer";

$(document).on('turbolinks:load', function () {
    let assembleds = $('#assembleds');

    if(!assembleds.length) return false;

    consumer.subscriptions.create("AssembledsChannel", {
        connected() { console.log('connect'); },
        disconnected() { console.log('disconnected'); },
        received(data) {
            document.getElementById(`link_assembled_${data['week_id']}`).innerHTML = `<div class='mt-1'><a target='_blank' href="${data.link}">Google sheets</a></div>`
        }
    });
});
