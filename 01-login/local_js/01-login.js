const formSteps = document.querySelectorAll(".form-step");
let currentStep = 0;

function showStep(step) {
  formSteps.forEach((formStep, index) => {
    formStep.style.display = index === step ? "block" : "none";
  });
}

showStep(currentStep);

// Get the modal
var modalSignIn = document.getElementById("modal-signin");
var modalLogin = document.getElementById("modal-login");

// Get the button that opens the modal
var btnSignIn = document.getElementById("signin-button");
var btnLogin = document.getElementById("login-button");

// Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// When the user clicks the button, open the modal
btnSignIn.onclick = function () {
  modalSignIn.style.display = "block";
  showStep(currentStep);
};

btnLogin.onclick = function () {
  modalLogin.style.display = "block";
};

// When the user clicks anywhere outside of the modal, close it
window.onclick = function (event) {
  if (event.target == modalSignIn || event.target == modalLogin) {
    modalSignIn.style.display = "none";
    modalLogin.style.display = "none";
    currentStep = 0;
  }
};

// Script per scorrere il form
nextBtn.onclick = () => {
  if (currentStep < formSteps.length - 1) {
    currentStep++;
    showStep(currentStep);
  }
};

prevBtn.onclick = () => {
  if (currentStep > 0) {
    currentStep--;
    showStep(currentStep);
  }
};
