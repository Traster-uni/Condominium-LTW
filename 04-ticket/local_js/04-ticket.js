let btn = document.getElementsByClassName("opnBtn");
         
btn[0].addEventListener("click", function () {
    this.classList.toggle("active");
    var content = document.getElementById("formTicket").style.maxHeight;
    if (content == "auto") {
        content = 0;
    } else {
        content = "auto";
    }
});