let agenciesSelect = document.getElementsByClassName('agencies_select')

for(let i = 0; i < agenciesSelect.length; i++) {
    agenciesSelect[i].addEventListener('change', opportunitiesByAgency)
    agenciesSelect[i].addEventListener('change', revenueTypesByOpportunity)
}

let opportunitiesSelect = document.getElementsByClassName('opportunities_select')
for(let i = 0; i < agenciesSelect.length; i++) {
    opportunitiesSelect[i].addEventListener('change', revenueTypesByOpportunity)
}

let removeX = document.getElementsByClassName('remove_x')
for(let i = 0; i < removeX.length; i++)
    removeX[i].addEventListener('click', removeAgencyOpportunity )

let agencies = []

window.$(`.add_agency`).on('click', (e)=> {
    e.preventDefault();
    e.stopPropagation();

    var task = $(e.target)[0].id;

    console.log(task)
    let uId = secureRandom(6)

    let agenciesSelect = document.createElement('select')
    agenciesSelect.appendChild(document.createElement('option'))
    agenciesSelect.id = `${task}[${uId}_agency_id]`
    agenciesSelect.name = `${task}[agg_opp_ids[${uId}[agency_id]]]`
    agenciesSelect.className = 'w-100 agencies_select'
    agenciesSelect.required = true
    agenciesSelect.addEventListener('change', opportunitiesByAgency)
    agenciesSelect.addEventListener('change', revenueTypesByOpportunity)

    let opportunitiesSelect = document.createElement('select')
    opportunitiesSelect.appendChild(document.createElement('option'))
    opportunitiesSelect.id = `${task}[${uId}_opportunity_id]`
    opportunitiesSelect.name = `${task}[agg_opp_ids[${uId}[opportunity_id]]]`
    opportunitiesSelect.className = 'w-100 opportunities_select'
    opportunitiesSelect.required = true
    opportunitiesSelect.addEventListener('change', revenueTypesByOpportunity)

    let revenueTypeSelect = document.createElement('select')
    revenueTypeSelect.appendChild(document.createElement('option'))
    revenueTypeSelect.id = `${task}[${uId}_revenue_type_id]`
    revenueTypeSelect.name = `${task}[agg_opp_ids[${uId}[revenue_type_id]]]`
    revenueTypeSelect.className = 'w-100 revenue_type_select'
    opportunitiesSelect.required = true

    let percentInput = document.createElement('input')
    percentInput.type = `number`
    percentInput.max = `100`
    percentInput.id = `${task}[${uId}_percent_id]`
    percentInput.name = `${task}[agg_opp_ids[${uId}[percent]]]`
    percentInput.className = 'small percent_select'

    let agenciesCol = document.createElement('div')
    agenciesCol.className = 'col-3 pr-1'
    agenciesCol.appendChild(agenciesSelect)

    let revenueTypeCol = document.createElement('div')
    revenueTypeCol.className = 'col-3 pr-2'
    revenueTypeCol.appendChild(revenueTypeSelect)

    let opportunitiesCol = document.createElement('div')
    opportunitiesCol.className = 'col-3 pr-1'
    opportunitiesCol.appendChild(opportunitiesSelect)

    let percentCol = document.createElement('div')
    percentCol.className = 'col-2 pl-1 pr-1 small'
    percentCol.appendChild(percentInput)

    let x = document.createElement('strong')
    x.className = 'remove_x fa fa-minus'
    x.addEventListener('click', removeAgencyOpportunity )

    let removeCol = document.createElement('div')
    removeCol.className = 'col-1 pl-1 my-auto remove_x'
    removeCol.appendChild(x)

    let row = document.createElement('div')
    row.className = 'row mb-1'
    row.id = uId
    row.appendChild(agenciesCol)
    row.appendChild(opportunitiesCol)
    row.appendChild(revenueTypeCol)
    row.appendChild(percentInput)
    row.appendChild(removeCol)

    document.getElementById(`agency_opportunity_revenue_types_${task}`).appendChild(row)

    if(agencies.length === 0) {
        window.$.ajax({
            url: `${window.location.origin}/api/main_agencies`,
            dataType: 'json',
            success: (agencies)=> { addAgenciesToSelectGroup(uId, agencies) }
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
    if(agencyId === '') return false;

    let opportunitiesSelect = event.target.parentNode.parentNode.getElementsByClassName('opportunities_select')[0]

    while (opportunitiesSelect.firstChild) {
        opportunitiesSelect.removeChild(opportunitiesSelect.firstChild);
    }

    window.$.ajax({
        url: `${window.location.origin}/api/main_agencies/${agencyId}/opportunities`,
        dataType: 'json',
        async: false,
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

function revenueTypesByOpportunity(event) {
    let opportunityId = event.target.parentNode.parentNode.getElementsByClassName('opportunities_select')[0].value;
    let agencyId = event.target.parentNode.parentNode.getElementsByClassName('agencies_select')[0].value;

    if(agencyId === '') return false;
    if(opportunityId === '') return false;

    let revenueTypesSelect = event.target.parentNode.parentNode.getElementsByClassName('revenue_type_select')[0]

    while (revenueTypesSelect.firstChild) {
        revenueTypesSelect.removeChild(revenueTypesSelect.firstChild);
    }

    window.$.ajax({
        url: `${window.location.origin}/api/main_opportunities/${opportunityId}/revenue_types`,
        dataType: 'json',
        success: (revenueTypes)=> { addRevenueTypesToSelectGroup(revenueTypesSelect, revenueTypes) }
    });
}

function addRevenueTypesToSelectGroup(revenueTypesSelect, revenueTypes) {
    let option = null;

    for (let i = 0; i < revenueTypes.length; i++) {
        option = document.createElement("option");
        option.setAttribute("value", revenueTypes[i].id);
        option.textContent = revenueTypes[i].name;
        revenueTypesSelect.appendChild(option);
    }
}


function removeAgencyOpportunity(e) {
    e.target.parentNode.parentNode.remove();
}
