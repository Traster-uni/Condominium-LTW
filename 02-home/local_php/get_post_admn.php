<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    $aptBlock_id = $_SESSION['aptblock_id']; // Recupero l'apt id dalla sessione


    $query = "SELECT sub2.aptblock_id, 
                sub2.admin_id, 
                ut_reg.nome, 
                ut_reg.cognome, 
                sub2.bb_id, 
                sub2.bb_name, 
                sub2.bb_year, 
                pt_a.post_id
                FROM (
                    SELECT sub1.aptblock_id, 
                    sub1.admin_id, 
                    aptb_bb.bb_id, 
                    aptb_bb.bb_name, 
                    aptb_bb.bb_year
                    FROM (
                        SELECT aptb.aptblock_id, aptb_adm.ut_id AS admin_id
                        FROM aptblock aptb 
                        JOIN req_aptblock_create r_aptb_c ON aptb.aptblock_id = r_aptb_c.aptblockreq_id
                        JOIN aptblock_admin aptb_adm ON r_aptb_c.ut_id = aptb_adm.ut_id
                        WHERE r_aptb_c.stat = 'accepted'
                    ) AS sub1
                    JOIN aptblock_bulletinboard aptb_bb ON aptb_bb.aptblock_id = sub1.aptblock_id
                ) AS sub2
                JOIN posts_admin pt_a ON pt_a.bb_id = sub2.bb_id
                JOIN ut_registered ut_reg ON ut_reg.ut_id = sub2.admin_id
                WHERE sub2.admin_id = pt_a.aptblockreq_id;";

    $result = pg_query($connection, $query);

    $posts = [];
    while ($line = pg_fetch_assoc($result)) {
        $posts[] = $line;
    }

    header('Content-Type: application/json');
    echo json_encode($posts);

    pg_free_result($result);
    pg_close($connection);