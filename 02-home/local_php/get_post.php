<?php
session_start();

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");
$connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");



if (!$connection) {
    echo "Errore, connessione non riuscita.<br>";
    pg_close($connection);
    exit;
}


// $aptBlock_id = $_SESSION['aptBlock']; // Recupero l'apt id dalla sessione
$aptblock_id = 1;

$query = "SELECT DISTINCT aptb.aptblock_id, aptb_bb.bb_id, aptb_bb.bb_name, pt.post_id, pt.ut_owner_id ut_id, 
            ut_r.nome, ut_r.cognome, pt.title, pt.ttext, pt.time_born, pt.time_mod, pt.time_event, pt.off_comments,
            tp.name_tag
            FROM aptblock aptb 
            JOIN aptblock_bulletinboard aptb_bb ON aptb.aptblock_id = aptb_bb.aptblock_id
            JOIN posts pt ON pt.bb_id = aptb_bb.bb_id
            LEFT JOIN ut_registered ut_r ON ut_r.ut_id = pt.ut_owner_id
            LEFT JOIN tags_posts tp ON tp.post_id = pt.post_id
            LEFT JOIN tags t ON tp.name_tag = tp.name_tag
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