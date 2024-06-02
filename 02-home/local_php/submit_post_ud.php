<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $aptblock_id = $_SESSION['aptblock_id'];
        $user_id = $_SESSION['ut_id'];

        $title = htmlspecialchars($_POST["ud-post-title"]);
        $content = htmlspecialchars($_POST["ud-post-content"]);
        $name_tag = htmlspecialchars($_POST["tags"]);
        
        $qry_post = "SELECT last_value+1 AS new_id FROM posts_post_id_seq";
        $qry_bb_id = "SELECT bb_id FROM aptblock_bulletinboard 
                        WHERE aptblock_id = $aptblock_id AND bb_name = 'general'";
        $qry_ut_owner_id = "SELECT utreq_id as ut_owner_id
                            FROM req_ut_access NATURAL JOIN ut_owner NATURAL JOIN ut_registered
                            WHERE ut_registered.ut_id = $user_id";

        $bb_id = pg_fetch_result(pg_query($connection, $qry_bb_id), 0, 'bb_id');
        $new_id = pg_fetch_result(pg_query($connection, $qry_post), 0, 'new_id');
        $ut_owner_id = pg_fetch_result(pg_query($connection, $qry_ut_owner_id), 0, 'ut_owner_id');
        echo "<br>$bb_id, $ut_owner_id, '$title', '$content', '$name_tag', $new_id<br>";
        $qry_post = "INSERT INTO posts(bb_id, ut_owner_id, title, ttext)
                        VALUES ($bb_id, $ut_owner_id, '$title', '$content');
                     INSERT INTO tags_posts(name_tag, post_id)
                        VALUES ('$name_tag', $new_id);";
        $result_post_insert = pg_query($connection, $qry_post);

        // Verifica se l'inserimento è avvenuto con successo
        if ($result_post_insert) {
            echo "Post sent successfully!";
            header("Location: ../../02-home.php");
        } else {
            echo "Post not sent, ERROR: " . pg_result_error($result_post_insert);
        }
    }

    pg_close($connection);
