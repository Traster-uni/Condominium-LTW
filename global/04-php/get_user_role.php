<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    header('Content-Type: application/json');

    if (!isset($_SESSION['ut_id'])) {
        echo json_encode(['error' => 'User not logged in']);
        http_response_code(401);
        exit();
    }

    $id_utente = $_SESSION['ut_id'];

    $check_admin = pg_num_rows(pg_query($connection, "SELECT ut_id FROM aptblock_admin WHERE ut_id = $id_utente"));

    if ($check_admin) {
        echo json_encode(['role' => 'admin']); 
    } else {
        echo json_encode(['role' => 'user']);
    }
    /* $isAdmin = isset($_SESSION['admin']) ? $_SESSION['admin'] : false;
    echo json_encode(['role' => $isAdmin ? 'admin' : 'user']); */