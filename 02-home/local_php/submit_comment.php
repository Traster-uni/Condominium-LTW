<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    //session_start();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        print_r($_SERVER['REQUEST_METHOD']);
        $user_id = $_SESSION['ut_id'];
        $data = json_decode(file_get_contents('php://input'), true);
        echo "$data";
        $post_id = $data['post_id'];
        $comm_text = $data['content'];
        $type = $data['type'];
        
        if ($type === "admin") {
            $query = "INSERT INTO thread_admin_comments (post_admin_id, comm_text, ut_id, time_born) 
                        VALUES ($post_id, $comm_text, $user_id, NOW())";
        } else if ($type === "general"){
            $query = "INSERT INTO thread_comments (post_id, comm_text, ut_id, time_born) 
                        VALUES ($post_id, $comm_text, $user_id, NOW())";
        }
        $result = pg_query($connection, $query);

        if ($result) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => $_SESSION['ut_id']]);
        }

        pg_close($connection);
    }