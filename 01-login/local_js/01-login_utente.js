var btnSubmit = document.getElementById("submit");

btnSubmit.onclick = function checkRequests(event) {
  const id = document.getElementById("id").value;
  if (check_sent.includes(id)) {
    event.preventDefault();
    alert("Hai già inviato una richiesta per questo condominio");
  }
};
