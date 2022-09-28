$(document).on('click', '.up', function () {
    const currItem = $(this).parents('li');
    const currentPosition = parseInt(currItem.attr('data-position'));
    let nextPosition;
    let nextItem;
    if (currentPosition !== 0) {
        nextPosition = currentPosition - 1;
        nextItem = currItem.prev();
        currItem.insertBefore(nextItem);
        currItem.attr('data-position', nextPosition);
        nextItem.attr('data-position', currentPosition);
    } else {
        return;
    }
});

$(document).on('click', '.down', function () {
    console.log($(this));
    const currItem = $(this).parents('li');
    const currentPosition = parseInt(currItem.attr('data-position'));
    const itemsLength = $('li[data-position]').length
    let nextPosition;
    let nextItem;
    if (currentPosition !== itemsLength - 1) {
        nextPosition = currentPosition + 1;
        nextItem = currItem.next();
        currItem.insertAfter(nextItem);
        currItem.attr('data-position', nextPosition);
        nextItem.attr('data-position', currentPosition);
    } else {
        return;
    }
});

$(document).on('click', '#applyListSorting', function () {
    let newOrder = {};
    let subject;
    const urlSearchParams = new URLSearchParams(window.location.search).get('list');
    // console.log(urlSearchParams);
    $('li[data-position]').each(function () {
        const currentPosition = parseInt($(this).attr('data-position'));
        const currentList = $.trim($(this).text());
        subject = $(this).attr('data-subject');
        newOrder[currentList] = currentPosition;
    });
    let myData = { subject: subject, data: newOrder, current_list: urlSearchParams }
    // if (typeof urlSearchParams !== 'undefined') {
    //     $.merge(myData, { current_list: urlSearchParams })
    // }
    $("[data-toggle='popover']").popover('hide');
    $.ajax({
        url: `${window.location.origin}/reorder_lists`,
        type: 'PATCH',
        dataType: 'script',
        data: myData
    });
});
