const progressBox = document.getElementById('progress-box')
const submitBtn = document.getElementById('submit-btn')
const form = document.getElementById('form')


// add loading bar after submition
submitBtn.addEventListener('click', ()=>{
    progressBox.innerHTML = `<div class="progress">
      <div class="indeterminate"></div>
    </div>`
    progressBox.classList.remove('not-visible')

    const messagesCards = document.getElementsByName('messages-card')
    if (messagesCards != []) {
        for (var i = 0; i < messagesCards.length; i++) {
            messagesCards[i].classList.add('not-visible')
        }
    }
})


// clean messages when a user starts filling the form again
form.addEventListener('change', ()=>{
    const messagesCards = document.getElementsByName('messages-card')
    if (messagesCards != []) {
        for (var i = 0; i < messagesCards.length; i++) {
            messagesCards[i].classList.add('not-visible')
        }
    }
})