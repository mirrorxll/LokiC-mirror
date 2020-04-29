// This method calls in views:
// population/_block_manipulate_buttons.html
// population/_form.html.haml

function blockManipBtn() {
    // Disable manipulate buttons on-time work population
    $('#sync :first-child').addClass('disabled');
    $('#manipulate').children().each(function() { $(this).addClass('disabled'); });
    $('#edit_columns :first-child').addClass('disabled');

    let editIndexBtn = $('#edit_index :first-child')

    if(!editIndexBtn.hasClass('disabled'))
        editIndexBtn.addClass('populate disabled');
}