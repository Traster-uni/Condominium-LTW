<?php

    // open connection with readonly auth on data
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_login password=iamdolly");
    // start session
    session_start();
    // check for succesful connection
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected<br>";
    }

    // ini_set('display_errors', 1);
    // ini_set('display_startup_errors', 1);
    // error_reporting(E_ALL);

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST["login_button"])){
            $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
            $passwd = $_POST["password"];
            $qry_email = "SELECT ut_email
                            FROM ut_registered ut_r
                            WHERE ut_r.ut_email = '$email'";
            $qry_em_res = pg_query($connection, $qry_email);
            if (!$qry_em_res){ // error checking
                echo "Something went wrong<br>";
                echo pg_result_error($qry_em_res);
            }

            // fetch associative array related to qry result
            $qry_em_arr = pg_fetch_assoc($qry_em_res);
            // check passwd
            if (strcmp($qry_em_arr["ut_email"], $email) != 0){
                echo "27: Wrong password, try again<br>";
            }


            $qry_passwd = "SELECT passwd, ut_id
                            FROM ut_registered ut_r
                            WHERE ut_r.ut_email = '$email' and ut_r.passwd = '$password'"; // AND ut_r.passwd = $passwd
            $qry_pwd_res = pg_query($connection, $qry_passwd);
            if (!$qry_pwd_res){ // error checking
                echo "Something went wrong<br>";
                echo pg_result_error($qry_pwd_res);
            }

            // fetch associative array related to qry result
            $qry_pwd_arr = pg_fetch_assoc($qry_pwd_res);
            
            // check password
            if (strcmp($qry_pwd_arr["passwd"], $passwd) == 0){
                $_SESSION["ut_id"] = $qry_pwd_arr["ut_id"];
                $_SESSION["email"] = $qry_em_arr["ut_email"];
                $_SESSION["password"] = $qry_pwd_arr["passwd"];
                // login succesfully, enter home menu
                // chdir("../..");
                header("Location: ../../02-home.php");
            } else {
                echo "Wrong password, try again<br>";
            }
        }
    }

    pg_close($connection); // close connection
    // refresh session id
    session_regenerate_id(true);
