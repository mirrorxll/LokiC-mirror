function onEnterAddMultiTask(event) {
    if((event.keyCode !== 13) || (this.value.trim().length === 0)) return false;

    let checksSet = this.form.querySelector('.form-check');
    let multiTasksIn = [...checksSet.querySelectorAll('label')].map((i) => i.textContent);
    let multiTasksOut = [...this.form.querySelectorAll('option')].map((i) => i.value);
    let label = this.value.trim();
    let id = label.match(/\d+/);

    if(multiTasksIn.includes(label) || !multiTasksOut.includes(label) ) return false;

    checksSet.insertAdjacentHTML(
        'beforeend',
        `
            <input name="multi_tasks[${id}]" type="hidden" value="0">
            <input class="form-check-input" type="checkbox" value="1" checked="checked" name="multi_tasks[${id}]" id="multi_tasks[${id}]">
            <label class="form-check-label" for="multi_tasks[${id}]">${label}</label>
            <br/>
          `
    )

    this.value = "";
}

document.querySelector('#multiTasksInputBlock>.form-group>input').addEventListener('keypress', onEnterAddMultiTask);
