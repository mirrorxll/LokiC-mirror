import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let exportedFactoids = $('#iteration_exported_factoids');

    if(!exportedFactoids.length) return false

    let factoidTypeId = exportedFactoids.attr('factoid_type_id');
    let factoidTypeIterationId = exportedFactoids.attr('iteration_exported_factoids_id');

    consumer.subscriptions.create(
        {
            channel: "ExportedFactoidsChannel",
            factoid_type_iteration_id: factoidTypeIterationId
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
            url: `${window.location.origin}/factoid_types/${factoidTypeId}/iterations/${factoidTypeIterationId}/export/update_section`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
