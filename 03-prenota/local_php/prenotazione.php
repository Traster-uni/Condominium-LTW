<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");

    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "Connected";
    }

    //Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $submit_time = date("Y-m-d H:i:s");
        $giorno = intval($_POST["giorno"]);
        $mese = intval($_POST["mese"]);
        $anno = intval($_POST["anno"]);
        $inizio = date("Y-m-d H:i:s", mktime(10, 0, 0, $mese, $giorno, $anno));
        $fine = date("Y-m-d H:i:s", mktime(12, 0, 0, $mese, $giorno, $anno));

        //Preparo la query
        $q = "INSERT INTO rental_request(ut_id, adm_id, submit_time, stat, rental_datatime_start, rental_datatime_end)
        VALUES ('1', '1', '$submit_time', 'pending', '$inizio', '$fine')";
        $result = pg_query($connection, $q);

        // Verifica se l'inserimento è avvenuto con successo
        if ($result) {
            echo "Prenotazione avvenuta con successo!";
            header("Location: /03-prenota.php");
        } else {
            echo "Errore durante la prenotazione: " . pg_last_error($connection);
        }
    }

    // Chiudi la connessione al database
    pg_close($connection);
?>