<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=$_SESSION["email"] password=$_SESSION["password"]");

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (isset($_GET['post_id'])) {
            $post_id = $_GET['post_id'];
            $query = "SELECT post_thread.*, ut_registered.nome, ut_registered.cognome 
                        FROM post_thread
                        JOIN ut_registered ON post_thread.ud_id = ut_registered.ut_id
                        WHERE post_id = $post_id
                        ORDER BY time_born DESC";
            $result = pg_query_params($connection, $query, array($post_id));

        } elseif (isset($_GET['thread_id'])) {
            $thread_id = $_GET['thread_id'];
            $query = "SELECT thread_comments.*, ut_registered.nome, ut_registered.cognome 
                        FROM thread_comments
                        JOIN ut_registered ON thread_comments.ut_id = ut_registered.ut_id
                        WHERE thread_id = $post_id
                        ORDER BY time_born ASC";
            $result = pg_query_params($connection, $query, array($thread_id));

        } else {
            die('Invalid request');
        }
    
        $comments = array();
        while ($row = pg_fetch_assoc($result)) {
            $comments[] = $row;
        }
    
        header('Content-Type: application/json');
        echo json_encode($comments);
    
        pg_free_result($result);
        pg_close($connection);
    }