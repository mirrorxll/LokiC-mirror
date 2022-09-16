function onEnterAddScrapeTask(event) {
    if((event.keyCode !== 13) || (this.value.trim().length === 0)) return false;

    let checksSet = this.form.querySelector('.form-check');
    let dataSetsIn = [...checksSet.querySelectorAll('label')].map((i) => i.textContent);
    let dataSetsOut = [...this.form.querySelectorAll('option')].map((i) => i.value);
    let label = this.value;
    let id = label.match(/\d+/);

    if(dataSetsIn.includes(label) || !dataSetsOut.includes(label) ) return false;

    checksSet.insertAdjacentHTML(
        'beforeend',
        `
            <input name="scrape_tasks[${id}]" type="hidden" value="0">
            <input class="form-check-input" type="checkbox" value="1" checked="checked" name="scrape_tasks[${id}]" id="scrape_tasks[${id}]">
            <label class="form-check-label" for="scrape_tasks[${id}]">${label}</label>
            <br/>
          `
    );

    this.value = "";
}

document.querySelector('#scrapeTasksInputBlock>.form-group>input').addEventListener('keypress', onEnterAddScrapeTask);
