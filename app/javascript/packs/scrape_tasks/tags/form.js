function onEnterAddTag(event) {
    if((event.keyCode !== 13) || (this.value.trim().length === 0)) return false;

    let checksSet =  this.form.querySelector('.form-check');
    let tags = [...checksSet.querySelectorAll('label')].map((i) => i.textContent);
    let value = this.value;

    if(tags.includes(value)) return false;

    checksSet.insertAdjacentHTML(
        'beforeend',
        `
            <input name="tags[${value}]" type="hidden" value="0">
            <input class="form-check-input" type="checkbox" value="1" checked="checked" name="tags[${value}]" id="tags[${value}]">
            <label class="form-check-label" for="tags[${value}]">${value}</label>
            <br/>
          `
    )

    this.value = "";
}

document.querySelector('#tagInputBlock>.form-group>input').addEventListener('keypress', onEnterAddTag);
