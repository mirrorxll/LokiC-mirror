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
            received(data) { update_sections(data); }
        }
    )

    function update_sections(data) {
        $.ajax({
            url: `${window.location.origin}/story_types/${storyTypeId}/update_sections`,
            method: 'patch',
            dataType: 'script',
            data: data
        });
    }
});
