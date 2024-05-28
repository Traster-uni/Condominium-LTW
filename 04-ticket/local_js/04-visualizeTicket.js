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
            const yearTickets = Object.values(ticketsByYear[year]);
            yearTickets.sort((a, b) => new Date(b.time_lastreplay) - new Date(a.time_lastreplay));

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
        Object.entries(ticketsByYear).forEach(([year, ticketsObj]) => {
            const tickets = Object.values(ticketsObj);
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
                    <th></th>
                </tr>
            `;

            // Aggiungere l'intestazione alla tabella
            table.appendChild(thead);

            // Creare il corpo della tabella e aggiungere le righe per ciascun ticket
            const tbody = document.createElement('tbody');
            
            tickets.forEach(ticket => {
                const row = document.createElement('tr');

                // Aggiungi una classe specifica in base al valore di ticket.status
                let statusClass = ticket.status === 'open' ? 'open' : 'closed';

                row.innerHTML = `
                    <td>${ticket.title}</td>
                    <td>${ticket.time_born}</td>
                    <td class="${statusClass}">${ticket.status}</td>
                    <td>${ticket.time_lastreplay}</td>
                    <td><button type="button" class="visualize-button" id="visualize-button" data-ticket-id="${ticket.ticket_id}">Visualizza</button>
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

        // Aggiungi la gestione del modale
        const modal = document.getElementById('ticket-modal');
        const ticketTitle = document.getElementById('ticket-title');
        const ticketCreationDate = document.getElementById('ticket-creation-date');
        const ticketStatus = document.getElementById('ticket-status');
        const ticketLastReply = document.getElementById('ticket-lastReply');
        const ticketContent = document.getElementById('ticket-content');
        const ticketReplies = document.getElementById('ticket-replies');
        const span = document.getElementsByClassName('close')[0];

        document.addEventListener('click', function(event) {
            if (event.target && event.target.classList.contains('visualize-button')) {
                const ticketId = event.target.getAttribute('data-ticket-id');
                const ticket = findTicketById(ticketId, ticketsByYear);
                if (ticket) {
                    ticketTitle.textContent = `${ticket.title}`;
                    ticketCreationDate.textContent = `Data Creazione: ${ticket.time_born}`;
                    ticketStatus.textContent = `Status: ${ticket.status}`;
                    ticketLastReply.textContent = `Ultima Risposta: ${ticket.time_lastreplay}`;
                    ticketContent.textContent = `${ticket.comm_text}`;
                    
                    ticketReplies.innerHTML = '';
                    ticket.replies.forEach(reply => {
                        const replyElement = document.createElement('div');
                        replyElement.className = 'reply';
                        replyElement.innerHTML = `
                            <strong>${reply.sender === 'admin' ? 'Admin' : 'Utente'}:</strong>
                            <p>${reply.response_text}</p>
                            <small>${new Date(reply.response_time).toLocaleString()}</small>
                        `;
                        ticketReplies.appendChild(replyElement);
                    });

                    const responseForm = document.createElement('div');
                    responseForm.innerHTML = `
                        <textarea id="responseText" placeholder="Scrivi la tua risposta qui..." rows="4" cols="50"></textarea>
                        <button id="sendResponse" type="button">Invia</button>
                    `;
                    ticketReplies.appendChild(responseForm);

                    const responseText = responseForm.querySelector('#responseText');
                    const sendResponse = responseForm.querySelector('#sendResponse');

                    const userLastReply = checkIfUserReplied(ticket);
                    if (ticket.status === 'open' && userLastReply) {
                        responseText.disabled = false;
                        sendResponse.disabled = false;
                    } else {
                        responseText.disabled = true;
                        sendResponse.disabled = true;
                    }

                    sendResponse.setAttribute('data-ticket-id', ticketId);

                    modal.style.display = "block";
                }
            }
        });

        span.onclick = function() {
            modal.style.display = "none";
        }

        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }

        function findTicketById(ticketId, ticketsByYear) {
            for (const year in ticketsByYear) {
                const tickets = Object.values(ticketsByYear[year]);
                const ticket = tickets.find(ticket => ticket.ticket_id == ticketId);
                if (ticket) {
                    return ticket;
                }
            }
            return null;
        }

        function checkIfUserReplied(ticket) {
            const userRole = ticket.replies.length > 0 ? ticket.replies[ticket.replies.length - 1].role : null;
            return userRole !== 'admin';
        }

        // Gestione di invio delle risposte
        document.addEventListener('click', function(event) {
            if (event.target && event.target.id === 'sendResponse') {
                const ticketId = event.target.getAttribute('data-ticket-id');
                const response = document.getElementById('responseText').value;
                if (response.trim() !== "") {
                    sendTicketResponse(ticketId, response);
                }
            }
        });

        function sendTicketResponse(ticketId, response) {
            fetch('04-ticket/local_php/send_response.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    ticket_id: ticketId,
                    response_text: response
                }),
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Risposta inviata con successo!');
                    modal.style.display = "none";
                    ticketReplies.value = "";
                } else {
                    alert('Errore nell\'invio della risposta. Riprova.');
                }
            })
            .catch(error => {
                console.error('Errore:', error);
                alert('Errore nell\'invio della risposta. Riprova.');
            });
        }

    }).catch(error => console.error('Errore nel recupero dei ticket:', error));
