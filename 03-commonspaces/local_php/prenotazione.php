<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=$_SESSION["email"] password=$_SESSION["password"]");

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
        $time_start = $_POST['time_start'];
        $time_end = $_POST['time_end'];
        list($ora_inizio, $minuto_inizio) = explode(':', $time_start);
        list($ora_fine, $minuto_fine) = explode(':', $time_end);
        $ora_inizio = (int)$ora_inizio;
        $minuto_inizio = (int)$minuto_inizio;
        $ora_fine = (int)$ora_fine;
        $minuto_fine = (int)$minuto_fine;
        $inizio = date("Y-m-d H:i:s", mktime($ora_inizio, $minuto_inizio, 0, $mese, $giorno, $anno));
        $fine = date("Y-m-d H:i:s", mktime($ora_fine, $minuto_fine, 0, $mese, $giorno, $anno));
        $id_utente = $_SESSION['ut_id'];
        $id_luogo = intval($_POST["cs_id"]);

        $check1 = pg_query($connection, "SELECT utreq_id as ut_id FROM ut_owner");
        $check2 = pg_fetch_assoc($check1);
        if (in_array($id_utente, $check2)) {
            echo "Errore, l'utente non fa parte di un condominio";
        }

        //Preparo la query
        $q = "INSERT INTO rental_request(ut_id, cs_id, submit_time, stat, rental_datetime_start, rental_datetime_end)
        VALUES ('$id_utente', '$id_luogo', '$submit_time', 'pending', '$inizio', '$fine')";
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

<!--
ERRORE: A rental request in the same time period already exists quando faccio una prenotazione nello stesso giorno di un'altra anche se hanno orari diversi
-->