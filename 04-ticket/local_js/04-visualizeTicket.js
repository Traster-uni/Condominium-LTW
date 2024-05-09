fetch('04-ticket/local_php/get_ticket.php')
    .then(response => response.json())
    .then(ticketsByYear => {
        // Ottieni il riferimento all'elemento contenitore dei bottoni
        const tabContainer = document.querySelector('.tab');

        const currentDate = new Date().getFullYear();
        // Itera sui ticket per ogni anno
        Object.keys(ticketsByYear).forEach(year => {
            // Creare il bottone per l'anno corrente
            const button = document.createElement('button');
            const annoButton = parseInt(year);
            button.className = 'tablinks';
            button.textContent = year;
            button.addEventListener('click', function() {
                openTab(event, year);
            });
            if (annoButton === currentDate) {
                button.id = 'currentDate';
            }

            // Aggiungere il bottone al contenitore dei bottoni
            tabContainer.appendChild(button);
        });

        const br = document.createElement('br');

        // Creare le sezioni e le tabelle per ciascun anno
        Object.entries(ticketsByYear).forEach(([year, tickets]) => {
            // Creare la sezione per l'anno corrente
            const section = document.createElement('section');
            section.id = year;
            section.className = 'tabcontent';

            // Creare la tabella per l'anno corrente
            const table = document.createElement('table');
            table.className = 'table-ticket';
            table.id = 'table' + year;
            table.setAttribute('border', '1px');

            // Creare l'intestazione della tabella
            const thead = document.createElement('thead');
            thead.innerHTML = `
                <tr>
                    <th><h2>Titolo</h2></th>
                    <th><h2>Data Creazione</h2></th>
                    <th><h2>Status</h2></th>
                    <th><h2>Ultima Risposta</h2></th>
                </tr>
            `;

            // Aggiungere l'intestazione alla tabella
            table.appendChild(thead);

            // Creare il corpo della tabella e aggiungere le righe per ciascun ticket
            const tbody = document.createElement('tbody');
            tickets.forEach(ticket => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${ticket.title}</td>
                    <td>${ticket.time_born}</td>
                    <td>${ticket.status}</td>
                    <td>${ticket.time_lastreplay}</td>
                `;
                tbody.appendChild(row);
            });

            // Aggiungere il corpo della tabella alla tabella
            table.appendChild(tbody);

            // Aggiungere la tabella alla sezione
            section.appendChild(table);

            // Aggiungere la sezione alla pagina
            tabContainer.appendChild(section);
        });
        document.getElementById("currentDate").click();
    })
    .catch(error => console.error('Errore nel recupero dei ticket:', error));
