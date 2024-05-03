var show = function (id) {
  return (document.getElementById(id).style.display = "grid");
};

var hide = function (id) {
  return (document.getElementById(id).style.display = "none");
};

function checkTime(event) {
  const timeStart = document.getElementById("time-start").value;
  const timeEnd = document.getElementById("time-end").value;

  if (timeEnd <= timeStart) {
    event.preventDefault();
    alert("L'ora di fine deve essere successiva all'ora di inizio");
  }
}
