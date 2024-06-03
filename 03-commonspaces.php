<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="./03-commonspaces/local_css/03-commonspaces.css" />
    <link rel="stylesheet" href="./global/01-css/contatti.css">
    <link rel="stylesheet" href="global/01-css/global.css" />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Lato"
    />
    <link
      href="https://fonts.googleapis.com/css2?family=Rubik:wght@400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <title>Prenota</title>
  </head>
  <body id="body">
    <script src="./03-commonspaces/local_js/03-commonspaces.js"></script>
    <script src="./global/05-js/ajax.js"></script>
    <?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if (!$connection) {
      echo "Errore, connessione non riuscita.<br>";
      exit;
    }

    if (!isset($_SESSION['ut_id'])  && !isset($_SESSION['email'])) {
      header("Location: ./01-login.php");
    }

    $id_utente = $_SESSION["ut_id"];
    $check_admin = pg_num_rows(pg_query($connection, "SELECT ut_id FROM aptblock_admin WHERE ut_id = $id_utente"));
    
    $array = array();
    $luoghi = pg_query($connection, "SELECT * FROM common_spaces");
    $prenotazioni_attive = pg_query($connection, "SELECT rental_req_id, cs_id, rental_datetime_start, rental_datetime_end FROM rental_request WHERE stat = 'accepted'");

    while ($row = pg_fetch_assoc($prenotazioni_attive)) {
      $timestamp_inizio = $row['rental_datetime_start'];
      $timestamp_fine = $row['rental_datetime_end'];
      $data_inizio = new DateTime($timestamp_inizio);
      $data_fine = new DateTime($timestamp_fine);
      $giorno = $data_inizio->format('d/m/Y');
      $ora_inizio = $data_inizio->format('H:i');
      $ora_fine = $data_fine->format('H:i');

      $array[] = [
        'rental_req_id' => $row['rental_req_id'],
        'cs_id' => $row['cs_id'],
        'giorno' => $giorno,
        'ora_inizio' => $ora_inizio,
        'ora_fine' => $ora_fine
      ];
    }

    $prenotazioni = json_encode($array);

    ?>

    <script type="text/javascript">
      var prenotazioni = <?php echo $prenotazioni; ?>;
    </script>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("./global/06-html/navbar.html");
      });
    </script>
    <!--end of Navigation bar-->

    <div class="grid">
      <div class="brown">
        <!--Calendario-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("./global/06-html/calendar-small.html");
          });
        </script>
        <!--Fine calendario-->
        <?php if ($check_admin): ?>
          <div id="richieste-pending"></div>
          <script>
            $(function () {
              $("#richieste-pending").load("./global/06-html/richieste_pending.php");
            });
          </script>
        <?php else: ?>
          <div id="prenotazioni-attive"></div>
          <script>
            $(function () {
              $("#prenotazioni-attive").load("./global/06-html/prenotazioni_attive.php");
            });
          </script>
        <?php endif; ?>
      </div>
      <div class="colonna-centrale">
        <?php
        $prenotazioni_pending = pg_query($connection, "SELECT * FROM ((rental_request JOIN req_ut_access ON ut_owner_id = utreq_id) NATURAL JOIN ut_registered) NATURAL JOIN common_spaces WHERE stat = 'pending' ORDER BY submit_time ASC");
        ?>
        <?php if ($check_admin): ?>
          <div class="prenotazioni-pending" id="prenotazioni-pending">
            <?php while ($row = pg_fetch_assoc($prenotazioni_pending)): ?>
              <?php
              $req_id = $row['rental_req_id'];
              $nome = $row['nome'];
              $cognome = $row['cognome'];
              $img = str_replace("\\", "/", $row['imgs_dir']);
              $img = 'tests/common_spaces_images/' . basename($img);
              $nome_luogo = $row['common_space_name'];
              $timestamp_inizio = $row['rental_datetime_start'];
              $timestamp_fine = $row['rental_datetime_end'];
              $data_inizio = new DateTime($timestamp_inizio);
              $data_fine = new DateTime($timestamp_fine);
              $giorno = $data_inizio->format('d/m/Y');
              $ora_inizio = $data_inizio->format('H:i');
              $ora_fine = $data_fine->format('H:i');
              ?>
              <form id="<?php echo htmlspecialchars($req_id);?>" action="./03-commonspaces/local_php/prenotazione_update.php" method="POST">
                <input type="hidden" name="req_id" value="<?php echo htmlspecialchars($req_id);?>">
                <input type="hidden" id="time-inizio-<?php echo htmlspecialchars($req_id); ?>" value="<?php echo $timestamp_inizio;?>">
                <input type="hidden" id="time-fine-<?php echo htmlspecialchars($req_id); ?>" value="<?php echo $timestamp_fine;?>">
                <div class="luogo-form">
                  <p><?php echo htmlspecialchars($nome_luogo);?></p>
                  <img src="<?php echo htmlspecialchars($img);?>">
                </div>
                <div>
                  <p><?php echo htmlspecialchars($nome);?> <?php echo htmlspecialchars($cognome);?></p>
                  <p><?php echo htmlspecialchars($giorno);?></p>
                  <p><?php echo htmlspecialchars($ora_inizio);?> - <?php echo htmlspecialchars($ora_fine);?></p>
                  <button class="accetta" type="submit" name="stato" value="accepted" onclick="handleRequest(event, 'accepted', './03-commonspaces/local_php/prenotazione_update.php', <?php echo htmlspecialchars($req_id); ?>), removeRefusedForms('<?php echo htmlspecialchars($timestamp_inizio); ?>', '<?php echo htmlspecialchars($timestamp_fine); ?>')">Accetta</button>
                  <button class="rifiuta" type="submit" name="stato" value="refused" onclick="handleRequest(event, 'refused', './03-commonspaces/local_php/prenotazione_update.php', <?php echo htmlspecialchars($req_id); ?>)">Rifiuta</button>
                </div>
              </form>
            <?php endwhile; ?>
          </div>
        <?php else: ?>
          <div class="luoghi">
            <?php while ($row = pg_fetch_assoc($luoghi)): ?>
              <?php
              $name = $row['common_space_name'];
              $img = str_replace("\\", "/", $row['imgs_dir']);
              $img = 'tests/common_spaces_images/' . basename($img);
              $cs_id = $row['cs_id'];
              ?>
              <figure class="luogo">
                <p class="cs-id" style="display: none"><?php echo htmlspecialchars($cs_id); ?></p>
                <p class="nome-luogo"><?php echo htmlspecialchars($name); ?></p>
                <p>
                  <img class="immagine img-luogo" src="<?php echo htmlspecialchars($img); ?>">
                </p>
                <div class="overlay">
                  <button id="prenota" class="bottone" href="#" onclick="popup(this), show('popup'), getDays()">
                    PRENOTA
                  </button>
                </div>
              </figure>
            <?php endwhile; ?>
            <div id="backdrop" class="backdrop"></div>
            <div class="popup" id="popup">
              <div>
                <h3 id="nome-popup" style="font-size: 20px; margin-bottom: 17px"></h3>
                <img id="img-popup" src="" class="immagine">
              </div>

              <form class="popup-form" action="./03-commonspaces/local_php/prenotazione.php" method="POST">
                <input type="hidden" id="cs-id" name="cs_id">
                <div style="text-align: right">
                  <button type="button" class="close" href="#" onclick="hide('popup')"></button>
                </div>
                <div style="text-align: center">
                  <div id="calendar-prenota"></div>
                  <script>
                    $(function () {
                      $("#calendar-prenota").load("./global/06-html/calendar-prenota.html");
                    });
                  </script>
                  <input type="hidden" id="giorno" name="giorno">
                  <input type="hidden" id="mese" name="mese">
                  <input type="hidden" id="anno" name="anno">
                </div>
                <div class="popup-form-bottom">
                  <label
                    for="time_start"
                    style="font-weight: 600; margin-right: 5px"
                    >Dalle:</label
                  >
                  <input
                    id="time_start"
                    name="time_start"
                    type="time"
                    style="margin-right: 10px"
                  />
                  <label for="time_end" style="font-weight: 600; margin-right: 5px"
                    >Alle:</label
                  >
                  <input
                    id="time_end"
                    name="time_end"
                    type="time"
                    style="margin-right: 20px"
                  />
                  <input
                    type="submit"
                    value="Conferma"
                    class="submit"
                    onclick="checkTime(event), checkDay(event)"
                  />
                </div>
              </form>
            </div>
          </div>
        <?php endif; ?>
      </div>
      <div class="brown">
        <div id="contatti"></div>
        <script>
          $(function () {
            $("#contatti").load("./global/06-html/contatti-utili.html");
          });
        </script>
      </div>
    </div>
  </body>
</html>

