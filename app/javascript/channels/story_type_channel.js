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
        if (data['population_msg']) {
            $.ajax({
                url: `${window.location.origin}/story_types/${storyTypeId}/staging_tables/section`,
                dataType: 'script'
            })
        }
    }

    function st_exp_configurations_section(data) {
        if (data['export_configurations_msg']) {
            $.ajax({
                url: `${window.location.origin}/story_types/${storyTypeId}/export_configurations/section`,
                dataType: 'script'
            })
        }
    }

    function st_samples_section(data) {
        let message = data['samples_msg'] || data['creation_msg'] || data['purge_last_creation_msg']
        if (message) {
            $.ajax({
                url: `${window.location.origin}/story_types/${storyTypeId}/iterations/${storyTypeIter}/samples/section`,
                data: { section_update: { message: message } },
                dataType: 'script'
            })
        }
    }

    function st_scheduler(data) {
        if (data['scheduler_msg'] || data['creation_msg']) {
            let params = data['scheduler_msg'] ? { section_update: { message: data['scheduler_msg'] } } : { section_update: { message: null } }
            $.ajax({
                url: `${window.location.origin}/story_types/${storyTypeId}/iterations/${storyTypeIter}/schedule/section`,
                data: params,
                dataType: 'script'
            })
        }
    }

    function st_export(data) {
        if (data['scheduler_msg'] || data['export_msg']) {
            $.ajax({
                url: `${window.location.origin}/story_types/${storyTypeId}/iterations/${storyTypeIter}/export/section`,
                dataType: 'script'
            })
        }
    }
});
