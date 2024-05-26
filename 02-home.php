<?php
  session_start();
?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <link rel="stylesheet" href="./02-home/local_css/02-home.css" />
    <link rel="stylesheet" href="./global/01-css/contatti.css">
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
  </head>
  <body>
    <?php

      // ini_set('display_errors', 1);
      // ini_set('display_startup_errors', 1);
      // error_reporting(E_ALL);
      
      $connect = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
      if (!$connect) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
      }

      if (!isset($_SESSION['ut_id'])  && !isset($_SESSION['email'])) {
        header("Location: ./01-login.php");
      }

      // $qry_aptb = "SELECT r_ut_a.aptBlock_id
      //                FROM ut_registered ut_r JOIN req_ut_access r_ut_a ON  ut_r.ut_id = r_ut_a.ut_id
      //               WHERE r_ut_a.status = 'accepted'
      //                 AND ut_r.ut_id = $usr_id";
      // $qry_aptb_res = pg_query($connect, $qry_aptb);
      // if (!$qry_aptb_res){ // error checking
      //   echo "Something went wrong<br>";
      //   echo pg_result_error($qry_aptb_res);
      // }
      // $qry_aptb_arr = pg_fetch_assoc($qry_aptb_res);
      // $_SESSION['aptBlock'] = $qry_aptb_arr['aptBlock_id'];
      // if (count($qry_aptb_arr) !== 0){
      //   $_SESSION['aptBlock'] = $qry_aptb_arr['aptBlock_id'];
      //   // may need something else, like redirection
      // } else {
      //   header("Location ../../<.php>;");
      // } 
      // pg_close($connect);
    ?>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("global/06-html/navbar.html");
      });
    </script>
    <!--end of Navigation bar-->
    <div class="grid">
      <div style="background-color: rgb(101, 189, 113)">
        <!--Calendar-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("./global/06-html/calendar-small.html");
          });
        </script>
        <!--End of calendar-->
        <!--Prenotazioni attive-->
        <div id="prenotazioni-attive"></div>
        <script>
          $(function () {
            $("#prenotazioni-attive").load("./global/06-html/prenotazioni_accettate.php");
          });
        </script>
        <!-- Fine prenotazioni -->
      </div>
      <div style="background-color: rgb(255, 255, 255)">
        <div class="bacheca">
          <div class="bacheca-types">
            <input
              class="bacheca-types__input"
              type="radio"
              name="bacheca-types"
              value="padmin"
              id="padmin"
              onclick="showTab('tab-admin')">
            <label class="bacheca-types__label" for="padmin">Post Admin</label>
          </div>
          <div class="bacheca-types">
            <input
              class="bacheca-types__input"
              type="radio"
              name="bacheca-types"
              value="putente"
              id="putente"
              onclick="showTab('tab-utente')">
            <label class="bacheca-types__label" for="putente"
              >Post Utente</label
            >
          </div>
        </div>

        <div class="tabcontent" id="tab-admin">
          <div id="admin-form-container">

          </div>

          <div class="post-container" id="admin-posts-container">

          </div>

        </div>

        <div class="tabcontent" id="tab-utente">

          <form action="./02-home/local_php/submit_post.php" class="post-form" id="user-post-form" method="post">
            <input type="text" id="ud-post-title" name="ud-post-title" placeholder="Titolo del post" required>
            <textarea id="ud-post-content" name="ud-post-content" placeholder="Scrivi qualcosa..." required></textarea>
            <input type="submit" value="Invia">
          </form>

          <div class="posts-container" id="user-posts-container">
            
          </div>    

        </div>
      </div>
      <div style="background-color: rgb(101, 189, 113)">
        <div class="contatti-utili">
          <ul>
            <li class="contatti-utili__nome">
              Nome - Amministratore Cellulare
            </li>
            <li class="contatti-utili__nome">Nome - Elettricista Cellulare</li>
            <li class="contatti-utili__nome">Nome - Fabbro Cellulare</li>
            <li class="contatti-utili__nome">Nome - Idraulico Cellulare</li>
          </ul>
        </div>
      </div>
    </div>
  <script src="./02-home/local_js/02-home.js"></script>
  <!-- <script src="./02-home/local_js/toggle_comments.js"></script> -->
  <script>document.getElementById("padmin").click();</script>
  <script src="./02-home/local_js/display_posts_ud.js"></script>
  </body>
</html>
