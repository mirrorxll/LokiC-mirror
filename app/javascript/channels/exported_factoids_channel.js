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
        $('#cover-spin').show();
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
