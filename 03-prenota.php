<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="./03-prenota/local_css/03-prenota.css" />
    <link rel="stylesheet" href="global/01-css/contatti.css">
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <title>Prenota</title>
  </head>
  <body id="body">
    <?php

    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");
    /* $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=".$_SESSION['email']." password=".$_SESSION['password']); */
    if (!$connection) {
      echo "Errore, connessione non riuscita.<br>";
      exit;
    }

    /* session_start();

    if (!isset($_SESSION['ut_id'])) {
      header('01-login.html');
      exit();
    } */

    $result = pg_query($connection, "SELECT * FROM common_spaces");

    ?>
    
    <script src="./03-prenota/local_js/03-prenota.js"></script>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("global/06-html/navbar.html");
      });
    </script>
    <!--end of Navigation bar-->

    <div class="flexbox">
      <div style="background-color: rgb(101, 189, 113); width: 20%">
        <!--Calendario-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("global/06-html/calendar-small.html");
          });
        </script>
        <!--Fine calendario-->
        <!--Prenotazioni attive-->
        <div id="prenotazioni"></div>
        <script>
          $(function () {
            $("#prenotazioni").load("global/06-html/prenotazioni.php");
          });
        </script>
        <!-- Fine prenotazioni -->
      </div>
      <div class="colonna-centrale">
        <div class="luoghi">
          <?php while ($row = pg_fetch_assoc($result)): ?>
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

            <form class="popup-form" action="./03-prenota/local_php/prenotazione.php" method="POST">
              <input type="hidden" id="cs-id" name="cs_id">
              <div style="text-align: right">
                <button type="button" class="close" href="#" onclick="hide('popup')"></button>
              </div>
              <div style="text-align: center">
                <div id="calendar1"></div>
                <script>
                  $(function () {
                    $("#calendar1").load("global/06-html/calendar-prenota.html");
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
                  onclick="checkTime(event)"
                />
              </div>
            </form>
          </div>
        </div>
      </div>
      <div style="background-color: rgb(101, 189, 113); width: 20%">
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

