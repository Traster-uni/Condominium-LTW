<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $user_id = 2;
        //$user_id = $_SESSION['user_id'];
        $data = json_decode(file_get_contents('php://input'), true);
        $post_id = $data['post_id'];
        $comm_text = $data['content'];

        $query = "INSERT INTO post_thread (post_id, comm_text, ud_id, time_born, time_lastreplay) 
                    VALUES ($1, $2, $3, NOW(), NOW())";
        $result = pg_query_params($connection, $query, array($post_id, $comm_text, $user_id));

        if ($result) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => 'error']);
        }

        pg_close($connection);
    }