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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
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

      if (!isset($_SESSION['ut_id']) && !isset($_SESSION['email'])) {
        header("Location: ../../01-login.php");
      } 
    ?>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("global/06-html/navbar.html");
      });
    </script>
    <!--end of Navigation bar-->
    <!-- search bar -->
    <!-- <div class="topnav">
      <a class="active" href="#home">Home</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
      <input type="text" placeholder="Search..">
    </div> -->
    <!-- end of search bar -->
    <div class="flexbox">
      <div style="background-color: rgb(101, 189, 113); width: 20%">
        <!--Calendar-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("./global/06-html/calendar-small.html");
          });
        </script>
        <!--End of calendar-->
      </div>
      <div style="background-color: rgb(255, 255, 255); flex: 1">
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

          <form action="./02-home/local_php/submit_post_ud.php" class="post-form" id="user-post-form" method="post">
            <input type="text" id="ud-post-title" name="ud-post-title" placeholder="Titolo del post" required>
            <textarea id="ud-post-content" name="ud-post-content" placeholder="Scrivi qualcosa..." required></textarea>
            <input type="submit" value="Invia">
          </form>

          <div class="posts-container" id="user-posts-container">
            
          </div>    

        </div>
      </div>
      <div style="background-color: rgb(101, 189, 113); width: 20%">
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
  <script>document.getElementById("padmin").click();</script>
  <script src="./02-home/local_js/display_posts.js"></script>
  <!-- <script src="./02-home/local_js/admin_features.js"></script> -->
  </body>
</html>
