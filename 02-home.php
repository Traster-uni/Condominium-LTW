<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <link rel="stylesheet" href="./02-home/local_css/02-home.css" />
    <link rel="stylesheet" href="global/01-css/contatti.css">
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
  </head>
  <body>
    <?php
      /* session_start();

      if (!isset($_SESSION['ut_id'])) {
        header('01-login.html');
        exit();
      } */
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
    <div class="topnav">
      <a class="active" href="#home">Home</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
      <input type="text" placeholder="Search..">
    </div>
    <!-- end of search bar -->
    <div class="flexbox">
      <div style="background-color: rgb(101, 189, 113); width: 20%">
        <!--Calendar-->
        <div id="calendar"></div>
        <script>
          $(function () {
            $("#calendar").load("global/06-html/calendar-small.html");
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
          <div class="post">
            <h3 class="post-title">Post Admin 1<span class="post-tag-prova">Prova</span></h3>
            <p class="post-content">Contenuto Post Admin 1</p>
            <span class="post-date">17 Maggio 2024</span>
            <button type="button" class="toggle-comments">Commenti</button>
            <div class="responses">
              <div class="post response">
                <h4 class="post-title">Risposta 1</h4>
                <p class="post-content">Contenuto risposta 1.</p>
                <span class="post-date">17 Maggio 2024</span>
              </div>
              <div class="post response">
                <h4 class="post-title">Risposta 2</h4>
                <p class="post-content">Contenuto risposta 2.</p>
                <span class="post-date">17 Maggio 2024</span>
              </div>
            </div>
            <form class="response-form">
                <input type="text" placeholder="Aggiungi una risposta..." class="response-input">
                <button type="button" class="response-button">Rispondi</button>
            </form>
          </div>
            <div class="post">
              <h3 class="post-title">Post Admin 2</h3>
              <p class="post-content">Contenuto Post Admin 2</p>
              <span class="post-date">18 Maggio 2024</span>
            </div>
        </div>

        <div class="tabcontent" id="tab-utente">
          <div class="post">
            <h3 class="post-title">Post Utente 1</h3>
            <p class="post-content">Contenuto Post Utente 1</p>
            <span class="post-date">17 Maggio 2024</span>
          </div>
          <div class="post">
            <h3 class="post-title">Post Utente 2</h3>
            <p class="post-content">Contenuto Post Utente 2</p>
            <span class="post-date">18 Maggio 2024</span>
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
  <script src="./02-home/local_js/toggle_comments.js"></script>
  <script>document.getElementById("padmin").click();</script>
  </body>
</html>
