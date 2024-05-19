<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    session_start();
    
    $aptblock_id = $_SESSION['aptblock_id']; // Recupero l'apt id dalla sessione

    $query = "SELECT * FROM posts"; //DA FINIRE, recupera i posts relativi al condominio
    $result = pg_query_params($connection, $query, array($aptblock_id));

    $posts = [];
    while ($line = pg_fetch_assoc($result)) {
        $posts[] = $line;
    }

    header('Content-Type: application/json');
    echo json_encode($posts);

    pg_free_result($result);
    pg_close($connection);