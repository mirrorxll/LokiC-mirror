let submit = $('#columns_editable input[type="submit"]')[0];
$('#add_column').click(function () {
    let hex = secureRandom(6);

    $(submit).before(
        `<div id="col_${hex}" class="mb-1">
            <div class=" remove_column d-inline-block mr-1" id="rm_col_${hex}""><i class="fas fa-minus"></i></div>
            <input placeholder="name" id="columns_${hex}_name" required="required" type="text" name="columns[${hex}[name]]">
            <select class="h_25px" id="columns_${hex}_type" name="columns[${hex}[type]]">
                <option selected="selected" value="string">string</option>
                <option value="text">text</option>
                <option value="integer">integer</option>
                <option value="float">float</option>
                <option value="decimal">decimal</option>
                <option value="datetime">datetime</option>
                <option value="timestamp">timestamp</option>
                <option value="time">time</option>
                <option value="date">date</option>
                <option value="boolean">boolean</option></select>
            </select>
            <div class="d-inline-block">
                <input class="w_80px" placeholder="limit" onclick="showInfo(this);"
                       id="columns_${hex}_params_limit" type="text"
                       name="columns[${hex}[options[limit]]]">
            </div>
        </div>`
    );

    $(`[id="rm_col_${hex}"]`).click(function (event){
        removeColumn(event.currentTarget);
    })

    $(`[id="columns_${hex}_type"]`).click(function (event){
        optionsForColumnType(event.currentTarget)
    })
});

$('[id*="rm_col_"]').click(function (event){
    removeColumn(event.currentTarget);
    return false;
})

function secureRandom(n){
    let result = '';
    while (n--){
        result += Math.floor(Math.random()*16).toString(16);
    }

    return result;
}

function removeColumn(elem) {
    $(elem.parentNode).remove();
}

function optionsForColumnType(elem) {
    let parent = elem.parentNode;
    let hex = parent.id.split('_')[1]
    while (parent.childElementCount > 3)
        $(elem).next().remove();

    switch (elem.options[elem.selectedIndex].value) {
        case 'string':
        case 'text':
        case 'integer':
        case 'float':
            $(parent).append(`
          <div class="d-inline-block">
            <input class="w_80px" placeholder="limit" type="text" onclick="showInfo(this);"
              name="columns[${hex}[options[limit]]]" id="columns_${hex}_params_limit">
          </div>
        `);
            break;
        case 'decimal':
            $(parent).append(`
          <div class="d-inline-block">
            <input class="w_80px" placeholder="precision" type="text" onclick="showInfo(this);"
              name="columns[${hex}[options[precision]]]" id="columns_${hex}_params_precision">
            <input class="w_80px" placeholder="scale" type="text" onclick="showInfo(this);"
              name="columns[${hex}[options[scale]]]" id="columns_${hex}_params_scale">
          </div>
        `);
            break;
        case 'datetime':
        case 'time':
            $(parent).append(`
          <div class="d-inline-block">
            <input class="w_80px" placeholder="precision" type="text" onclick="showInfo(this);"
              name="columns[${hex}[options[precision]]]" id="columns_${hex}_params_precision">
          </div>
        `);

            break;
    }
}

function showInfo(elem) {
    let info = ''
    let select = elem.parentNode.parentNode.querySelector("select")
    let selected = select.options[select.selectedIndex].value

    switch (selected) {
        case 'string':
            info = '<b>string</b></br>' +
                'Usual SQL varchar. Limit can set between 1 and 3000.</br>' +
                'if you leave the field empty it will be set to 255.'
            break;
        case 'text':
            info = '<b>text</b></br>' +
                'limit values:</br>' +
                '256 - tinytext</br>' +
                '65535 - text</br>' +
                '16777215 - mediumtext</br>' +
                '4294967295 - longtext</br>' +
                'if you leave the field empty it will be set to 65535.'
            break;
        case 'integer':
            info = '<b>integer</b></br>' +
                'limit values:</br>' +
                '1 - tinyint</br>' +
                '2 - smallint</br>' +
                '3 - mediumint</br>' +
                '4 - int</br>' +
                '8 - bigint</br>' +
                'if you leave the field empty it will be set to 4.'
            break;
        case 'float':
            info = '<b>float</b></br>' +
                'limit value is 24.'
            break;
        case 'decimal':
            info = '<b>decimal</b></br>' +
                'precision - the total number of digits in a decimal number, both before and after the decimal point.</br>' +
                'scale - The total number of digits after the decimal point in a number.'
            break;
        case 'time':
        case 'datetime':
            info = '<b>datetime/time</b></br>' +
                'The datetime/time precision specifies number of digits after the decimal point and can be any integer number from 0 to 6.'
            break;
        case 'timestamp':
        case 'date':
        case 'boolean':
            break;
    }

    document.getElementById('column_info').innerHTML = info
}
