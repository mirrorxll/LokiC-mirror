$(document).on('turbolinks:load', function() {
    let spinner = $("[role='status'].spinner-border.text-dark.text-center");
    if (spinner.length > 0) { hideElements(); }
});

$(document).on('click', ('input#start_population'), function() {
    hideElements();
});

function hideElements() {
    $('#story_type_iterations').addClass('d-none');
    $('#story_type_properties > .card-header > form').addClass('d-none');
    $('#story_type_code').addClass('d-none');
}
