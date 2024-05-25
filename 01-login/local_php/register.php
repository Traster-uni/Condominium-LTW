<?php
    
    session_start();

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    // TODO: CONTROLLO SE L'UTENTE GIA ESISTE PRIMA DI CREARE RUOLO
    // Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        
        $nome = htmlspecialchars($_POST["nome"]);
        $cognome = htmlspecialchars($_POST["cognome"]);
        $dnascita = htmlspecialchars($_POST["data-nascita"]);
        $telefono = htmlspecialchars($_POST["telefono"]);
        $fiscalcode = htmlspecialchars($_POST["fiscal-code"]); //
        $address = htmlspecialchars($_POST["address"]);
        $citta = htmlspecialchars($_POST["citta"]);
        $email = htmlspecialchars($_POST["email"]);
        $password = htmlspecialchars($_POST["password"]);


        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_login password=iamdolly");
        //Verifico che la connessione è avvenuta con successo
        if (!$connection) {
            echo "Errore, connessione non riuscita.<br>";
            exit;
        } else {
            echo "connected<br>";
        }
        $qry_check = "SELECT *
                        FROM ut_registered
                       WHERE ut_registered.ut_email = $email";
        $qry_check_res = pg_query($connection, $qry_check);
        if (!$qry_check_res){
            echo "Something went wrong<br>";
            echo pg_result_error($qry_usr_res);
        }
        $qry_check_arr = pg_fetch_assoc($qry_check_res);
        if ($email === $qry_check_arr['ut_email']){
            echo "THE ACCOUNT ALREADY EXISTS<br>";
        } 
        if ($telefono === $qry_check_arr['telefono']){
            echo "THE TELEPHONE NUMBER IT'S ALREADY ASSOCIATED WITH ANOTHER ACCOUNT<br>";
        }
        // else if ($fiscalcode === $qry_check_arr['fiscalcode'])
        pg_close($connection);


        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_register password=iamdolly");
        //Preparo la query
        $q = "INSERT INTO ut_registered(nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd) 
                VALUES ('$nome', '$cognome', '$dnascita', '$telefono', '$address', '$citta', '$email', '$password')";
        $result = pg_query($connection, $q);
        pg_close($connection);

        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_login password=iamdolly");
        $qry_usr = "SELECT ut_id, ut_email, passwd 
                    FROM ut_registered ut_r
                    WHERE ut_r.ut_email = '$email' and ut_r.passwd = '$password'";
        $qry_usr_res = pg_query($connection, $qry_usr);
        if (!$qry_usr_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_usr_res);
        }
        // fetch associative array related to qry result
        $qry_usr_arr = pg_fetch_assoc($qry_usr_res); 

        // Verifica se l'inserimento è avvenuto con successo
        if (count($qry_usr_arr) !== 0) { // if not empty
            echo "Registrazione avvenuta con successo!<br>";
            $_SESSION["ut_id"] = $qry_usr_arr["ut_id"];
            $_SESSION["email"] = $qry_usr_arr["ut_email"];
            $_SESSION["password"] = $qry_usr_arr["passwd"];
            header("Location: ../../02-home.php");
        } else {
            echo "Errore durante la registrazione: " . pg_last_error($connection);
        }
        pg_close($connection);
    }

    // Chiudi la connessione al database
    session_regenerate_id(true);
?>
    