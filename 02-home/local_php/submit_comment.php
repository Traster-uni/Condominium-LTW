<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    //session_start();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $user_id = $_SESSION['ut_id'];
        $data = json_decode(file_get_contents('php://input'), true);
        $thread_id = $data['thread_id'];
        $comm_text = $data['content'];
        
        $query = "INSERT INTO thread_comments (thread_id, comm_text, ut_id, time_born) 
                    VALUES ($1, $2, $3, NOW())";
        $result = pg_query_params($connection, $query, array($thread_id, $comm_text, $user_id));

        if ($result) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => 'error']);
        }

        pg_close($connection);
    }