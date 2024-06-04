var btnSubmit = document.getElementById("submit");

// Controlla se l'utente ha già chiesto di accedere al condominio
btnSubmit.onclick = function checkRequests(event) {
  const id = document.getElementById("id").value;
  if (check_sent.includes(id)) {
    event.preventDefault();
    alert("Hai già inviato una richiesta per questo condominio");
  }
};

// Bottone file custom
document.getElementById("doc").addEventListener("click", function () {
  document.getElementById("upload-img").click();
});

// Mostra il nome del file caricato
document.getElementById("upload-img").addEventListener("change", function () {
  var fileName = this.files[0] ? this.files[0].name : "Nessun file caricato";
  document.getElementById("file").textContent = fileName;
});
