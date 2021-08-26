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
            received(data) { update_sections(data); }
        }
    )

    function update_sections(data) {
        $.ajax({
            url: `${window.location.origin}/article_types/${articleTypeId}/update_sections`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
