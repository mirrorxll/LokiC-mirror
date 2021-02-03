function checkCronPattern() {
    let minute = document.getElementsByName('cron_tab[setup[pattern[minute]]]')[0].value;
    let hour = document.getElementsByName('cron_tab[setup[pattern[hour]]]')[0].value;
    let month_day = document.getElementsByName('cron_tab[setup[pattern[month_day]]]')[0].value;
    let month = document.getElementsByName('cron_tab[setup[pattern[month]]]')[0].value;
    let weekDay = document.getElementsByName('cron_tab[setup[pattern[week_day]]]')[0].value;
    let description = document.getElementById('cron_description');
    let pattern = `${minute} ${hour} ${month_day} ${month} ${weekDay}`;
    let isCorrectPattern = cronValidator.isValidCron(pattern);

    if([minute, hour, month_day, month, weekDay].every((el) => el.trim().length === 0)) {
        description.innerText = "";
    } else if(isCorrectPattern) {
        description.innerText = cronstrue.toString(pattern);
    } else {
        description.innerText = "Cron pattern isn't valid";
    }

    return isCorrectPattern;
}

let cronPattern = document.querySelectorAll('#cron_pattern input[type="text"]')

for(let i = 0; i < cronPattern.length; i++) {
    cronPattern[i].addEventListener('input', checkCronPattern);
}

document.querySelector('#cron_tab_panel form').addEventListener('submit', (event) => {
    event.preventDefault();

    if(checkCronPattern()) {
        event.currentTarget.setAttribute('data-remote', true)
        // event.currentTarget.submit()
        Rails.fire(event.currentTarget,  'submit')
    } else {
        console.log(0)
    }

    return false;
});

checkCronPattern();

