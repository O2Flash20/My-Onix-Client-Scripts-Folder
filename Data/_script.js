// let text
// function readFile() {
//     let oldText = text
//     document.querySelector("iframe").contentWindow.location.reload()
//     text = document.querySelector("iframe").contentWindow.document.body.innerText

//     if (text !== oldText) {
//         console.log(text)
//     }
// }

// setInterval(readFile, 1000)

setTimeout(function () {
    // console.log(document.querySelector("iframe").contentWindow.document.body.innerText)
    document.getElementById("message").innerText = document.querySelector("iframe").contentWindow.document.body.innerText
}, 100)

/*
message sent goes at the end of the index.html in a p tag with a specific class
    js sends new entries to the server and then deletes the elements
every few seconds the page reloads so that new messages are shown and sent off

things to do:
    learn how to get text from a page
    actually learn how to make the chat app
    add elements from lua/delete and send them to the server
*/