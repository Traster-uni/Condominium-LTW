<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="./03-commonspaces/local_css/03-commonspaces.css" />
    <link rel="stylesheet" href="./global/01-css/contatti.css">
    <link rel="stylesheet" href="./global/01-css/fonts.css">
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Lato"
    />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Montserrat"
    />
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <title>Prenota</title>
  </head>
  <body id="body">
    <script src="./03-commonspaces/local_js/03-commonspaces.js"></script>
    <?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if (!$connection) {
      echo "Errore, connessione non riuscita.<br>";
      exit;
    }

    if (!isset($_SESSION['ut_id'])  && !isset($_SESSION['email'])) {
      // $id_utente = $_SESSION["ut_id"];
      //   $check_registered = pg_query($connection, "SELECT utreq_id FROM ut_owner WHERE utreq_id = $id_utente");
      //   if (!pg_num_rows($check_registered)) {
      //     header('01-login2.html');
      //   } else {
      //     header('01-login1.html');
      //   }
      header("Location: ../../01-login.php");
    }

    $id_utente = $_SESSION["ut_id"];
    $check_admin = pg_num_rows(pg_query($connection, "SELECT ut_id FROM aptblock_admin WHERE ut_id = $id_utente"));
    
    $array = array();
    $result1 = pg_query($connection, "SELECT * FROM common_spaces");
    $result2 = pg_query($connection, "SELECT rental_req_id, cs_id, rental_datetime_start, rental_datetime_end FROM rental_request");

    while ($row = pg_fetch_assoc($result2)) {
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
      <div style="background-color: rgb(101, 189, 113)">
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
        <div class="luoghi">
          <?php while ($row = pg_fetch_assoc($result1)): ?>
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
      </div>
      <div style="background-color: rgb(101, 189, 113)">
        <div class="contatti-utili">
          <ul>
            <li class="contatti-utili__nome">Nome - Amministratore Cellulare</li>
            <li class="contatti-utili__nome">Nome - Elettricista Cellulare</li>
            <li class="contatti-utili__nome">Nome - Fabbro Cellulare</li>
            <li class="contatti-utili__nome">Nome - Idraulico Cellulare</li>
          </ul>
        </div>
      </div>
    </div>
  </body>
</html>

