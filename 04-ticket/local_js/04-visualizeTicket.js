document.addEventListener('DOMContentLoaded', async () => {
    await checkUserRole();
});

async function checkUserRole() {
    try {
        const response = await fetch('/global/04-php/get_user_role.php', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('User role fetched successfully:', data);

        if (data.role === 'user') {
            fetchAndDisplayTickets('04-ticket/local_php/get_ticket_ud.php', 'user');
        } else if (data.role === 'admin') {
            fetchAndDisplayTickets('04-ticket/local_php/get_all_ticket.php', 'admin');
        }
    } catch (error) {
        console.error('Error fetching user role:', error);
    }
}

function enableTicketPosting() {
    const centralBody = document.getElementById('form-container');
    if (centralBody) {
        centralBody.innerHTML = `
            <button data-toggle="collapse" data-toggle="formTicket" class="openBtn">
                <h1>Nuovo Ticket</h1>
                <span class="material-symbols-outlined">add</span>
            </button>
            <div class="collapse" id="formTicket">
                <form id="ticketForm" enctype="multipart/form-data" method="post" action="./04-ticket/local_php/submit_ticket.php">
                    <h4>Titolo</h4>
                    <input type="text" name="titolo" id="titolo" size="50" required />
                    <h4>Descrizione</h4>
                    <textarea class="descrizione" name="descrizione" id="descrizione" cols="50" rows="10" minlength="50" required></textarea>
                    <br />
                    <input type="file" name="file" id="file" />
                    <input type="submit" value="Invia" />
                    <input type="reset" />
                </form>
            </div>
        `;
    }
    var nuovoTicketBtn = document.querySelector('.openBtn');
  
    // Aggiungi l'evento di click al pulsante "Nuovo Ticket"
    nuovoTicketBtn.addEventListener('click', function() {
        // Toggle della classe "active" sul pulsante
        this.classList.toggle('active');
  
        // Seleziona l'elemento successivo al pulsante (il form ticket)
        var content = this.nextElementSibling;
  
        // Verifica se lo stile maxHeight è già impostato
        if (content.style.maxHeight) {
            // Se è impostato, rimuovi il maxHeight
            content.style.maxHeight = null;
        } else {
            // Altrimenti, imposta il maxHeight per far espandere il form completamente
            content.style.maxHeight = content.scrollHeight + 'px';
        }
    });
}

async function fetchAndDisplayTickets(fetchUrl, currentUserRole) {
    try {
        const response = await fetch(fetchUrl);
        const tickets = await response.json(); // <---
        console.log('Tickets fetched successfully:', tickets);

        // Conta il numero di ticket aperti dell'utente
        const openTicketsCount = Object.values(tickets).filter(ticket => ticket.status === 'open').length;

        // Se l'utente ha meno di 5 ticket aperti, abilita l'invio di nuovi ticket
        if (openTicketsCount < 5 && currentUserRole === 'user') {
            enableTicketPosting();
        } else if (openTicketsCount >= 5 && currentUserRole === 'user') {
            alert("Troppi ticket aperti, devi assicurarti di concluderne qualcuno prima di inviarne di nuovi")
        }

        // Visualizza i ticket
        displayTickets(tickets, currentUserRole);
    } catch (error) {
        console.error('Error fetching tickets:', error);
    }
}

function displayTickets(ticketsByYear, currentUserRole) {
    const tabContainer = document.getElementById('ticket-tab');
    if (!tabContainer) {
        console.error('Tab container not found');
        return;
    }
    const currentDate = new Date().getFullYear();
    const years = Object.keys(ticketsByYear).sort((a, b) => b - a);

    years.forEach(year => {
        const yearTickets = Object.values(ticketsByYear[year]);
        yearTickets.sort((a, b) => new Date(b.time_lastreplay) - new Date(a.time_lastreplay));

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

        tabContainer.appendChild(button);
    });

    Object.entries(ticketsByYear).forEach(([year, ticketsObj]) => {
        const tickets = Object.values(ticketsObj);
        const section = document.createElement('section');
        section.id = year;
        section.className = 'tabcontent';

        const table = document.createElement('table');
        table.className = 'table-ticket';
        table.id = 'table' + year;
        table.setAttribute('border', '1px');

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

        table.appendChild(thead);

        const tbody = document.createElement('tbody');
        tickets.forEach(ticket => {
            const row = document.createElement('tr');
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

        table.appendChild(tbody);
        section.appendChild(table);
        tabContainer.appendChild(section);
    });

    const currentTab = document.getElementById("currentDate");
    if (currentTab) {
        currentTab.click();
    } else {
        console.error('Current date tab not found');
    }

    const modal = document.getElementById('ticket-modal');
    const ticketTitle = document.getElementById('ticket-title');
    const ticketCreationDate = document.getElementById('ticket-creation-date');
    const ticketStatus = document.getElementById('ticket-status');
    const ticketContent = document.getElementById('ticket-content');
    const ticketReplies = document.getElementById('ticket-replies');
    const ticketResponseForm = document.getElementById('ticket-response-form');
    const span = document.getElementsByClassName('close')[0];

    document.addEventListener('click', function(event) {
        if (event.target && event.target.classList.contains('visualize-button')) {
            const ticketId = event.target.getAttribute('data-ticket-id');
            const ticket = findTicketById(ticketId, ticketsByYear);
            if (ticket) {
                ticketTitle.textContent = `Titolo: ${ticket.title}`;
                ticketCreationDate.textContent = `Data Creazione: ${ticket.time_born}`;
                ticketStatus.textContent = `Status: ${ticket.status}`;
                ticketContent.textContent = `${ticket.comm_text}`;
                
                ticketReplies.innerHTML = '';
                ticket.replies.sort((a, b) => new Date(a.response_time) - new Date(b.response_time));
                ticket.replies.forEach(reply => {
                    const replyElement = document.createElement('div');
                    replyElement.className = 'reply';
                    replyElement.innerHTML = `
                        <div class="responses">
                            <strong>${reply.sender_name}</strong>
                            <p class="response-text">${reply.response_text}</p>
                            <p class="response-time">${new Date(reply.response_time).toLocaleString()}</small>
                        </div>
                    `;
                    ticketReplies.appendChild(replyElement);
                });

                // Rimuovi eventuali form di risposta esistenti
                while (ticketResponseForm.firstChild) {
                    ticketResponseForm.removeChild(ticketResponseForm.firstChild);
                }
            
                const responseForm = document.createElement('div');
                responseForm.innerHTML = `
                    <textarea id="responseText" placeholder="Scrivi la tua risposta qui..." rows="4" cols="50"></textarea>
                    <div class="button-container">
                        <button id="sendResponse" type="button">Invia</button>
                    </div>
                `;
                ticketResponseForm.appendChild(responseForm);
            
                const responseText = responseForm.querySelector('#responseText');
                const sendResponse = responseForm.querySelector('#sendResponse');
            
                if (ticket.status === 'open') {
                    responseText.disabled = false;
                    sendResponse.disabled = false;
                } else {
                    responseText.disabled = true;
                    sendResponse.disabled = true;
                }
            
                sendResponse.setAttribute('data-ticket-id', ticketId);

                // Aggiunge il pulsante "Chiudi Ticket" per gli admin
                if (currentUserRole === 'admin') {
                    const closeButton = document.createElement('button');
                    closeButton.textContent = 'Chiudi Ticket';
                    closeButton.id = 'close-ticket';
                    closeButton.setAttribute('data-ticket-id', ticketId);
                    closeButton.addEventListener('click', closeTicket);
                    responseForm.querySelector('.button-container').appendChild(closeButton);
                }

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
                const replyElement = document.createElement('div');
                replyElement.className = 'reply';
                const senderName = data.sender_name;
                replyElement.innerHTML = `
                    <strong>${senderName}:</strong>
                    <p>${response}</p>
                    <small>${new Date().toLocaleString()}</small>
                `;
                const responseForm = document.querySelector('#responseText').parentElement;
                document.getElementById('ticket-replies').insertBefore(replyElement, responseForm);

                document.getElementById('responseText').value = "";
            } else {
                alert('Errore nell\'invio della risposta. Riprova.');
            }
        })
        .catch(error => {
            console.error('Errore:', error);
            alert('Errore nell\'invio della risposta. Riprova.');
        });
    };

    function closeTicket(event) {
        const ticketId = event.target.getAttribute('data-ticket-id');
        if (confirm('Sei sicuro di voler chiudere questo ticket?')) {
            fetch('04-ticket/local_php/close_ticket.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    ticket_id: ticketId
                }),
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Ticket chiuso con successo!');
                    modal.style.display = "none";
                    fetchAndDisplayTickets('04-ticket/local_php/get_ticket_ud.php', 'admin');
                } else {
                    alert('Errore nella chiusura del ticket. Riprova.');
                }
            })
            .catch(error => {
                console.error('Errore:', error);
                alert('Errore nella chiusura del ticket. Riprova.');
            });
        }
    }
}

function openTab(evt, year) {
    const tabcontent = document.getElementsByClassName("tabcontent");
    for (let i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    const tablinks = document.getElementsByClassName("tablinks");
    for (let i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    document.getElementById(year).style.display = "block";
    evt.currentTarget.className += " active";
}

