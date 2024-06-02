<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (isset($_GET['post_id']) && isset($_GET['type'])) {
            $type = $_GET['type'];
            $post_id = $_GET['post_id'];

            if ($type === 'admin'){
                $query = "SELECT post_thread_admin.*, ut_registered.nome, ut_registered.cognome 
                            FROM post_thread_admin
                            JOIN ut_registered ON post_thread_admin.ut_id = ut_registered.ut_id
                            WHERE post_admin_id = $post_id
                            ORDER BY time_born DESC";

            } else if ($type === 'general'){
                $query = "SELECT post_thread.*, ut_registered.nome, ut_registered.cognome 
                            FROM post_thread
                            JOIN ut_registered ON post_thread.ut_id = ut_registered.ut_id
                            WHERE post_id = $post_id
                            ORDER BY time_born DESC";
            }
           
            $result = pg_query($connection, $query);

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