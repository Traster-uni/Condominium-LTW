<?php
    session_start();
    
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        pg_close($connection);
        exit;
    } else {
        echo "connected<br>";
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_SESSION['admin'])) {

            $aptblock_id = $_SESSION['aptblock_id'];
            $user_id = $_SESSION['ut_id'];

            $title = htmlspecialchars($_POST["admin-post-title"]);
            $content = htmlspecialchars($_POST["admin-post-content"]);
            $name_tag = htmlspecialchars($_POST["tags"]);
            $time_event = new DateTime(htmlspecialchars($_POST["event-datetime"]));
            $time_event_f = $time_event->format('Y-m-d H:i:s');
            
            
            $qry_post_id = "SELECT last_value+1 AS new_id FROM posts_admin_post_id_seq";
            $qry_bb_id = "SELECT bb_id 
                            FROM aptblock_bulletinboard 
                            WHERE aptblock_id = $aptblock_id AND bb_name = 'admin'";
            $qry_aptblockreq_id = "SELECT rac.aptblockreq_id
                            FROM ut_registered NATURAL JOIN req_aptblock_create rac NATURAL JOIN aptblock_admin
                            WHERE ut_registered.ut_id = $user_id";
            
            $bb_id = pg_fetch_result(pg_query($connection, $qry_bb_id), 0, 'bb_id');
            $aptblockreq_id = pg_fetch_result(pg_query($connection, $qry_aptblockreq_id), 0, 'aptblockreq_id');
            $new_id = pg_fetch_result(pg_query($connection, $qry_post_id), 0, 'new_id');
            echo "($bb_id, $user_id, '$title', '$content', $time_event_f)<br>";

            if ($name_tag === 'Evento' || $name_tag === 'Riunione' || $name_tag === 'Avvertenze') {
                $qry_post = "INSERT INTO posts_admin(bb_id, aptblockreq_id, title, ttext, time_event)
                                VALUES ($bb_id, $aptblockreq_id, '$title', '$content', '$time_event_f');
                            INSERT INTO tags_posts_admin(name_tag, post_admin_id)
                                VALUES ('$name_tag', $new_id);";
            } else {
                $qry_post = "INSERT INTO posts_admin(bb_id, aptblockreq_id, title, ttext, time_event)
                                VALUES ($bb_id, $aptblockreq_id, '$title', '$content', NULL);
                            INSERT INTO tags_posts_admin(name_tag, post_admin_id)
                                VALUES ('$name_tag', $new_id);";
            }
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