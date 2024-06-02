<?php
session_start();

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL); 

$connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");


if (!$connection) {
    echo "Errore, connessione non riuscita.<br>";
    pg_close($connection);
    exit;
}


$aptblock_id = $_SESSION['aptblock_id']; // Recupero l'apt id dalla sessione

$query = "SELECT 
            allposts.aptblock_id, 
            allposts.post_id,
            allposts.bb_name,
            allposts.nome, 
            allposts.cognome,
            allposts.title, 
            allposts.ttext, 
            allposts.time_born, 
            allposts.time_mod, 
            allposts.time_event,
            allposts.off_comments,
            allposts.name_tag
        FROM (
            SELECT DISTINCT
                    aptb.aptblock_id,
                    pt.post_id,
                    aptb_bb.bb_name,
                    ut_r.nome, 
                    ut_r.cognome,
                    pt.title, 
                    pt.ttext, 
                    pt.time_born, 
                    pt.time_mod, 
                    pt.time_event,
                    pt.off_comments,
                    tp.name_tag
                FROM aptblock aptb 
                JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
                JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
                JOIN ut_owner ut_o ON ut_o.utreq_id = pt.ut_owner_id
                JOIN req_ut_access req_id ON req_id.utreq_id = ut_o.utreq_id
                JOIN ut_registered ut_r ON req_id.ut_id = ut_r.ut_id
                LEFT JOIN tags_posts tp ON tp.post_id = pt.post_id
                LEFT JOIN tags t ON tp.name_tag = tp.name_tag
            UNION
            SELECT DISTINCT
                    aptb.aptblock_id,
                    --aptb_adm.ut_id as admin_id,
                    pt_a.post_id,
                    aptb_bb.bb_name,
                    ut_r.nome, 
                    ut_r.cognome,
                    pt_a.title, 
                    pt_a.ttext, 
                    pt_a.time_born, 
                    pt_a.time_mod, 
                    pt_a.time_event,
                    pt_a.off_comments,
                    tp.name_tag
                FROM aptblock aptb 
                JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
                JOIN posts_admin pt_a ON pt_a.bb_id = aptb_bb.bb_id
                JOIN req_aptblock_create r_aptb_c ON aptb.aptblock_id = r_aptb_c.aptblockreq_id
                JOIN aptblock_admin aptb_adm ON r_aptb_c.ut_id = aptb_adm.ut_id
                JOIN ut_registered ut_r ON r_aptb_c.ut_id = ut_r.ut_id
                JOIN tags_posts_admin tp ON tp.post_admin_id = pt_a.post_id
                LEFT JOIN tags t ON tp.name_tag = tp.name_tag
                WHERE r_aptb_c.stat = 'accepted'
            ) as allposts
            WHERE allposts.aptblock_id = $aptblock_id
        ORDER BY (allposts.time_born) DESC";

$result = pg_query($connection, $query);

$posts = [];
while ($line = pg_fetch_assoc($result)) {
    $posts[] = $line;
}

header('Content-Type: application/json');
echo json_encode($posts);

pg_free_result($result);
pg_close($connection);