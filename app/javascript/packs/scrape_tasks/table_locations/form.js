function loadSchemas() {
    let schemas = document.querySelector('#schemas');
    let tableNames = document.querySelector('#tableNamesFilterSelect');

    schemas.options.length = 0;
    tableNames.options.length = 0;

    if(this.value === '') return false;

    Rails.ajax({
        type: "GET",
        dataType: 'json',
        url: `/schemas`,
        data: `host_id=${encodeURIComponent(this.value)}`,
        success: (data) => {
            let option = document.createElement("option");

            schemas.appendChild(option);

            data['schemas'].forEach((item) => {
                option = document.createElement("option");
                option.setAttribute("value", `${item['id']}`);
                option.textContent = item['name'];
                schemas.appendChild(option)
            });
        }
    });
}

function loadTables() {
    let tableNames = document.querySelector('#tableNamesFilterSelect');

    tableNames.options.length = 0;

    if(this.value === '') return false;

    let filterInput = document.querySelector('#tableNamesFilterInput');
    let schema_id = this.value.trim();

    Rails.ajax({
        type: "GET",
        dataType: 'json',
        url: `/schemas/${schema_id}/sql_tables`,
        success: (data) => {
            data['tables'].forEach((item) => {
                let option = document.createElement("option");
                option.setAttribute("value", `${item['id']}`);
                option.textContent = item['name'];
                tableNames.appendChild(option)
            });
        }
    });

    function tableNamesFilter() {
        let tester = new RegExp(`${filterInput.value}`, 'i');

        for(let i = 0; i < tableNames.options.length; i++) {
            if(tester.test(tableNames.options[i].textContent)) {
                tableNames.options[i].style.display = '';
            } else {
                tableNames.options[i].style.display = 'none';
            }
        }
    }

    filterInput.addEventListener('input', tableNamesFilter);
}

function onEnterTableLocations(event) {
    if((event.keyCode !== 13) || (this.selectedOptions.length === 0)) return false;

    let hosts = document.querySelector('#hosts');
    let schemas = document.querySelector('#schemas');

    let checksSet = this.form.querySelector('.form-check');
    let tableLocationLabels = [...checksSet.querySelectorAll('label')].map((i) => i.textContent);
    let tableLocationLabelRaw =
        `${hosts.options[hosts.selectedIndex].textContent}.${schemas.options[schemas.selectedIndex].textContent}`;

    this.selectedOptions.forEach((el) => {
        if(tableLocationLabels.includes(`${tableLocationLabelRaw}.${el.textContent}`)) return false;

        checksSet.insertAdjacentHTML(
            'beforeend',
            `
            <input name="table_locations[${hosts.value}_${schemas.value}_${el.value}]" type="hidden" value="0">
            <input class="form-check-input" type="checkbox" value="1" checked="checked" name="table_locations[${hosts.value}_${schemas.value}_${el.value}]" id="table_locations[${hosts.value}_${schemas.value}.${el.value}]">
            <label class="form-check-label" for="table_locations[${hosts.value}_${schemas.value}_${el.value}]">${tableLocationLabelRaw}.${el.textContent}</label>
            <br/>
          `
        )
    });
}

document.querySelector('#hosts').addEventListener('change', loadSchemas);
document.querySelector('#schemas').addEventListener('change', loadTables);
document.querySelector('#tableNamesFilterSelect').addEventListener('keypress', onEnterTableLocations);
