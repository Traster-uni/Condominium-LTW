<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    // Controllo se l'utente è autenticato
    $user_id = 1; //IMPORTANTE: da modificare, user di prova

    // Query per recuperare i ticket dal database
    $q = "SELECT * FROM tickets WHERE ud_id = $1";
    $result = pg_query_params($connection, $q, array($user_id));

    // Inizializzo l'array dove salvare i dati dei tickets
    $tickets = array();

    // Recupero i dati
    
