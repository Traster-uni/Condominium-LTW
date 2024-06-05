<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }
    // ini_set('display_errors', 1);
    // ini_set('display_startup_errors', 1);
    // error_reporting(E_ALL);
    // Controllo se l'utente è autenticato
    if (!isset($_SESSION['ut_id']) && !isset($_SESSION['email']) && !isset($_SESSION['aptblock_id'])) {
        header("Location: ./01-login.php");
    }

    $user_id = $_SESSION["ut_id"];

    // Query per recuperare i ticket dal database
    $q = "SELECT t.*, tr.response_text, tr.response_time, ur.ut_id, ur.nome, ur.cognome,
                CASE 
                    WHEN (SELECT COUNT(*) FROM aptblock_admin aa WHERE aa.ut_id = ur.ut_id) > 0 THEN 'admin'
                    ELSE 'user'
                END as role
            FROM tickets t
            LEFT JOIN ticket_responses tr ON t.ticket_id = tr.ticket_id
            LEFT JOIN ut_registered ur ON tr.ut_id = ur.ut_id
            WHERE aptblock_admin = $user_id
            ORDER BY t.time_lastreplay DESC";
                
    $result = pg_query($connection, $q);

    // Inizializzo l'array dove salvare i dati dei tickets
    $ticketsByYear = array();

    // Recupero i dati
    while ($row = pg_fetch_assoc($result)) {
        $year = date('Y', strtotime($row['time_born']));

        if (!isset($ticketsByYear[$year][$row['ticket_id']])) {
            $ticketsByYear[$year][$row['ticket_id']] = [
                'ticket_id' => $row['ticket_id'],
                'title' => $row['title'],
                'time_born' => $row['time_born'],
                'status' => $row['status'],
                'time_lastreplay' => $row['time_lastreplay'],
                'comm_text' => $row['comm_text'],
                'img_fname' => $row['img_fname'],
                'replies' => []
            ];
        }

        if ($row['response_text']) {
            $ticketsByYear[$year][$row['ticket_id']]['replies'][] = [
                'response_text' => $row['response_text'],
                'response_time' => $row['response_time'],
                'role' => $row['role'],
                'sender_name' => $row['nome'] . ' ' . $row['cognome']
            ];
        }
    }
    
    // Transforma in json
    header('Content-Type: application/json');
    
    echo json_encode($ticketsByYear);