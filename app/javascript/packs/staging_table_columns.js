// $(document).on('turbolinks:load', function () {
//     function removeColumnAndSaveEnum() {
//         $(this.parentNode).remove();
//
//         $('#columns-editable').children().each(function(index) {
//             index++;
//             $(this).attr({id: `column-${index}`});
//             $(this).find('label[for^="staging_table_column_name_"]')
//                 .attr({for: `staging_table_column_name_${index}`})
//                 .text(`Column ${index}`);
//             $(this).find('input[name^="staging_table[column_name_"]')
//                 .attr({name: `staging_table[column_name_${index}]`, id: `staging_table_column_name_${index}`});
//             $(this).find('label[for^="staging_table_column_type_"]')
//                 .attr({for: `staging_table_column_type_${index}`});
//             $(this).find('select[name^="staging_table[column_type_"]')
//                 .attr({name: `staging_table[column_type_${index}]`, id: `staging_table_column_type_${index}`});
//             $(this).find('div[id^="rm-column-"]').attr({id: `rm-column-${index}`})
//         });
//     }
//
//     $('#add-column').on('click', function () {
//         let editable_block = $('#columns-editable');
//         let count = editable_block.children().length + 1;
//
//         $(editable_block).append(
//             `<div id="column-${count}">
//                 <label for="staging_table_column_name_${count}">Column ${count}</label>
//                 <input type="text" name="staging_table[column_name_${count}]" id="staging_table_column_name_${count}" required>
//                 <label for="staging_table_column_type_${count}">Type</label>
//                 <select name="staging_table[column_type_${count}]" id="staging_table_column_type_${count}"><option value="TINYINT">tinyint</option>
//                     <option value="INT">INT</option>
//                     <option value="BIGINT">BIGINT</option>
//                     <option value="DECIMAL">DECIMAL</option>
//                     <option value="FLOAT">FLOAT</option>
//                     <option value="VARCHAR(255)">VARCHAR(255)</option>
//                     <option value="TEXT">TEXT</option>
//                     <option value="LONGTEXT">LONGTEXT</option>
//                     <option value="TIME">TIME</option>
//                     <option value="DATE">DATE</option>
//                     <option value="YEAR">YEAR</option>
//                     <option value="DATETIME">DATETIME</option>
//                     <option value="JSON">JSON</option>
//                 </select>
//                 <div id="rm-column-${count}" class="remove-column"></div>
//             </div>`
//         );
//
//         if (count > 0) {
//             editable_block.children().each(function () {
//                 let last = $(this).children().last()
//
//                 if (last.is(':empty')) {
//                     last.html('-')
//                         .addClass('d-inline-block')
//                         .click(removeColumnAndSaveEnum)
//                 }
//             })
//         }
//     });
// });
