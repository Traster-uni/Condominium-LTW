<?php
    // adm fa richiesta per un nuovo condominino
    // la richiesta entra nel db come pending
    // lo staff puo rifiutarla o accettarla, visualizzando i documenti e i dati inseriti
    // alla accettazione l'istanza di aptblock con le relative bacheche viene genereata automaticamente dal database tramite triggers

    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    // start session
    session_start();
    // check for succesful connection
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected<br>";
    }

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    if ($_SERVER["REQUEST_METHOD"] == "POST"){
        $qry_chk = "";
        $qry_chk_res = pg_query($connection, $qry_chk);

        if (!$qry_chk_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_chk_res);
        }

        // fetch associative array related to qry result
        $qry_em_arr = pg_fetch_assoc($qry_chk_res);
    } 