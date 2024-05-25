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

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

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
            if (strcmp($qry_em_arr["ut_email"], $email) == 1){
                echo "27: Wrong password, try again<br>";
            }


            $qry_passwd = "SELECT passwd, ut_id
                            FROM ut_registered ut_r
                            WHERE ut_r.ut_email = '$email'";
            $qry_pwd_res = pg_query($connection, $qry_passwd);
            if (!$qry_pwd_res){ // error checking
                echo "Something went wrong<br>";
                echo pg_result_error($qry_pwd_res);
            }
            pg_close($connection); // close connection

            // fetch associative array related to qry result
            $qry_pwd_arr = pg_fetch_assoc($qry_pwd_res);

            // check password
            if (strcmp($qry_pwd_arr["passwd"], $passwd) == 0){
                $_SESSION["ut_id"] = $qry_pwd_arr["ut_id"];
                $_SESSION["email"] = $qry_em_arr["ut_email"];
                $_SESSION["password"] = $qry_pwd_arr["passwd"];
                $_SESSION["admin"] = false;
                echo "<br> sessionValue: "; 
                print_r($_SESSION["ut_id"]);
                $conn = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
                $qry_adm = "SELECT COUNT(adm.ut_id)
                            FROM aptblock_admin adm 
                                JOIN ut_registered ut_r ON adm.ut_id = ut_r.ut_id
                            WHERE ut_r.ut_id = ".$_SESSION["ut_id"];
                $qry_adm_result = pg_query($conn, $qry_adm);
                $qry_adm_arr = pg_fetch_assoc($qry_adm_result);

                if (!$conn) {
                    echo "Errore, connessione non riuscita.<br>";
                    exit;
                } else {
                    echo "connected<br>";
                }

                if (count($qry_adm_arr) == 1){
                    $_SESSION["admin"] = true;
                }
                $id_utente = $_SESSION["ut_id"];
                $check_registered = pg_query($conn, "SELECT utreq_id FROM ut_owner WHERE utreq_id = $id_utente");
                /* if (!pg_num_rows($check_registered)) {
                    pg_close($conn);
                    header("Location: ../../01-login2.html");
                    session_regenerate_id(true);
                } else {
                    pg_close($conn);
                    header("Location: ../../02-home.php");
                    session_regenerate_id(true);
                } */
                pg_close($conn);
                header("Location: ../../02-home.php");
            } else {
                echo "Wrong password, try again<br>";
            }
        }
    }

    // refresh session id
    session_regenerate_id(true);
