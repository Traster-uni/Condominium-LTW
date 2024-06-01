<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    session_start();
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $req_id = $_POST['req_id'];
        $stato = $_POST['stato'];

        $q = "UPDATE rental_request SET stat = '$stato' WHERE rental_req_id = '$req_id'";
        $result = pg_query($connection, $q);
    }
?>
