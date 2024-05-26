<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=$_SESSION["email"] password=$_SESSION["password"]");
    
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_SESSION['admin']) && $_SESSION['admin']) {

            //$aptblock_id = $_SESSION['aptBlock'];
            $aptblock_id = 1;
            $user_id = $_SESSION['user_id'];
            $title = htmlspecialchars($_POST["admin-post-title"]);
            $content = htmlspecialchars($_POST["admin-post-content"]);

            $qry_bb_id = "SELECT bb_id FROM aptblock_bulletinboard 
                            WHERE aptblock_id = $aptblock_id AND bb_name = 'admin'";
            $bb_id = pg_fetch_result(pg_query($connection, $qry_bb_id), 0, 'bb_id');

            $qry_post = "INSERT INTO posts(bb_id, ut_owner_id, title, ttext, time_born, time_mod)
                            VALUES ('$bb_id', '$user_id', '$title', '$content', NOW(), NOW())";
            $result_post_insert = pg_query($connection, $qry_post);

            // Verifica se l'inserimento è avvenuto con successo
            if ($result_post_insert) {
                echo "Post sent successfully!";
                header("Location: /02-home.php");
            } else {
                echo "Post not sent, ERROR: " . pg_result_error($result_post_insert);
            }
        }
    }

    pg_close($connection);