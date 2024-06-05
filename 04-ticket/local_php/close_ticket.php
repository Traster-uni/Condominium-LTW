<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] == 'POST' && $_SESSION['admin']) {
        $data = json_decode(file_get_contents('php://input'), true);
        $ticket_id = $data['ticket_id'];

        $query = "UPDATE tickets SET status = 'closed' WHERE ticket_id = $ticket_id";
        $result = pg_query($connection, $query);

        if (!$result) {
            throw new Exception('Errore nell\'aggiornamento del ticket');
        }

        echo json_encode(['success' => true]);
    }
    
    pg_free_result($result);
    pg_close();