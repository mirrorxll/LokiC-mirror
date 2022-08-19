$(document).on('click', 'input#update_opportunities', function(event) {
    event.preventDefault();
    let story_type_id = $('#story_type').attr('story_type_id');
    let oppo_id = $('#default_opportunity_opportunity_id').val();
    let oppo_type_id = $('#default_opportunity_opportunity_type_id').val();
    let content_type_id = $('#default_opportunity_content_type_id').val();

    let params = `update_opportunities[opportunity_id]=${oppo_id}&` +
                 `update_opportunities[opportunity_type_id]=${oppo_type_id}&` +
                 `update_opportunities[content_type_id]=${content_type_id}`

    Rails.ajax({
        type: 'PATCH',
        dataType: 'json',
        url: `/story_types/${story_type_id}/default_opportunities/update_opportunities`,
        data: params
    })
});

$(document).on('shown.bs.modal', '#storyTypePropertiesForm', function () {
    enableDisabledButton();
});

$(document).on('change', '#default_opportunity_opportunity_id, #default_opportunity_opportunity_type_id, #default_opportunity_content_type_id', function() {
    enableDisabledButton();
});

$(document).on('click', "input[value='update opportunity list']", function() {
    enableDisabledButton();
});

$(window).on('load ajaxStop', function() {
    enableDisabledButton();
});

function enableDisabledButton() {
    let opportunity = $('#default_opportunity_opportunity_id').val();
    let opportunity_type = $('#default_opportunity_opportunity_type_id').val();
    let content_type = $('#default_opportunity_content_type_id').val();

    if (opportunity && opportunity.length > 0 && opportunity_type.length > 0 && content_type.length > 0) {
        $('#update_opportunities').attr('disabled', false);
    } else {
        $('#update_opportunities').attr('disabled', true);
    }
}
