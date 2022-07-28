function checkCronPattern() {
    let minute = document.getElementsByName('cron_tab[setup[pattern[minute]]]')[0].value;
    let hour = document.getElementsByName('cron_tab[setup[pattern[hour]]]')[0].value;
    let month_day = document.getElementsByName('cron_tab[setup[pattern[month_day]]]')[0].value;
    let month = document.getElementsByName('cron_tab[setup[pattern[month]]]')[0].value;
    let weekDay = document.getElementsByName('cron_tab[setup[pattern[week_day]]]')[0].value;
    let description = document.getElementById('cron_description');
    let pattern = `${minute} ${hour} ${month_day} ${month} ${weekDay}`;
    let isCorrectPattern = cronValidator.isValidCron(pattern);

    let formSubmitButton = document.querySelector('#cron_tab_panel form input[type="submit"]')
    formSubmitButton.disabled = !isCorrectPattern;

    if([minute, hour, month_day, month, weekDay].every((el) => el.trim().length === 0)) {
        description.textContent = "";
    } else if(isCorrectPattern) {
        description.textContent = cronstrue.toString(pattern);
    } else {
        description.textContent = "Cron pattern isn't valid";
    }

    return isCorrectPattern;
}

let cronPattern = document.querySelectorAll('#cron_pattern input[name^="cron_tab[setup[pattern["]')

for(let i = 0; i < cronPattern.length; i++) {
    cronPattern[i].addEventListener('input', checkCronPattern);
}

checkCronPattern();
