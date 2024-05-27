<?php
session_start();
$connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");
/* $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=".$_SESSION['email']." password=".$_SESSION['password']); */
if (!$connection) {
    echo "Errore, connessione non riuscita.<br>";
    exit;
}

$id_utente = $_SESSION['ut_id'];
$result = pg_query($connection, "SELECT * FROM rental_request NATURAL JOIN common_spaces WHERE ut_id = $id_utente ORDER BY rental_datetime_start ASC ");

?>

<div style="background: white; padding: 0px 0px 5px 10px; border-top: 1px solid gray">
    <p style="font-weight: bold; font-size: 20px">Prenotazioni attive</p>
    <?php while ($row = pg_fetch_assoc($result)): ?>
        <?php
        $name = $row['common_space_name'];
        $timestamp_inizio = $row['rental_datetime_start'];
        $timestamp_fine = $row['rental_datetime_end'];
        $data_inizio = new DateTime($timestamp_inizio);
        $data_fine = new DateTime($timestamp_fine);
        $giorno = $data_inizio->format('d/m/Y');
        $ora_inizio = $data_inizio->format('H:i');
        $ora_fine = $data_fine->format('H:i');
        ?>
        <p><?php echo htmlspecialchars($name); ?> (<?php echo htmlspecialchars($giorno); ?>, <?php echo htmlspecialchars($ora_inizio); ?> - <?php echo htmlspecialchars($ora_fine); ?>)</p>
    <?php endwhile; ?>
</div>