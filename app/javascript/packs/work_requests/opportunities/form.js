let agenciesSelect = document.getElementsByClassName('agencies_select')
for(let i = 0; i < agenciesSelect.length; i++) {
    agenciesSelect[i].addEventListener('change', opportunitiesByAgency)
}

let removeX = document.getElementsByClassName('remove_x')
for(let i = 0; i < removeX.length; i++)
    removeX[i].addEventListener('click', removeOpportunities )

let agencies = []

window.$('#add_a_opp').on('click', (e)=> {
    e.preventDefault();

    let uId = secureRandom(6)

    let agenciesSelect = document.createElement('select')
    agenciesSelect.appendChild(document.createElement('option'))
    agenciesSelect.id = `a_op_p_${uId}_agency_id`
    agenciesSelect.name = `work_request[a_op_p[${uId}[agency_id]]]`
    agenciesSelect.className = 'form-control form-control-sm agencies_select'
    agenciesSelect.required = true
    agenciesSelect.addEventListener('change', opportunitiesByAgency)

    let opportunitiesSelect = document.createElement('select')
    opportunitiesSelect.appendChild(document.createElement('option'))
    opportunitiesSelect.id = `a_op_p_${uId}_opportunity_id`
    opportunitiesSelect.name = `work_request[a_op_p[${uId}[opportunity_id]]]`
    opportunitiesSelect.className = 'form-control form-control-sm opportunities_select'
    opportunitiesSelect.required = true

    let percentInput = document.createElement('input')
    percentInput.id = `a_op_p_${uId}_percent`;
    percentInput.name = `work_request[a_op_p[${uId}[percent]]]`;
    percentInput.className = 'form-control form-control-sm percent_input';
    percentInput.type = 'number';
    percentInput.max = '100';
    percentInput.required = true;

    let x = document.createElement('strong')
    x.className = 'remove_x mouse-hover'
    x.textContent = '[ X ]'
    x.addEventListener('click', removeOpportunities )

    let agenciesCol = document.createElement('div')
    agenciesCol.className = 'col-3 pr-0'
    agenciesCol.appendChild(agenciesSelect)

    let opportunitiesCol = document.createElement('div')
    opportunitiesCol.className = 'col-4 pr-0'
    opportunitiesCol.appendChild((opportunitiesSelect))

    let percentCol = document.createElement('div')
    percentCol.className = 'col-3 pr-1';
    percentCol.appendChild(percentInput);

    let removeCol = document.createElement('div')
    removeCol.className = 'col-2 d-flex align-items-center'
    removeCol.appendChild(x)

    let row = document.createElement('div')
    row.className = 'row mb-1'
    row.id = uId
    row.appendChild(agenciesCol)
    row.appendChild(opportunitiesCol)
    row.appendChild(percentCol)
    row.appendChild(removeCol)

    document.querySelector('#agencyOpportunities .card-body').appendChild(row)

    if(agencies.length === 0) {
        window.$.ajax({
            url: `/api/main_agencies`,
            dataType: 'json',
            success: (agencies) => { addAgenciesToSelectGroup(uId, agencies) }
        });
    } else {
        addAgenciesToSelectGroup(uId);
    }
})

function secureRandom(n){
    let result = '';
    while (n--){
        result += Math.floor(Math.random() * 16).toString(16);
    }
    return result;
}

function addAgenciesToSelectGroup(uId, agenciesFromApi = null) {
    if(agenciesFromApi != null) agencies = agenciesFromApi

    if(agencies.length > 0) {
        let select = document.getElementById(uId).getElementsByClassName('agencies_select')[0]
        let option = null;

        for (let i = 0; i < agencies.length; i++) {
            option = document.createElement("option");
            option.setAttribute("value", agencies[i].id);
            option.textContent = agencies[i].name;
            select.appendChild(option);
        }
    } else {
        setTimeout(addAgenciesToSelectGroup, 1000)
    }
}

function opportunitiesByAgency(event) {
    let agencyId = event.target.value;
    let opportunitiesSelect = event.target.parentNode.parentNode.getElementsByClassName('opportunities_select')[0]

    window.$.ajax({
        url: `/api/main_agencies/${agencyId}/opportunities`,
        dataType: 'json',
        success: (opportunities) => {
            addOpportunitiesToSelectGroup(opportunitiesSelect, opportunities)
        }
    });
}

function addOpportunitiesToSelectGroup(opportunitiesSelect, opportunities) {
    let option = null;

    for (let i = 0; i < opportunities.length; i++) {
        option = document.createElement("option");
        option.setAttribute("value", opportunities[i].id);
        option.textContent = opportunities[i].name;
        opportunitiesSelect.appendChild(option);
    }
}

function removeOpportunities(e) {
    e.target.parentNode.parentNode.remove();
}
