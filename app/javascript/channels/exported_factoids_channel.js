import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let exportedFactoids = $('#iteration_exported_factoids');

    if(!exportedFactoids.length) return false

    let articleTypeIterationId = exportedFactoids.attr('iteration_exported_factoids_id');

    consumer.subscriptions.create(
        {
            channel: "ExportedFactoidsChannel",
            article_type_iteration_id: articleTypeIterationId
        },
        {
            connected()    { console.log('connected'); },
            disconnected() { console.log('disconnected'); },
            received(data) {
                if (data.spinner){
                    showSpinner(data);
                } else {
                    update_section(data);
                }
            }
        }
    )

    function showSpinner(data) {
        $(`#${data.section}`).html("<div class=\"small text-center\">\n" +
            "<div class=\"spinner-border text-dark text-center\" role=\"status\"></div>\n" +
            "<div class=\"font-weight-bold\">\n" +
            data.message + "\n" +
            "</div>\n" +
            "</div>")
    }

    function update_section(data) {
        $.ajax({
            url: `${window.location.origin}/article_types/8/iterations/${articleTypeIterationId}/export/update_section`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
