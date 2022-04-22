import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let articleType = $('#article_type');

    if(!articleType.length) return false

    let articleTypeId = articleType.attr('article_type_id');

    consumer.subscriptions.create(
        {
            channel: "ArticleTypeChannel",
            article_type_id: articleTypeId
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
            url: `${window.location.origin}/article_types/${articleTypeId}/update_sections`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
