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

    $query = "SELECT aptb.aptblock_id, aptb_bb.bb_id, aptb_bb.bb_name, pt.post_id, pt.ut_owner_id ut_id, 
                ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_mod, pt.off_comments
                FROM aptblock aptb 
                JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
                JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
                JOIN ut_registered ut_r ON ut_r.ut_id = pt.ut_owner_id
                WHERE aptb.aptblock_id = $aptblock_id
                ORDER BY time_born DESC";

    $result = pg_query($connection, $query);

    $posts = [];
    while ($line = pg_fetch_assoc($result)) {
        $posts[] = $line;
    }

    header('Content-Type: application/json');
    echo json_encode($posts);

    pg_free_result($result);
    pg_close($connection);