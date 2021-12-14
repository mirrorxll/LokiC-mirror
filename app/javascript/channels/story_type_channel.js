import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let storyType = $('#story_type');

    if(!storyType.length) return false

    let storyTypeId = storyType.attr('story_type_id');

    consumer.subscriptions.create(
        {
            channel: "StoryTypeChannel",
            story_type_id: storyTypeId
        },
        {
            connected()    { console.log('connected'); },
            disconnected() { console.log('disconnected'); },
            received(data) {
                console.log(data);

                if (data.spinner){
                    showSpinner(data);
                } else {
                    update_sections(data);
                }
            }
        }
    )

    function showSpinner(data) {
        $('#staging_table > .card-body').html("<div class=\"small text-center\">\n" +
            "<div class=\"spinner-border text-dark text-center\" role=\"status\"></div>\n" +
            "<div class=\"font-weight-bold\">\n" +
            data['message'] + "\n" +
            "</div>\n" +
            "</div>")
    }

    function update_sections(data) {
        $.ajax({
            url: `${window.location.origin}/story_types/${storyTypeId}/update_sections`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
