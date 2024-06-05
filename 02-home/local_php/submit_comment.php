<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $user_id = $_SESSION['ut_id'];
        // Ottieni il contenuto grezzo della richiesta POST
        $requestBody = file_get_contents('php://input');

        // Decodifica il contenuto della richiesta JSON
        $data = json_decode($requestBody, true);

        if (isset($data['threadId']) && isset($data['content']) && isset($data['type'])) {
            $thread_id = $data['threadId'];
            $content = $data['content'];
            $type = $data['type'];
        
        if ($type === "admin") {
            $query = "INSERT INTO thread_admin_comments (thread_id, comm_text, ut_id, time_born) 
                        VALUES ('$thread_id', '$content', '$user_id', NOW())";
        } else if ($type === "general"){
            $query = "INSERT INTO thread_comments (thread_id, comm_text, ut_id, time_born) 
                        VALUES ('$thread_id', '$content', '$user_id', NOW())";
        }
        $result = pg_query($connection, $query);

        if ($result) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => $_SESSION['ut_id']]);
        }

        pg_close($connection);
        }
    }