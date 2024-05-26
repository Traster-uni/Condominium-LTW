<?php
    // start session
    session_start(); 
    // enstablish connection
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=usr_login password=iamdolly");
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
            $qry_empw = "SELECT ut_id, ut_email
                            FROM ut_registered ut_r
                            WHERE ut_r.ut_email = '$email' AND ut_r.passwd = '$passwd'";
            $qry_empw_arr = array();
            $qry_empw_res = pg_query($connection, $qry_empw);
            if (!$qry_empw_res){ // error checking
                echo "Something went wrong<br>";
                echo pg_result_error($qry_empw_res);
            }

            // fetch associative array related to qry result
            $qry_empw_arr = pg_fetch_assoc($qry_empw_res);
            // close connection
            pg_close($connection);
            if ($qry_empw_arr){
                print_r($qry_empw_arr);
                if ($qry_empw_arr["ut_email"] === $email){
                    
                    $_SESSION["ut_id"] = $qry_empw_arr["ut_id"];
                    $_SESSION["email"] = $qry_empw_arr["ut_email"];
                    $_SESSION["admin"] = false;

                    $conn = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
                    if (!$conn) {
                        echo "Errore, connessione non riuscita.<br>";
                        exit;
                    } else {
                        echo "connected<br>";
                    }
                    $qry_adm = "SELECT COUNT(adm.ut_id)
                                FROM aptblock_admin adm 
                                    JOIN ut_registered ut_r ON adm.ut_id = ut_r.ut_id
                                WHERE ut_r.ut_id = ".$_SESSION["ut_id"];
                    $qry_adm_result = pg_query($conn, $qry_adm);
                    $qry_adm_arr = pg_fetch_assoc($qry_adm_result);
                    if (count($qry_adm_arr) == 1){
                        $_SESSION["admin"] = true;
                    }
                    $id_utente = $_SESSION["ut_id"];
                    $check_registered = pg_query($conn, "SELECT utreq_id FROM ut_owner WHERE utreq_id = $id_utente");
                    $check_admin = pg_query($conn, "SELECT ut_id FROM aptblock_admin WHERE ut_id = $id_utente");
                    // if (!pg_num_rows($check_registered)) {
                    //     pg_close($conn);
                    //     header("Location: ../../01-login_utente.html");
                    //     session_regenerate_id(true);
                    // } else {
                    //     pg_close($conn);
                    //     header("Location: ../../02-home.php");
                    //     session_regenerate_id(true);
                    // } 
    
                    if (pg_num_rows($check_admin)) {
                        pg_close($conn);
                        header("Location: ../../01-login_admin.php");
                    } else {
                        pg_close($conn);
                        header("Location: ../../02-home.php");
                    }
                }
            } else {
                exit("wrong email or password");
            }
        }
    }