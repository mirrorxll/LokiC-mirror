$(document).on('turbolinks:load', function () {
    function removeColumnAndSaveEnum() {
        $(this.parentNode).remove();

        $('#columns-editable').children().each(function(index) {
            index++;
            $(this).attr({id: `column-${index}`});
            $(this).find('label[for^="staging_table_column_name_"]')
                .attr({for: `staging_table_column_name_${index}`})
                .text(`Column ${index}`);
            $(this).find('input[name^="staging_table[column_name_"]')
                .attr({name: `staging_table[column_name_${index}]`, id: `staging_table_column_name_${index}`});
            $(this).find('label[for^="staging_table_column_type_"]')
                .attr({for: `staging_table_column_type_${index}`});
            $(this).find('input[name^="staging_table[column_type_"]')
                .attr({name: `staging_table[column_type_${index}]`, id: `staging_table_column_type_${index}`});
            $(this).find('div[id^="rm-column-"]').attr({id: `rm-column-${index}`})
        });
    }

    $('#add-column').on('click', function () {
        let editable_block = $('#columns-editable');
        let count = editable_block.children().length + 1;

        $(editable_block).append(
            `<div id="column-${count}">
                <label for="staging_table_column_name_${count}">Column ${count}</label>
                <input type="text" name="staging_table[column_name_${count}]" id="staging_table_column_name_${count}">
                <label for="staging_table_column_type_${count}">Type</label>
                <input type="text" name="staging_table[column_type_${count}]" id="staging_table_column_type_${count}">
                <div id="rm-column-${count}" class="remove-column"></div>
            </div>`
        );

        if (count > 0) {
            editable_block.children().each(function () {
                let last = $(this).children().last()

                if (last.is(':empty')) {
                    last.html('-')
                        .removeClass('d-none')
                        .addClass('d-inline-block')
                        .click(removeColumnAndSaveEnum)
                }
            })
        }
    });
});
