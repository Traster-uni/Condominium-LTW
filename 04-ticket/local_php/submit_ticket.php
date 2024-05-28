<?php
    //session_start()
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=user_condominium");
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    //Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $titolo = htmlspecialchars($_POST["titolo"]);
        $comm_text = htmlspecialchars($_POST["descrizione"]);
        $id = 2; // TODO: modify to adapt to instance connection
        // $id = $_SESSION["ut_id"];
        $data = date("Y-m-d");

        //Query per prendere l'id dell'admin
        $query = "SELECT req_aptblock_create.ut_id AS admin_id 
                    FROM req_ut_access 
                    JOIN req_aptblock_create ON req_ut_access.aptblock_id = req_aptblock_create.aptblockreq_id 
                    WHERE req_ut_access.status = 'accepted' 
                    AND req_ut_access.ut_id = $id";
        $admin_id = pg_fetch_result(pg_query($connection, $query), 0, 'admin_id');

        //Preparo la query
        $qry_ticket = "INSERT INTO tickets(ud_id, aptblock_admin, title, comm_text, time_born, time_lastreplay, status) 
                        VALUES ('$id', '$admin_id', '$titolo', '$comm_text', '$data', '$data', 'open')";
        $result_ticket_insert = pg_query($connection, $qry_ticket);

        // Verifica se l'inserimento è avvenuto con successo
        if ($result_ticket_insert) {
            echo "Ticket sent successfully!";
            header("Location: ../../04-ticket.php");
        } else {
            echo "Ticket not sent, ERROR: " . pg_result_error($result_ticket_insert);
        }
    }

    // Chiudi la connessione al database
    pg_close($connection);