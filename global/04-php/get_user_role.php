<?php
    session_start();

    header('Content-Type: application/json');

    if (!isset($_SESSION['ut_id'])) {
        echo json_encode(['error' => 'User not logged in']);
        http_response_code(401);
        exit();
    }

    $isAdmin = isset($_SESSION['admin']) ? $_SESSION['admin'] : false;
    echo json_encode(['role' => $isAdmin ? 'admin' : 'user']);