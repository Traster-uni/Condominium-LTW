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
        header("Location: ../../01-login_admin.php");
        session_regenerate_id(true);
    }
?>
