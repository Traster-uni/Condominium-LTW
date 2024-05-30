<?php
    //session_start()
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    //$ut_id = $_SESSION['ut_id'];
    $ut_id = 7;
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['ticket_id'], $data['response_text'])) {
        echo json_encode(['success' => false, 'message' => 'Dati mancanti']);
        exit;
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $ticket_id = (int)$data['ticket_id'];
        $response_text = $data['response_text'];

        // Verifica se l'utente è un admin
        $adminQuery = "SELECT COUNT(*) FROM aptblock_admin WHERE ut_id = $1";
        $adminResult = pg_query_params($connection, $adminQuery, array($ut_id));
        if (!$adminResult) {
            throw new Exception('Errore nella verifica dell\'admin');
        }
        $isAdmin = pg_fetch_result($adminResult, 0, 0) > 0;

        // Recupera nome e cognome dell'utente
        $result = pg_query_params($connection, "SELECT nome, cognome FROM ut_registered WHERE ut_id = $1", [$ut_id]);
        $user = pg_fetch_assoc($result);
        $sender_name = $user['nome'] . ' ' . $user['cognome'];

        // Inserimento della risposta
        $insertQuery = "INSERT INTO ticket_responses (ticket_id, ut_id, response_text, response_time) VALUES ($1, $2, $3, NOW())";
        $insertResult = pg_query_params($connection, $insertQuery, array($ticket_id, $ut_id, $response_text));
        if (!$insertResult) {
            throw new Exception('Errore nell\'inserimento della risposta');
        }

        // Aggiornamento del timestamp dell'ultima risposta nel ticket
        $updateQuery = "UPDATE tickets SET time_lastreplay = NOW() WHERE ticket_id = $1";
        $updateResult = pg_query_params($connection, $updateQuery, array($ticket_id));
        if (!$updateResult) {
            throw new Exception('Errore nell\'aggiornamento del ticket');
        }

        echo json_encode(['success' => true, 'role' => $isAdmin ? 'admin' : 'user', 'sender_name' => $sender_name]);
    }
    pg_close($connection);