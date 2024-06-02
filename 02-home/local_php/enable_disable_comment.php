<?php 
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    $post_id = $_GET['post_id'];
    $post_type = $_GET['type'];
    $action = $_GET['action']; // 'disable' or 'enable

    if($action === 'disable') {
        if ($post_type === 'general'){
            $query = "UPDATE posts SET off_comments = 't' WHERE post_id = $1";
        } else if ($post_typepe === 'admin'){
            $query = "UPDATE posts_admin SET off_comments = 't' WHERE post_admin_id = $1";
        }

    } else if ($action === 'enable') {
        if ($post_type === 'general') {
            $query = "UPDATE posts SET off_comments = 'f' WHERE post_id = $1";
        } else if ($post_type === 'admin'){
            $query = "UPDATE posts_admin SET off_comments = 'f' WHERE post_admin_id = $1";
        }

    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
        exit;
    }

    $result = pg_query_params($connection, $query, array($post_id));

    if ($result) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Query failed']);
    }

    pg_free_result($result);
    pg_close($connection);
