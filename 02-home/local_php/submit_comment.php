<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    //session_start();

    $user_id = 2;
    //$user_id = $_SESSION['user_id'];
    $data = json_decode(file_get_contents('php://input'), true);
    $post_id = $data['post_id'];
    $comm_text = $data['content'];
    $parent_id = isset($data['parent_id']) ? $data['parent_id'] : null;

    // Inserisci il nuovo commento nella tabella 'post_thread'
    if ($parent_id != null) {
        $insert_query = "INSERT INTO post_thread (ud_id, post_id, parent_id, comm_text, time_born, time_lastreplay) VALUES ('$user_id', '$post_id', '$parent_id', '$comm_text', NOW(), NOW()) RETURNING *";
    } else {
        $insert_query = "INSERT INTO post_thread (ud_id, post_id, comm_text, time_born, time_lastreplay) VALUES ('$user_id', '$post_id', '$comm_text', NOW(), NOW()) RETURNING *";
    }
    
    $insert_result = pg_query($connection, $insert_query) or die('Insert query failed: ' . pg_last_error());

    $comment = pg_fetch_assoc($insert_result);

    header('Content-Type: application/json');
    echo json_encode($comment);

    pg_free_result($insert_result);
    pg_close($connection);