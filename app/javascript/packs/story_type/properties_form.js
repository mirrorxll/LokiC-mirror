$(document).on('click', 'button#fill_clients', function() {
    let story_type_id = $('#story_type').attr('story_type_id');
    let oppo_id = $('#default_opportunity_opportunity_id').val();
    let oppo_type_id = $('#default_opportunity_opportunity_type_id').val();
    let content_type_id = $('#default_opportunity_content_type_id').val();

    let params = `update_opportunities[opportunity_id]=${oppo_id}&` +
                 `update_opportunities[opportunity_type_id]=${oppo_type_id}&` +
                 `update_opportunities[content_type_id]=${content_type_id}`

    Rails.ajax({
        type: "PATCH",
        dataType: 'json',
        url: `/story_types/${story_type_id}/default_opportunities/update_opportunities`,
        data: params
    })
});
