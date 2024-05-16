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
    // may be removed as we don't use HTTPS for logon
    session_set_cookie_params([
        'lifetime' => 0, // Session cookie lasts until the browser is closed
        'path' => '/',
        'secure' => isset($_SERVER['HTTPS']), // True if using HTTPS
        'httponly' => true, // Prevents JavaScript access to session cookie
        'samesite' => 'Strict', // Strict or Lax depending on your needs
    ]);

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST["login_button"])){
            $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
            $passwd = $_POST["password"];
            $qry_email = "SELECT ut_email
                            FROM ut_registered ut_r
                            WHERE ut_r = ut_email";
            $qry_email_result = pg_query($connection, $qry_email);
            if (!$qry_email_result){
                echo "Something went wrong";
                echo pg_result_error($qry_result);                
            }
            if (strcmp($qry_email_result[0]["email"], $email) != 0){
                echo "Wrong password, try again";
            }
            $qry_passwd = "SELECT passwd, ut_id
                    FROM ut_registered ut_r
                    WHERE ut_r = ut_email";
            $qry_passwd_result = pg_query($connection, $qry_passwd);
            if (!$qry_passwd_result){
                echo "Something went wrong";
                echo pg_result_error($qry_passwd_result);
            }
            if (strcmp($qry_passwd_result[0]["passwd"], $passwd) == 0){
                $_SESSION["ut_id"] = $qry_passwd_result[0]["ut_id"];
                $_SESSION["email"] = $qry_email_result[0]["email"];
                $_SESSION["password"] = $qry_passwd_result[0]["passwd"];
            } else {
                echo "Wrong password, try again";
            }
        }
    }

    pg_close($connection); // close connection
    session_regenerate_id(true);
