<?php
  session_start();
?>
<!DOCTYPE html>
<html lang="it">
  <head>
    <title>Condominium</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="./01-login/local_css/01-login.css" />
    <link rel="stylesheet" href="./global/01-css/popup.css">
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Lato"
    />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Montserrat"
    />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    
    <style>
      body,
      h1 {
        margin: 0;
        font-family: "Lato", sans-serif;
      }
      button {
        font-family: "Montserrat", sans-serif;
      }
    </style>
  </head>
  <body>
    <div class="grid">
      <div class="lightgreen"></div>
      <div>
        <header class="title center green">
          <h1 class="logo">CONDOMINIUM</h1>
        </header>
        <div class="buttons">
          <button class="button" id="signin-button"> REGISTRATI </button>
          <button class="button" id="login-button"> LOGIN </button>
        </div>
        <!--Modale per la registrazione-->
        <div class="modal" id="modal-signin">
          <div class="modal-content">
            <div class="modal-header"><h2>Registrazione</h2></div>
            <div class="modal-body">
              <form action="./01-login/local_php/register.php" method="POST" id="registrationForm">
                <div id="step1" class="form-step">
                  <label for="nome">Nome</label>
                  <input type="text" name="nome" id="nome" required>

                  <label for="cognome">Cognome</label>
                  <input type="text" name="cognome" id="cognome" required>

                  <label for="data-nascita">Data di nascita</label>
                  <input type="date" name="data-nascita" id="data-nascita">

                  <label for="telefono">Telefono</label>
                  <input type="tel" name="telefono" id="telefono" maxlength="13" required>

                  <label for="fiscal-code">Codice Fiscale</label>
                  <input type="text" name="fiscal-code" maxlength="16" id="fiscal-code">

                  <label for="address">Indirizzo di residenza</label>
                  <input type="text" name="address" id="address" required>

                  <label for="citta">Città di Residenza</label>
                  <select name="citta" id="citta" required>
                    <option value="">-</option>
                    <option value="Torino">Torino</option>
                    <option value="Aosta">Aosta</option>
                    <option value="Milano">Milano</option>
                    <option value="Trento">Trento</option>
                    <option value="Venezia">Venezia</option>
                    <option value="Trieste">Trieste</option>
                    <option value="Genova">Genova</option>
                    <option value="Bologna">Bologna</option>
                    <option value="Firenze">Firenze</option>
                    <option value="Perugia">Perugia</option>
                    <option value="Ancona">Ancona</option>
                    <option value="Roma">Roma</option>
                    <option value="L Aquila">L'Aquila</option>
                    <option value="Campobasso">Campobasso</option>
                    <option value="Napoli">Napoli</option>
                    <option value="Bari">Bari</option>
                    <option value="Potenza">Potenza</option>
                    <option value="Catanzaro">Catanzaro</option>
                    <option value="Palermo">Palermo</option>
                    <option value="Cagliari">Cagliari</option>
                  </select>
                  
                  <label for="email">E-mail</label>
                  <input type="email" name="email" id="email" required>

                  <label for="password">Password</label>
                  <input type="password" name="password" id="password" required>

                  <input type="submit" value="Invia">

                  <div class="centered-button-container">
                    <button type="button" id="nextBtn"><span class="material-symbols-outlined">chevron_right</span></button>
                  </div>
                  
                </div>

                <div id="step2" class="form-step" style="display: none;">
                  <div class="centered-button-container">
                    <button type="button" id="prevBtn"><span class="material-symbols-outlined">chevron_left</span></button>
                  </div>
                </div>
                
              </form>
            </div>
            <div class="modal-footer"></div>
          </div>
        </div>

        <!--Modale per il log in-->
        <div class="modal" id="modal-login">
          <div class="modal-content">
            <div class="modal-header"><h2>Accedi</h2></div>
            <div class="modal-body">
              <form action="./01-login/local_php/login.php" method="post">
                <label for="email">E-Mail</label>
                <input type="email" name="email" id="email">
                <label for="password">Password</label>
                <input type="password" name="password" id="password">
                <input type="submit" name="login_button" id="login_button" value="Accedi">
              </form>
            </div>
            <div class="modal-footer"></div>
          </div>
        </div>

        <div style="padding-left: 40px; padding-right: 40px">
          <div>
            <div>
              <h1>Lorem Ipsum</h1>
              <h3>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
                eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
                enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat.
              </h3>

              <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
                eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
                enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat. Excepteur sint occaecat
                cupidatat non proident, sunt in culpa qui officia deserunt mollit
                anim id est laborum consectetur adipiscing elit, sed do eiusmod
                tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
                minim veniam, quis nostrud exercitation ullamco laboris nisi ut
                aliquip ex ea commodo consequat.
              </p>
            </div>
          </div>
        </div>
    </div>
    <div class="lightgreen"></div>
  <script src="./01-login/local_js/01-login.js"></script>
  <!--<script src="global/05-js/hover_text.js"></script>-->
  </body>
</html>