$(document).on('turbolinks:load', function () {
    $('#add-column').on('click', function () {
        let editable_block = $('#columns-editable');
        let count = editable_block.children().length + 1;

        $(editable_block).append(
            `<div id="column-${count}">
                <label for="staging_table_column_${count}">Column ${count}</label>
                <input type="text" name="staging_table[column_name_${count}]" id="staging_table_column_name_${count}">
                <label for="staging_table_data_type">Data type</label>
                <input type="text" name="staging_table[column_data_type_${count}]" id="staging_table_column_data_type_${count}">
                <div id="rm-column-${count}" class="remove-column"></div>
            </div>`
        );

        if (count > 1) {
            editable_block.children().each(function () {
                if ($(this).children().last().is(':empty')) {
                    $(this).children().last().html('-').removeClass('d-none').addClass('d-inline-block')
                }
            })
        }
    })
});
