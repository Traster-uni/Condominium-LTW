function popup(button) {
  var figure = button.closest("figure");
  var nomeLuogo = figure.querySelector(".nome-luogo");
  var imgLuogo = figure.querySelector(".img-luogo");
  var nomeLuogo = nomeLuogo.textContent;
  var imgLuogo = imgLuogo.src;
  console.log("Nome Luogo:", nomeLuogo);
  console.log("Image Source:", imgLuogo);
  document.getElementById("nome-popup").textContent = nomeLuogo;
  document.getElementById("img-popup").src = imgLuogo;
}

function show(id) {
  return (document.getElementById(id).style.display = "grid");
}

function hide(id) {
  return (document.getElementById(id).style.display = "none");
}

function checkTime(event) {
  const timeStart = document.getElementById("time_start").value;
  const timeEnd = document.getElementById("time_end").value;

  if (timeEnd <= timeStart) {
    event.preventDefault();
    alert("L'ora di fine deve essere successiva all'ora di inizio");
  }
}
