<?php
session_start();
$connect = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
if (!$connect) {
  echo "Errore, connessione non riuscita.<br>";
  exit();
}

// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

$id_utente = $_SESSION["ut_id"];

$qry_aptb = "SELECT aptb.aptblock_id as id, addr_aptb, city, cap, time_born as data_richiesta, time_mod as data_verifica
            FROM ut_registered ut_r 
            JOIN req_ut_access rutc ON ut_r.ut_id = rutc.ut_id
            JOIN aptblock aptb ON rutc.aptblock_id = aptb.aptblock_id
            WHERE ut_r.ut_id = $id_utente
            ORDER BY (time_mod) ASC";
$qry_aptb_res = pg_query($connect, $qry_aptb);
if (!$qry_aptb_res){ // error checking
    echo "57: Something went wrong<br>";
    echo pg_result_error($qry_aptb_res);
}
?>

<div style="background: white; padding: 0px 0px 5px 10px; border-top: 1px solid gray">
    <p style="font-weight: bold; font-size: 20px">Storico Condomini</p>
    <?php while ($row = pg_fetch_assoc($qry_aptb_res)): ?>
        <?php
        $id = $row['id'];
        $addr = $row['addr_aptb'];
        $city = $row['city'];
        $cap = $row['cap'];
        $timestamp_b = new DateTime($row['data_richiesta']);
        $timestamp_m = new DateTime($row['data_verifica']);
        $d_b = $timestamp_b->format('d/m/Y');
        $d_m = $timestamp_m->format('d/m/Y');
        ?>
        <p><pre class="tab2">  <?php echo htmlspecialchars($id); ?> - <?php echo htmlspecialchars($addr); ?> in <?php echo htmlspecialchars($city); ?> <?php echo htmlspecialchars($cap); ?> ( Ingresso richiesto: <?php echo htmlspecialchars($d_b); ?> | Accettato: <?php echo htmlspecialchars($d_m); ?> )</pre></span></p>
    <?php endwhile; ?>