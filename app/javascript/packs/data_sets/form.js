let clientsSelect = document.getElementsByClassName('clients_select')
for(let i = 0; i < clientsSelect.length; i++)
    clientsSelect[i].addEventListener('change', tagsByClient)

let removeX = document.getElementsByClassName('remove_x')
for(let i = 0; i < removeX.length; i++)
    removeX[i].addEventListener('click', removeClientTag )

function setPlaceholder(block) {
    let placeholder = block.find('.select_placeholder');
    let select = block.find('select');

    placeholder.html(
        placeholder.attr('data-text') + `<span class='text-dark'>${select.find('option:selected').text()}</span>`
    );
}

window.$('.sheriff, .photo_bucket').each(function() { setPlaceholder(window.$(this)); });
window.$('.sheriff select, .photo_bucket select').on('change', function() { setPlaceholder(window.$(this).parent()) });

let clients = []

window.$('#add_client').on('click', (e)=> {
    e.preventDefault();

    let uId = secureRandom(6)

    let clientsSelect = document.createElement('select')
    clientsSelect.appendChild(document.createElement('option'))
    clientsSelect.id = `data_set_default_${uId}_client_id`
    clientsSelect.name = `default_props[client_tag_ids[${uId}[client_id]]]`
    clientsSelect.className = 'form-control form-control-sm clients_select'
    clientsSelect.required = true
    clientsSelect.addEventListener('change', tagsByClient)

    let tagsSelect = document.createElement('select')
    tagsSelect.appendChild(document.createElement('option'))
    tagsSelect.id = `data_set_default_${uId}_tag_id`
    tagsSelect.name = `default_props[client_tag_ids[${uId}[tag_id]]]`
    tagsSelect.className = 'form-control form-control-sm tags_select'
    tagsSelect.required = true

    let clientsCol = document.createElement('div')
    clientsCol.className = 'col-5 pr-1'
    clientsCol.appendChild(clientsSelect)

    let tagsCol = document.createElement('div')
    tagsCol.className = 'col-6 pl-1 pr-1'
    tagsCol.appendChild(tagsSelect)

    let x = document.createElement('strong')
    x.className = 'remove_x'
    x.innerText = 'x'
    x.addEventListener('click', removeClientTag )

    let removeCol = document.createElement('div')
    removeCol.className = 'col-1 pl-1 my-auto remove_x'
    removeCol.appendChild(x)

    let row = document.createElement('div')
    row.className = 'row mb-1'
    row.id = uId
    row.appendChild(clientsCol)
    row.appendChild(tagsCol)
    row.appendChild(removeCol)

    document.getElementById('clients_tags').appendChild(row)

    if(clients.length === 0) {
        window.$.ajax({
            url: `${window.location.origin}/api/v1/clients/visible`,
            dataType: 'json',
            success: (clients)=> { addClientsToSelectGroup(uId, clients.visible) }
        });
    } else {
        addClientsToSelectGroup(uId);
    }
})

function secureRandom(n){
    let result = '';
    while (n--){
        result += Math.floor(Math.random() * 16).toString(16);
    }

    return result;
}

function addClientsToSelectGroup(uId, clientsFromApi = null) {
    if(clientsFromApi != null) clients = clientsFromApi

    if(clients.length > 0) {
        let select = document.getElementById(uId).getElementsByClassName('clients_select')[0]
        let option = null

        for (let i = 0; i < clients.length; i++) {
            option = document.createElement("option");
            option.setAttribute("value", clients[i].id);
            option.text = clients[i].name;
            select.appendChild(option);
        }
    } else {
        setTimeout(addClientsToSelectGroup, 1000)
    }
}

function tagsByClient(event) {
    let clientId = event.target.value
    if(clientId === '') return false;

    let tagsSelect = event.target.parentNode.parentNode.getElementsByClassName('tags_select')[0]

    while (tagsSelect.firstChild) {
        tagsSelect.removeChild(tagsSelect.firstChild);
    }

    window.$.ajax({
        url: `${window.location.origin}/api/v1/clients/${clientId}/tags`,
        dataType: 'json',
        success: (tags)=> { addTagsToSelectGroup(tagsSelect, tags.attached) }
    });
}

function addTagsToSelectGroup(tagsSelect, tags) {
    tagsSelect.appendChild(document.createElement('option'))
    let option = null

    for (let i = 0; i < tags.length; i++) {
        option = document.createElement("option");
        option.setAttribute("value", tags[i].id);
        option.text = tags[i].name;
        tagsSelect.appendChild(option);
    }
}

function removeClientTag(e) {
    e.target.parentNode.parentNode.remove();
}
