import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let factoidType = $('#factoid_type');

    if(!factoidType.length) return false

    let factoidTypeId = factoidType.attr('factoid_type_id');

    consumer.subscriptions.create(
        {
            channel: "FactoidTypeChannel",
            factoid_type_id: factoidTypeId
        },
        {
            connected()    { console.log('connected'); },
            disconnected() { console.log('disconnected'); },
            received(data) {
                if (data.spinner){
                    showSpinner(data);
                } else {
                    update_sections(data);
                }
            }
        }
    )

    function showSpinner(data) {
        $(`#${data.section} > .card-body`).html("<div class=\"small text-center\">\n" +
            "<div class=\"spinner-border text-dark text-center\" role=\"status\"></div>\n" +
            "<div class=\"font-weight-bold\">\n" +
            data.message + "\n" +
            "</div>\n" +
            "</div>")
    }

    function update_sections(data) {
        $.ajax({
            url: `${window.location.origin}/factoid_types/${factoidTypeId}/update_sections`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
