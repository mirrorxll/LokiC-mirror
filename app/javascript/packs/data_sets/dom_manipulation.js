$(document).on('click', (".current_sheriff > a[href='#'], .current_responsible_editor > a[href='#']"), function (evt) {
    evt.preventDefault();
    $(this).parent().addClass('d-none');
    $(this).parent().next().removeClass('d-none');
    return false;
});
