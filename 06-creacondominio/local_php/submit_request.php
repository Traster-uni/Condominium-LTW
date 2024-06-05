<?php
    // adm fa richiesta per un nuovo condominino
    // la richiesta entra nel db come pending
    // lo staff puo rifiutarla o accettarla, visualizzando i documenti e i dati inseriti
    // alla accettazione l'istanza di aptblock con le relative bacheche viene genereata automaticamente dal database tramite triggers
    
    // start session
    session_start();

    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
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
        // insert variables from form
        $address = htmlspecialchars($_POST[""]);
        $city = htmlspecialchars($_POST[""]);
        $cap = htmlspecialchars($_POST[""]);
        $usr_id = $_SESSION['ut_id'];
        
        $qry_chk = "SELECT ut_id, addr_aptb, city
                    FROM req_aptblock_create rac
                    WHERE rac.ut_id = $usr_id";
        $qry_chk_res = pg_query($connection, $qry_chk);
        if (!$qry_chk_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_chk_res);
        }

        // fetch associative array related to qry result
        $qry_em_arr = pg_fetch_assoc($qry_chk_res);
        if ($qry_chk_arr['city'] === $city && $qry_chk_arr['adr_aptb'] === $address ){
                echo "it already exists an appartament block with the same address in the same city<br>";
        }

        $qry_insrt = "INSERT INTO req_aptblock_create(ut_id, stat, addr_aptb, city, cap) 
                        VALUES ($usr_id, $address, $city, $cap)";
        $qry_insrt_res = pg_query($connection, $qry_insrt);
        if (!$qry_insrt_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_insrt_res);
        }
    }

    $pg_close($connection);