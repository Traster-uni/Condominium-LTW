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
  <body>
    <?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=postgres password=service");
    /* $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=".$_SESSION['email']." password=".$_SESSION['password']); */
    if (!$connection) {
      echo "Errore, connessione non riuscita.<br>";
      exit;
    }

    session_start();

    if (!isset($_SESSION['ut_id'])) {
      header('01-login.html');
      exit();
    }

    $result = pg_query($connection, "SELECT * FROM common_spaces");
    $common_space_name = pg_fetch_all_columns($result, 1);
    $aptblock_imgs_dir = pg_fetch_all_columns($result, 4);
    ?>
    
    <script src="./03-prenota/local_js/03-prenota.js"></script>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("navbar.html");
      });
    </script>
    <!--end of Navigation bar-->

    <div class="flexbox">
      <div style="background-color: rgb(101, 189, 113); width: 20%">
        <!--Calendar-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("calendar-small.html");
          });
        </script>
        <!--End of calendar-->
      </div>
      <div class="colonna-centrale">
        <div class="luoghi">
          <figure class="luogo">
            <?php
            echo "$common_space_name[0]"
            ?>
            <img src="03-prenota/images/1.jpg" class="immagine" />
            <div class="overlay">
              <button class="bottone" href="#" onclick="show('popup1'), getDays()">
                PRENOTA
              </button>
            </div>
          </figure>
          <figure class="luogo">
            <?php
            echo "$common_space_name[1]"
            ?>
            <img src="03-prenota/images/2.jpg" class="immagine" />
            <div class="overlay">
              <button class="bottone" href="#" onclick="show('popup2')">
                PRENOTA
              </button>
            </div>
          </figure>
          <figure class="luogo">
            <?php
            echo "$common_space_name[2]"
            ?>
            <img src="03-prenota/images/3.jpg" class="immagine" />
            <div class="overlay">
              <button class="bottone" href="#" onclick="show('popup3')">
                PRENOTA
              </button>
            </div>
          </figure>
          <td></td>
        </div>
        <div class="popup" id="popup1">
          <div>
            <h3 style="font-size: 20px">Luogo 1</h3>
            <img src="03-prenota/images/1.jpg" class="immagine" />
          </div>
          
          <form class="popup-form" action="./03-prenota/local_php/prenotazione.php" method="POST">
            <div style="text-align: right">
              <button type="button" class="close" href="#" onclick="hide('popup1')"></button>
            </div>
            <div style="text-align: center">
              <div id="calendar1"></div>
              <script>
                $(function () {
                  $("#calendar1").load("calendar-prenota.html");
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
        <div class="popup" id="popup2">
          <div>
            <img src="03-prenota/images/2.jpg" class="immagine" />
          </div>
          <div class="popup-form">
            <button href="#" onclick="hide('popup2')">X</button>
          </div>
        </div>
        <div class="popup" id="popup3">
          <div>
            <img src="03-prenota/images/3.webp" class="immagine" />
          </div>
          <div class="popup-form">
            <button href="#" onclick="hide('popup3')">X</button>
          </div>
        </div>
        <div class="popup" id="popup4">
          <div>
            <img src="03-prenota/images/4.jpg" class="immagine" />
          </div>
          <div class="popup-form">
            <button href="#" onclick="hide('popup4')">X</button>
          </div>
        </div>
        <div class="popup" id="popup5">
          <div>
            <img src="03-prenota/images/5.jpg" class="immagine" />
          </div>
          <div class="popup-form">
            <button href="#" onclick="hide('popup5')">X</button>
          </div>
        </div>
        <div class="popup" id="popup6">
          <div>
            <img src="03-prenota/images/6.webp" class="immagine" />
          </div>
          <div class="popup-form">
            <button href="#" onclick="hide('popup6')">X</button>
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

