<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=$_SESSION["email"] password=$_SESSION["password"]");
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }
    // Controllo se l'utente è autenticato
    $user_id = 1; //IMPORTANTE: da modificare, user di prova
    // $user_id = $_SESSION["ut_id"];

    // Query per recuperare i ticket dal database
    $q = "SELECT * FROM tickets WHERE ud_id = $user_id";
    $result = pg_query($connection, $q);

    // Inizializzo l'array dove salvare i dati dei tickets
    $ticketsByYear = array();

    // Recupero i dati
    while ($row = pg_fetch_assoc($result)) {
        $year = date('Y', strtotime($row['time_born']));
        $ticketsByYear[$year][] = $row;
    }
    
    // Transforma in json
    header('Content-Type: application/json');
    
    echo json_encode($ticketsByYear);
