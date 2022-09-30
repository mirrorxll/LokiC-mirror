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

// editing comment of story_type or factoid_type
$(document).on('show.bs.collapse', ('#commentForm'), function() {
    $("textarea[id$='_type_comment']") .froalaEditor({
        key: 'KfdolbcqsaA2wzA-13==',
        editorClass: 'border rounded p-2',
        toolbarInline: true,
        toolbarButtons: ['undo', 'redo', '|', 'bold', 'italic', 'underline', 'strikeThrough', '|', 'color', 'lineHeight', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'insertLink', 'insertImage'],
        imageUploadURL: '/images/upload',
        imageUploadMethod: 'POST',
        toolbarVisibleWithoutSelection: false,
        zIndex: 3333,
        heightMin: 100,
        placeholderText: 'Type here....'
    })
});
