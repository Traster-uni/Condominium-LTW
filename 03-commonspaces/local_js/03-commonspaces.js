// Mostra sul popup le informazioni relative al luogo comunque cliccato
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

// Mostra il popup cliccando sul tasto PRENOTA
function show(id) {
  return (document.getElementById(id).style.display = "grid");
}

// Chiude il popup cliccando sul tasto X
function hide(id) {
  return (document.getElementById(id).style.display = "none");
}

// Chiude il popup cliccando fuori
window.addEventListener("click", ({ target }) => {
  if (
    target.id !== "prenota" &&
    target.id == "popup" &&
    document.getElementById("popup").style.display == "grid"
  ) {
    document.getElementById("popup").style.display = "none";
  }
});

// Controlla che l'orario di fine scelto sia successivo a quello iniziale
function checkTime(event) {
  const timeStart = document.getElementById("time_start").value;
  const timeEnd = document.getElementById("time_end").value;

  if (timeEnd <= timeStart) {
    event.preventDefault();
    alert("L'ora di fine deve essere successiva all'ora di inizio");
  }
}

// Controlla che l'utente abbia selezionato un giorno
function checkDay(event) {
  if (!document.getElementById("giorno").value) {
    event.preventDefault();
    alert("Devi selezionare un giorno per la tua prenotazione");
  }
}

// Rimuove dinamicamente le prenotazioni che vanno in conflitto di data con quella appena accettata
function removeRefusedForms(inizio1, fine1) {
  let prenotazioni = document.getElementById("prenotazioni-pending");
  let forms = prenotazioni.getElementsByTagName("form");
  let formsArray = Array.from(forms);

  formsArray.forEach(function (form) {
    let inizio2 = document.getElementById("time-inizio-" + form.id);
    let fine2 = document.getElementById("time-fine-" + form.id);

    if (
      (inizio2.value >= inizio1 && inizio2.value <= fine1) ||
      (fine2.value >= inizio1 && fine2.value <= fine1) ||
      (inizio1 >= inizio2.value && inizio1 <= fine2.value) ||
      (fine1 >= inizio2.value && fine1 <= fine2.value)
    ) {
      $(form).fadeOut(300, function () {
        form.remove();
      });
    }
  });
}
