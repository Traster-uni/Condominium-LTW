function popup(button) {
  var figure = button.closest("figure");
  var nomeLuogo = figure.querySelector(".nome-luogo");
  var imgLuogo = figure.querySelector(".img-luogo");
  var csId = figure.querySelector(".cs-id");
  var nomeLuogo = nomeLuogo.textContent;
  var imgLuogo = imgLuogo.src;
  var csId = csId.textContent;
  document.getElementById("nome-popup").textContent = nomeLuogo;
  document.getElementById("img-popup").src = imgLuogo;
  document.getElementById("cs-id").value = csId;
}

function show(id) {
  return (document.getElementById(id).style.display = "grid");
}

function hide(id) {
  return (document.getElementById(id).style.display = "none");
}

// Chiudi il popup cliccando fuori
window.addEventListener("click", ({ target }) => {
  if (
    target.id !== "prenota" &&
    target.id == "popup" &&
    document.getElementById("popup").style.display == "grid"
  ) {
    document.getElementById("popup").style.display = "none";
  }
});

function checkTime(event) {
  const timeStart = document.getElementById("time_start").value;
  const timeEnd = document.getElementById("time_end").value;

  if (timeEnd <= timeStart) {
    event.preventDefault();
    alert("L'ora di fine deve essere successiva all'ora di inizio");
  }
}
