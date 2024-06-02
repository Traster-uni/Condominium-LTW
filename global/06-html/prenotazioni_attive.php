<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="stylesheet" href="./global/01-css/prenotazioni.css" />
    </head>
    <body>
        <?php
        session_start();
        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");
        /* $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=".$_SESSION['email']." password=".$_SESSION['password']); */
        if (!$connection) {
            echo "Errore, connessione non riuscita.<br>";
            exit;
        }

        $id_utente = $_SESSION['ut_id'];
        $result = pg_query($connection, "SELECT * FROM (rental_request JOIN req_ut_access ON ut_owner_id = utreq_id) NATURAL JOIN common_spaces WHERE ut_id = $id_utente AND stat = 'accepted' ORDER BY rental_datetime_start ASC");

        ?>

        <div class="prenotazioni">
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
                <li><?php echo htmlspecialchars($name); ?> (<?php echo htmlspecialchars($giorno); ?>, <?php echo htmlspecialchars($ora_inizio); ?> - <?php echo htmlspecialchars($ora_fine); ?>)</li>
            <?php endwhile; ?>
        </div>
    </body>
</html>