<?php
    // TODO: update login credential for this connection
    //open connection
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    
    // check for succesful connection
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST["login_button"])){
            $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
            $passwd = $_POST["password"];

            $qry = "SELECT passwd
                    FROM ut_registered ut_r
                    WHERE ut_r = ut_email";
            $qry_result = pg_query($connection, $qry);
            if (!$qry_result){
                echo "Something went wrong";
                echo pg_result_error($qry_result);
            }
            if (strcmp($qry_result[0]["passwd"], $passwd) != 0){
                echo "Wrong password, try again";
            }
        }
    }

    pg_close($connection); // close connection