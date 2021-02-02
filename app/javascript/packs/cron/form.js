function checkCronPattern() {
    let minute = document.getElementsByName('cron_tab[setup[pattern[minute]]]')[0].value;
    let hour = document.getElementsByName('cron_tab[setup[pattern[hour]]]')[0].value;
    let day = document.getElementsByName('cron_tab[setup[pattern[day]]]')[0].value;
    let month = document.getElementsByName('cron_tab[setup[pattern[month]]]')[0].value;
    let weekDay = document.getElementsByName('cron_tab[setup[pattern[week_day]]]')[0].value;
    let description = document.getElementById('cron_description');
    let pattern = `${minute} ${hour} ${day} ${month} ${weekDay}`;

    if([minute, hour, day, month, weekDay].every((el) => el.trim().length === 0)) {
        description.innerText = ""
    } else if(cronValidator.isValidCron(pattern)) {
        description.innerText = cronstrue.toString(pattern)
    } else {
        description.innerText = "Cron pattern isn't valid"
    }
}

let cronPattern = document.querySelectorAll('#cron_pattern input')

for(let i = 0; i < cronPattern.length; i++) {
    cronPattern[i].addEventListener('input', checkCronPattern)
}

checkCronPattern();
