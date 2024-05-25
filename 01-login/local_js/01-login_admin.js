var modalAptblock = document.getElementById("modal-aptblock");
var btnAptblock = document.getElementById("aptblock-button");
var btnSubmit = document.getElementById("submit");

btnAptblock.onclick = function () {
  modalAptblock.style.display = "block";
};

window.onclick = function (event) {
  if (event.target == modalAptblock) {
    modalAptblock.style.display = "none";
  }
};

btnSubmit.onclick = function checkRequests(event) {
  const città = document.getElementById("città").value;
  const indirizzo = document.getElementById("indirizzo").value;
  if (
    check_exists.find(
      (item) => item.città === città && item.indirizzo === indirizzo
    )
  ) {
    event.preventDefault();
    alert("Esiste già un condominio in questa città con questo indirizzo");
  } else if (
    check_sent.find(
      (item) => item.città === città && item.indirizzo === indirizzo
    )
  ) {
    event.preventDefault();
    alert("Hai già inviato una richiesta per creare questo condominio");
  }
};
