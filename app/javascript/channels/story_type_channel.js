import consumer from "./consumer";

$(document).on("turbolinks:load", function() {
    let storyType = $('#story_type');

    if(!storyType.length) return false

    let storyTypeId = storyType.attr('story_type_id');
    let storyTypeIter = storyType.attr('iteration_id')

    consumer.subscriptions.create(
        {
            channel: "StoryTypeChannel",
            story_type_id: storyTypeId
        },
        {
            connected()    { console.log('connected'); },
            disconnected() { console.log('disconnected'); },
            received(data) { update_statuses(data); }
        }
    )

    function update_statuses(data) {
        st_population(data);
        st_exp_configurations_section(data);
        st_samples_section(data);
        st_scheduler(data);
        st_export(data);
    }

    function st_population(data) {
        if (data['population_msg'])
            $.ajax({url: `${storyTypeId}/staging_tables/section`})
    }

    function st_exp_configurations_section(data) {
        if (data['export_configurations_msg'])
            $.ajax({url: `${storyTypeId}/export_configurations/section`})
    }

    function st_samples_section(data) {
        if (data['samples_msg'] || data['creation_msg'] || data['purge_last_creation_msg'])
            $.ajax({url: `${storyTypeId}/iterations/${storyTypeIter}/samples/section`})
    }

    function st_scheduler(data) {
        if ([true, false].includes(data['scheduler_msg']) || data['creation_msg'])
            $.ajax({url: `${storyTypeId}/iterations/${storyTypeIter}/schedule/section`})
    }

    function st_export(data) {
        if (data['scheduler_msg'] || data['export_msg'])
            $.ajax({url: `${storyTypeId}/iterations/${storyTypeIter}/export/section`})
    }
});
