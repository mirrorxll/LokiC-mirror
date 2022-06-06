$(document).on('change', ("input[type='checkbox']"), function() {
    var checked = $("input[type='checkbox']:checked");
    var disabled_button = $('button#delete_selected');

    if (checked.length > 0) {
        disabled_button.attr('disabled', false)
    } else {
        disabled_button.attr('disabled', true)
    }
});

$(document).on('click', ('button#select_all_button'), function() {
    var disabled_button = $('button#delete_selected');
    var trigger = $('input#trigger');
    if (trigger.val()) {
        console.log('------------------');
        $("input[type='checkbox']").each(function() {
            this.checked = false;
        });
        this.textContent = 'Select All';
        trigger.value = false;
    } else {
        console.log('+++++++++++++++++');

        $("input[type='checkbox']").each(function() {
            this.checked = true;
        });
        this.textContent = 'Deselect All';
        disabled_button.attr('disabled', false);
        trigger.value = true;
    }
});

$(document).on('click', ('button#delete_selected'), function() {
    if (!confirm('Are you sure?')) return;

    var values = [];
    var iteration_id = $('#iteration_exported_factoids').attr('iteration_exported_factoids_id');
    var article_types_id = $('#iteration_exported_factoids').attr('article_type_id');

    document.querySelectorAll("input[type='checkbox']").forEach(elem => {
        if (elem.checked) {
            values.push(elem.id)
        }
    });

    Rails.ajax({
        type: 'DELETE',
        dataType: 'script',
        url: `${window.location.origin}/article_types/${article_types_id}/iterations/${iteration_id}/export/remove_selected_factoids`,
        data: `factoids_ids=${values}`
    })
});