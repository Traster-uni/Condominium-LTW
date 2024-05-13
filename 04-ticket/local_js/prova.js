fetch('04-ticket/local_php/get_ticket.php', {
    method: "post",
    mode: "cors",
    headers: {
      "Content-Type": "application/json"
    },
    body: {data: "ticketsByYear"}
  })
    .then(response => {
        return response.text(); // returns text that can used as html
        response.json();  // returns json object
    }).catch(error => console.error('Errore nel recupero dei ticket:', error));