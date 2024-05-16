// Get the modal
var modalSignIn = document.getElementById("modalSignIn");
var modalLogin = document.getElementById("modalLogin");

// Get the button that opens the modal
var btnSignIn = document.getElementById("signInButton");
var btnLogin = document.getElementById("loginButton");

// Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// When the user clicks the button, open the modal 
btnSignIn.onclick = function() {
  modalSignIn.style.display = "block";
}

btnLogin.onclick = function() {
  modalLogin.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modalSignIn || event.target == modalLogin) {
    modalSignIn.style.display = "none";
    modalLogin.style.display = "none";
  }
}