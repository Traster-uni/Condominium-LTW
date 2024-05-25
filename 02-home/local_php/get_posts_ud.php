<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
    // $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }
    //session_start();
    
    //$aptBlock_id = $_SESSION['aptBlock']; // Recupero l'apt id dalla sessione
    $aptblock_id = 1;

    $query = "SELECT 
                    posts.post_id, 
                    posts.ut_owner_id, 
                    utreg.nome AS nome, 
                    utreg.cognome AS cognome, 
                    posts.title, 
                    posts.ttext, 
                    posts.time_born, 
                    posts.time_mod, 
                    posts.off_comments
                FROM 
                    aptblock aptb 
                JOIN 
                    aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
                JOIN 
                    posts ON posts.bb_id = aptb_bb.bb_id
                JOIN 
                    ut_registered utreg ON posts.ut_owner_id = utreg.ut_id
                WHERE 
                    $aptblock_id = aptb.aptblock_id
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