function ticketSubmit(event) {
    event.preventDefault();
    
    var titolo = document.getElementById("titolo").value();
    var dataCreazione = new Date().toJSON().slice(0, 10);

    // Creazione di una nuova riga per la tabella
    var tabella = document.getElementById("table2024").getElementsByTagName("tbody")[0];
    var newRow = tabella.insertRow(tabella.rows.length);
    var cell1 = newRow.insertCell(0);  
    var cell2 = newRow.insertCell(1);
    var cell3 = newRow.insertCell(2);
    var cell4 = newRow.insertCell(3);

    // Inserimento dei valori nei campi della nuova riga
    cell1.textContent = titolo;
    cell2.textContent = dataCreazione;
    cell3.textContent = "prova";
    cell4.textContent = "Nessuna Risposta";

    document.getElementById("titolo").value = "";
    document.getElementById("descrizione").value = "";

    return false;
}