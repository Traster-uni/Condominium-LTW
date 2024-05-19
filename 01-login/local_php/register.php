<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_register password=iamdolly");
    session_start();
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    //Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $nome = htmlspecialchars($_POST["nome"]);
        $cognome = htmlspecialchars($_POST["cognome"]);
        $dnascita = htmlspecialchars($_POST["data-nascita"]);
        $telefono = htmlspecialchars($_POST["telefono"]);
        $fiscalcode = htmlspecialchars($_POST["fiscal-code"]);
        $address = htmlspecialchars($_POST["address"]);
        $citta = htmlspecialchars($_POST["citta"]);
        $email = htmlspecialchars($_POST["email"]);
        $password = htmlspecialchars($_POST["password"]);
        $data = date("Y-m-d");

        //Preparo la query
        $q = "INSERT INTO ut_registered(nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) 
                VALUES ('$nome', '$cognome', '$dnascita', '$telefono', '$address', '$citta', '$email', '$password', '$data')";
        $result = pg_query($connection, $q);
        pg_close($connection);

        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_login password=iamdolly");
        $qry_usr = "SELECT ut_id, ut_email, passwd 
                            FROM ut_registered ut_r
                            WHERE ut_r.ut_email = '$email', ut_r.passwd = '$password'";
        $qry_usr_res = pg_query($connection, $qry_usr);
        if (!$qry_usr_res){ // error checking
            echo "34: Something went wrong<br>";
            echo pg_result_error($qry_usr_res);
        }
        // fetch associative array related to qry result
        $qry_usr_arr = pg_fetch_assoc($qry_usr_res);
        
        // TODO: GESTISCI LA CREAZIONE DELLE VARIABILI $_SESSION 

        // Verifica se l'inserimento è avvenuto con successo
        if ($result) {
            echo "Registrazione avvenuta con successo!";
            $_SESSION["ut_id"] = $qry_pwd_arr["ut_id"];
            $_SESSION["email"] = $qry_em_arr["ut_email"];
            $_SESSION["password"] = $qry_pwd_arr["passwd"];
            header("Location: ./02-home.php");
        } else {
            echo "Errore durante la registrazione: " . pg_last_error($connection);
        }
    }

    // Chiudi la connessione al database
    pg_close($connection);
    session_regenerate_id(true);
?>
    