<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }
    
    $aptBlock_id = $_SESSION['aptblock_id']; // Recupero l'apt id dalla sessione

    $query = "SELECT 
                    posts.post_id, 
                    ut_r.ut_id, 
                    ut_r.nome AS nome, 
                    ut_r.cognome AS cognome, 
                    posts.title, 
                    posts.ttext, 
                    posts.time_born, 
                    posts.time_mod, 
                    posts.off_comments
                FROM aptblock aptb 
                    JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
                    JOIN posts ON posts.bb_id = aptb_bb.bb_id
                    JOIN ut_owner ut_o ON ut_o.utreq_id = posts.ut_owner_id
                    JOIN req_ut_access req_id ON req_id.utreq_id = ut_o.utreq_id
                    JOIN ut_registered ut_r ON req_id.ut_id = ut_r.ut_id
                WHERE 
                    aptb.aptblock_id = $aptBlock_id
                ORDER BY 
                    posts.time_born DESC";

    $result = pg_query($connection, $query);

    $posts = [];
    while ($line = pg_fetch_assoc($result)) {
        $posts[] = $line;
    }

    header('Content-Type: application/json');
    echo json_encode($posts);

    pg_free_result($result);
    pg_close($connection);