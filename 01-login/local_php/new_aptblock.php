<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    session_start();
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected<br>";
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        
        $id_admin = $_SESSION['ut_id'];
        $città = htmlspecialchars($_POST["città"]);
        $indirizzo = htmlspecialchars($_POST["indirizzo"]);
        $cap = htmlspecialchars($_POST["cap"]);

        $qry_chk = "SELECT ut_id, addr_aptb, city
                    FROM req_aptblock_create rac
                    WHERE rac.ut_id = $id_admin";
        $qry_chk_res = pg_query($connection, $qry_chk);
        if (!$qry_chk_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_chk_res);
        }

        // fetch associative array related to qry result
        $qry_em_arr = pg_fetch_assoc($qry_chk_res);
        if ($qry_chk_arr['city'] === $città && $qry_chk_arr['adr_aptb'] === $indirizzo ){
                echo "it already exists an appartament block with the same address in the same city<br>";
                //refresh ??
        }
        
        //Preparo la query
        $q = "INSERT INTO req_aptblock_create(ut_id, city, addr_aptb, cap, stat)
            VALUES ('$id_admin', '$città', '$indirizzo', '$cap', 'pending')";
        $result = pg_query($connection, $q);
    }

    $check_aptblock = pg_query($connection, "SELECT stat FROM req_aptblock_create WHERE ut_id = $id_admin");
    if ($check_aptblock == 'accepted') {
        pg_close($connection);
        header("Location: ../../02-home.php");
        session_regenerate_id(true);
    } else {
        pg_close($connection);
        header("Location: ../../01-login_admin.html");
        session_regenerate_id(true);
    }
?>
