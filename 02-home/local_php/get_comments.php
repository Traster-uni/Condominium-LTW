<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=$_SESSION["email"] password=$_SESSION["password"]");

    if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['post_id'])) {
        $post_id = $_GET['post_id'];
    
        // Query per ottenere i commenti principali associati al post_id
        $comments_query = "SELECT * FROM post_thread WHERE post_id = $post_id AND parent_id IS NULL ORDER BY time_born DESC";
        $comments_result = pg_query($connection, $comments_query) or die('Query failed: ' . pg_last_error());
    
        $comments = array();
        while ($row = pg_fetch_assoc($comments_result)) {
            // Aggiungi le risposte ai commenti principali
            $responses_query = "SELECT * FROM post_thread WHERE parent_id = $post_id ORDER BY time_born ASC";
            $responses_result = pg_query($connection, $responses_query) or die('Query failed: ' . pg_last_error());
    
            $responses = array();
            while ($response = pg_fetch_assoc($responses_result)) {
                $responses[] = $response;
            }
    
            $row['responses'] = $responses;
            $comments[] = $row;
    
            pg_free_result($responses_result);
        }
    
        header('Content-Type: application/json');
        echo json_encode($comments);
    
        pg_free_result($comments_result);
        pg_close($connection);
    }