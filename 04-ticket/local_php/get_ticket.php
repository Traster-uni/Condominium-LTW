<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    // Controllo se l'utente è autenticato
    $user_id = 1; //IMPORTANTE: da modificare, user di prova

    // Query per recuperare i ticket dal database
    $q = "SELECT * FROM tickets WHERE ud_id = $user_id";
    //print_r($q);
    $result = pg_query($connection, $q);
    //print_r($result);

    // Inizializzo l'array dove salvare i dati dei tickets
    $ticketsByYear = array();

    //print_r(pg_fetch_assoc($result));
    // Recupero i dati
    while ($row = pg_fetch_assoc($result)) {
        $year = date('Y', strtotime($row['time_born']));
        $ticketsByYear[$year][] = $row;
    }
    
    // Transforma in json
    header('Content-Type: application/json');
    //echo json_encode(pg_fetch_all($result));
    echo json_encode($ticketsByYear);
