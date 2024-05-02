// Define an array to store events
let events = [];

// letiables to store event input fields and reminder list
let eventDateInput = document.getElementById("eventDate");
let eventTitleInput = document.getElementById("eventTitle");
let eventDescriptionInput = document.getElementById("eventDescription");
let reminderList = document.getElementById("reminderList");

// Counter to generate unique event IDs
let eventIdCounter = 1;

// Function to add events
function addEvent() {
  let date = eventDateInput.value;
  let title = eventTitleInput.value;
  let description = eventDescriptionInput.value;

  if (date && title) {
    // Create a unique event ID
    let eventId = eventIdCounter++;

    events.push({
      id: eventId,
      date: date,
      title: title,
      description: description,
    });
    showCalendar1(currentMonth1, currentYear1);
    eventDateInput.value = "";
    eventTitleInput.value = "";
    eventDescriptionInput.value = "";
    displayReminders();
  }
}

// Function to delete an event by ID
function deleteEvent(eventId) {
  // Find the index of the event with the given ID
  let eventIndex = events.findIndex((event) => event.id === eventId);

  if (eventIndex !== -1) {
    // Remove the event from the events array
    events.splice(eventIndex, 1);
    showCalendar1(currentMonth1, currentYear1);
    displayReminders();
  }
}

// Function to display reminders
function displayReminders() {
  reminderList.innerHTML = "";
  for (let i = 0; i < events.length; i++) {
    let event = events[i];
    let eventDate = new Date(event.date);
    if (
      eventDate.getMonth() === currentMonth1 &&
      eventDate.getFullYear() === currentYear1
    ) {
      let listItem = document.createElement("li");
      listItem.innerHTML = `<strong>${event.title}</strong> - 
            ${event.description}
            (${eventDate.toLocaleDateString()})`;

      // Add a delete button for each reminder item
      let deleteButton = document.createElement("button");
      deleteButton.className = "delete-event";
      deleteButton.textContent = "Elimina";
      deleteButton.onclick = function () {
        deleteEvent(event.id);
      };

      listItem.appendChild(deleteButton);
      reminderList.appendChild(listItem);
    }
  }
}

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

// Function to jump to a specific month and year
function jump() {
  currentYear1 = parseInt(selectYear1.value);
  currentMonth1 = parseInt(selectMonth1.value);
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
        cell.className = "date-picker";
        cell.innerHTML = "<span>" + date + "</span";

        if (
          date === today.getDate() &&
          year === today.getFullYear() &&
          month === today.getMonth()
        ) {
          cell.className = "date-picker selected";
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

  displayReminders();
}

// Function to create an event tooltip
function createEventTooltip(date, month, year) {
  let tooltip = document.createElement("div");
  tooltip.className = "event-tooltip";
  let eventsOnDate = getEventsOnDate(date, month, year);
  for (let i = 0; i < eventsOnDate.length; i++) {
    let event = eventsOnDate[i];
    let eventDate = new Date(event.date);
    let eventText = `<strong>${event.title}</strong> - 
            ${event.description}
            ${eventDate.toLocaleDateString()}`;
    let eventElement = document.createElement("p");
    eventElement.innerHTML = eventText;
    tooltip.appendChild(eventElement);
  }
  return tooltip;
}

// Function to get events on a specific date
function getEventsOnDate(date, month, year) {
  return events.filter(function (event) {
    let eventDate = new Date(event.date);
    return (
      eventDate.getDate() === date &&
      eventDate.getMonth() === month &&
      eventDate.getFullYear() === year
    );
  });
}

// Function to check if there are events on a specific date
function hasEventOnDate(date, month, year) {
  return getEventsOnDate(date, month, year).length > 0;
}

// Function to get the number of days in a month
function daysInMonth(iMonth, iYear) {
  return 32 - new Date(iYear, iMonth, 32).getDate();
}

// Call the showCalendar1 function initially to display the calendar
showCalendar1(currentMonth1, currentYear1);

/* Source: https://www.geeksforgeeks.org/how-to-create-a-dynamic-calendar-in-html-css-javascript/ */
