<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="stylesheet" href="./global/01-css/richieste.css" />
    </head>
    <body>
        <script src="./global/05-js/ajax.js"></script>
        <?php
        session_start();
        $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");
        /* $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=".$_SESSION['email']." password=".$_SESSION['password']); */
        if (!$connection) {
            echo "Errore, connessione non riuscita.<br>";
            exit;
        }

        $id_admin = $_SESSION['ut_id'];
        $r = pg_query($connection, "SELECT aptblockreq_id FROM req_aptblock_create WHERE ut_id = $id_admin");
        $aptblock_id = pg_fetch_result($r, 0, 0);
        $result = pg_query($connection, "SELECT nome, cognome, time_born, utreq_id FROM req_ut_access NATURAL JOIN ut_registered WHERE aptblock_id = $aptblock_id AND status = 'pending' ORDER BY time_born ASC ");

        ?>

        <div class="richieste">
            <p style="font-weight: bold; font-size: 20px; text-align: center;">Richieste di accesso</p>
            <?php while ($row = pg_fetch_assoc($result)): ?>
                <?php
                $req_id = $row['utreq_id'];
                $nome = $row['nome'];
                $cognome = $row['cognome'];
                $timestamp = $row['time_born'];
                $data = new DateTime($timestamp);
                $data = $data->format('d/m/Y');
                ?>
                <form id="<?php echo htmlspecialchars($req_id); ?>" action="./global/04-php/request_update.php" method="POST">
                    <p><?php echo htmlspecialchars($nome);?> <?php echo htmlspecialchars($cognome);?> (<?php echo htmlspecialchars($data);?>)</p>
                    <input type="hidden" name="req_id" value="<?php echo htmlspecialchars($req_id); ?>">
                    <div>
                        <button class="accetta" type="submit" name="stato" value="accepted" onclick="handleRequest(event, 'accepted', <?php echo htmlspecialchars($req_id); ?>)">Accetta</button>
                        <button class="rifiuta" type="submit" name="stato" value="refused" onclick="handleRequest(event, 'refused', <?php echo htmlspecialchars($req_id); ?>)">Rifiuta</button>
                    </div>
                </form>
            <?php endwhile; ?>
        </div>
    </body>