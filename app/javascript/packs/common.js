document.addEventListener('turbolinks:before-cache', function() { toastr.remove(); });

// changing status of story_type or factoid_type
$(document).on('change', ('form#progress_status'), function() {
    let subject = $('#story_type').length > 0 ? 'story_type' : 'factoid_type';
    let entity_id = $(`#${subject}`).attr(`${subject}_id`);
    let status = $('#status_id option:selected');
    let statusVal = status.text();
    let statusId = status.val();
    let reason = null;
    if (jQuery.inArray(statusVal, ['blocked', 'archived']) >= 0) {
        reason = prompt(`Status '${statusVal}' :(\nWhy?`);

        if(!reason) return false;
    }

    Rails.ajax({
        type: 'PATCH',
        dataType: 'script',
        url: `${window.location.origin}/${subject + 's'}/${entity_id}/progress_statuses/change`,
        data: `status_id=${statusId}` + (reason ? `&reason=${reason}` : '')
    });
});
