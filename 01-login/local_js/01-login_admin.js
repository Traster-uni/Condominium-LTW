var modalAptblock = document.getElementById("modal-aptblock");

var btnAptblock = document.getElementById("aptblock-button");

btnAptblock.onclick = function () {
  modalAptblock.style.display = "block";
};

window.onclick = function (event) {
  if (event.target == modalAptblock) {
    modalAptblock.style.display = "none";
  }
};
