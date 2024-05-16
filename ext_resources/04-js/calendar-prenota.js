// Define an array to store events
let events = [];

// letiables to store event input fields and reminder list
let eventDateInput = document.getElementById("eventDate");
let eventTitleInput = document.getElementById("eventTitle");
let eventDescriptionInput = document.getElementById("eventDescription");
let reminderList = document.getElementById("reminderList");

// Counter to generate unique event IDs
let eventIdCounter = 1;

// Function to generate a range of
// years for the year select input
function generate_year_range(start, end) {
  let years = "";
  for (let year = start; year <= end; year++) {
    years += "<option value='" + year + "'>" + year + "</option>";
  }
  return years;
}

// Initialize date-related letiables
today = new Date();
currentMonth1 = today.getMonth();
currentYear1 = today.getFullYear();
selectYear1 = document.getElementById("year");
selectMonth1 = document.getElementById("month");

createYear = generate_year_range(2000, 2050);

document.getElementById("year").innerHTML = createYear;

let calendar1 = document.getElementById("calendar1");

let months = [
  "Gennaio",
  "Febbraio",
  "Marzo",
  "Aprile",
  "Maggio",
  "Giugno",
  "Luglio",
  "Agosto",
  "Settembre",
  "Ottobre",
  "Novembre",
  "Dicembre",
];
let days = ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"];

$dataHead = "<tr>";
for (dhead in days) {
  $dataHead += "<th data-days='" + days[dhead] + "'>" + days[dhead] + "</th>";
}
$dataHead += "</tr>";

document.getElementById("thead-month1").innerHTML = $dataHead;

monthAndYear1 = document.getElementById("monthAndYear1");
showCalendar1(currentMonth1, currentYear1);

// Function to navigate to the next month
function next1() {
  currentYear1 = currentMonth1 === 11 ? currentYear1 + 1 : currentYear1;
  currentMonth1 = (currentMonth1 + 1) % 12;
  showCalendar1(currentMonth1, currentYear1);
}

// Function to navigate to the previous month
function previous1() {
  currentYear1 = currentMonth1 === 0 ? currentYear1 - 1 : currentYear1;
  currentMonth1 = currentMonth1 === 0 ? 11 : currentMonth1 - 1;
  showCalendar1(currentMonth1, currentYear1);
}

// Function to display the calendar
function showCalendar1(month, year) {
  let firstDay = new Date(year, month, 1).getDay();
  tbl = document.getElementById("calendar-body1");
  tbl.innerHTML = "";
  monthAndYear1.innerHTML = months[month] + " " + year;
  selectYear1.value = year;
  selectMonth1.value = month;

  let date = 1;
  for (let i = 0; i < 6; i++) {
    let row = document.createElement("tr");
    for (let j = 0; j < 7; j++) {
      if (i === 0 && j < firstDay) {
        cell = document.createElement("td");
        cellText = document.createTextNode("");
        cell.appendChild(cellText);
        row.appendChild(cell);
      } else if (date > daysInMonth(month, year)) {
        break;
      } else {
        cell = document.createElement("td");
        cell.setAttribute("data-date", date);
        cell.setAttribute("data-month", month + 1);
        cell.setAttribute("data-year", year);
        cell.setAttribute("data-month_name", months[month]);
        cell.className = "selectable";
        cell.innerHTML = "<span>" + date + "</span";

        if (
          date === today.getDate() &&
          year === today.getFullYear() &&
          month === today.getMonth()
        ) {
          cell.className = "today";
        }

        if (
          (date < today.getDate() &&
            month === today.getMonth() &&
            year === today.getFullYear()) ||
          (month < today.getMonth() && year === today.getFullYear()) ||
          year < today.getFullYear()
        ) {
          cell.className = "not-selectable";
        }

        // Check if there are events on this date
        if (hasEventOnDate(date, month, year)) {
          cell.classList.add("event-marker");
          cell.appendChild(createEventTooltip(date, month, year));
        }

        row.appendChild(cell);
        date++;
      }
    }
    tbl.appendChild(row);
  }
}

// Function to get the number of days in a month
function daysInMonth(iMonth, iYear) {
  return 32 - new Date(iYear, iMonth, 32).getDate();
}

// Call the showCalendar1 function initially to display the calendar
showCalendar1(currentMonth1, currentYear1);

/* Source: https://www.geeksforgeeks.org/how-to-create-a-dynamic-calendar-in-html-css-javascript/ */

function getDays() {
  // Add event listener to each calendar day
  const calendarDays = document.querySelectorAll(".selectable");
  console.log(calendarDays);
  calendarDays.forEach((day) => {
    day.addEventListener("click", function () {
      const giorno = this.getAttribute("data-date");
      const mese = this.getAttribute("data-month");
      const anno = this.getAttribute("data-year");
      document.getElementById("giorno").value = giorno; // Set the value of the hidden input field
      document.getElementById("mese").value = mese; // Set the value of the hidden input field
      document.getElementById("anno").value = anno; // Set the value of the hidden input field
      // Add some visual feedback for the selected date
      calendarDays.forEach((day) => {
        day.classList.remove("choosen");
      });
      this.classList.add("choosen");
    });
  });
}
