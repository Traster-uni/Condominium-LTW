fetch('04-ticket/local_php/get_ticket.php')
    .then(response => response.json())
    .then(ticketsByYear => {
        // Ottieni il riferimento all'elemento contenitore dei bottoni
        const tabContainer = document.querySelector('.tab');

        // Ottengo l'anno corrente
        const currentDate = new Date().getFullYear();

        // Ordino gli anni del json
        const years = Object.keys(ticketsByYear).sort((a, b) => b - a);

        // Itera sui ticket per ogni anno
        years.forEach(year => {
            // Ordino in base alla lastreplay
            ticketsByYear[year].sort((a, b) => new Date(b.time_lastreplay) - new Date(a.time_lastreplay));

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

                // Aggiungi una classe specifica in base al valore di ticket.status
                let statusClass = '';
                if (ticket.status === 'open') {
                    statusClass = 'open';
                } else {
                    statusClass = 'closed';
                }

                row.innerHTML = `
                    <td>${ticket.title}</td>
                    <td>${ticket.time_born}</td>
                    <td class="${statusClass}">${ticket.status}</td>
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

    }).catch(error => console.error('Errore nel recupero dei ticket:', error));
