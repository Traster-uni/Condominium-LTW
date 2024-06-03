var btnSubmit = document.getElementById("submit");

btnSubmit.onclick = function checkRequests(event) {
  const id = document.getElementById("id").value;
  if (check_sent.includes(id)) {
    event.preventDefault();
    alert("Hai già inviato una richiesta per questo condominio");
  }
};

document.getElementById("doc").addEventListener("click", function () {
  document.getElementById("upload-img").click();
});

document.getElementById("upload-img").addEventListener("change", function () {
  var fileName = this.files[0] ? this.files[0].name : "No file chosen";
  document.getElementById("file").textContent = fileName;
});
