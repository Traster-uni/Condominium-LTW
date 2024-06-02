<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $user_id = $_SESSION['ut_id'];
        $data = json_decode(file_get_contents('php://input'), true);
        $post_id = $data['postId'];
        $comm_text = $data['content'];
        $type = $data['type'];
        
        if ($type === 'general'){
            $query = "INSERT INTO post_thread (post_id, ut_id, comm_text, time_lastreplay) 
                        VALUES ($post_id, $user_id, $comm_text,  NOW())";
        } else if ($type === 'admin'){
            $query = "INSERT INTO post_thread_admin (post_admin_id, ut_id, comm_text,  time_lastreplay) 
                        VALUES ($post_id, $user_id, $comm_text,  NOW())";
        }
        
        $result = pg_query($connection, $query);

        if ($result) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => 'error']);
        }

        pg_close($connection);
    }