<?php
session_start();
$connect = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
if (!$connect) {
  echo "Errore, connessione non riuscita.<br>";
  exit();
}

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$id_utente = $_SESSION["ut_id"];

$qry_pdata = "SELECT ut_r.*, req_a.aptblock_id, ut_o.utreq_id as ut_owner_id
              FROM ut_registered ut_r 
              JOIN req_ut_access req_a ON ut_r.ut_id = req_a.ut_id
              JOIN ut_owner ut_o ON ut_o.utreq_id = req_a.utreq_id
              WHERE ut_r.ut_id = $id_utente;";
$qry_pdata_res = pg_query($connect, $qry_pdata);
if (!$qry_pdata_res){ // error checking
  echo "42: Something went wrong<br>";
  echo pg_result_error($qry_pdata_res);
}
?>

<div style="background: white; padding: 0px 0px 5px 10px; border-top: 1px solid gray">
    <p style="font-weight: bold; font-size: 20px">Storico Condomini</p>
    <?php while ($row = pg_fetch_assoc($qry_pdata_res)): ?>
        <?php
        $n_m = $row['nome'] . " " . $row['cognome'];
        $dnascita = $row['d_nascita'];
        $tel = $row['telefono'];
        $discrizione = new DateTime($row['data_iscrizione']);
        $email = $row['ut_email'];
        $d = $discrizione->format('d/m/Y');
        ?>
        <p><pre class="tab2">      <?php echo htmlspecialchars($n_m); ?> - <?php echo htmlspecialchars($dnascita); ?>    telefono: <?php echo htmlspecialchars($tel); ?>    indirizzo email:<?php echo htmlspecialchars($email); ?> ( data iscrizione: <?php echo htmlspecialchars($d); ?> )</pre></span></p>
    <?php endwhile; ?>