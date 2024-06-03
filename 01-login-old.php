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
    <link rel="stylesheet" href="global/01-css/global.css"/>
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Lato"
    />
    <link
      href="https://fonts.googleapis.com/css2?family=Rubik:wght@400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

  </head>
  <body>
    <div class="grid">
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
          <div class="modal-content-signin">
            <div class="modal-header"><h2>Registrazione</h2></div>
            <div class="modal-body">
              <form action="./01-login/local_php/register.php" method="POST" id="registrationForm">
                <!-- <div id="step1" class="form-step"> -->
                  <div>
                    <label for="nome">Nome:</label>
                    <input type="text" name="nome" id="nome" required>
                  </div>
                  <div>
                    <label for="cognome">Cognome:</label>
                    <input type="text" name="cognome" id="cognome" required>
                  </div>
                  <div>
                    <label for="data-nascita">Data di nascita:</label>
                    <input type="date" name="data-nascita" id="data-nascita">
                  </div>
                  <div>
                    <label for="telefono">Telefono:</label>
                    <input type="tel" name="telefono" id="telefono" maxlength="13" required>
                  </div>
                  <div>
                    <label for="fiscal-code">Codice Fiscale:</label>
                    <input type="text" name="fiscal-code" maxlength="16" id="fiscal-code">
                  </div>
                  <div>
                    <label for="address">Indirizzo di residenza:</label>
                    <input type="text" name="address" id="address" required>
                  </div>
                  <div>
                    <label for="citta">Città di Residenza:</label>
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
                  </div>
                  <div>
                    <label for="email">E-mail:</label>
                    <input type="email" name="email" id="email-register" required>
                  </div>
                  <div>
                    <label for="password">Password:</label>
                    <input type="password" name="password" id="password-register" required>
                  </div>

                  <p id="errore-login"></p>

                  <input class="submit" type="submit" value="Invia">

                  <!-- <div class="centered-button-container">
                    <button type="button" id="nextBtn"><span class="material-symbols-outlined">chevron_right</span></button>
                  </div> -->
                  
                <!-- </div> -->

                <!-- <div id="step2" class="form-step" style="display: none;">
                  <div class="centered-button-container">
                    <button type="button" id="prevBtn"><span class="material-symbols-outlined">chevron_left</span></button>
                  </div>
                </div> -->
                
              </form>
            </div>
            <div class="modal-footer"></div>
          </div>
        </div>

        <!--Modale per il log in-->
        <div class="modal" id="modal-login">
          <div class="modal-content-login">
            <div class="modal-header"><h2>Accedi</h2></div>
            <div class="modal-body">
              <form action="./01-login/local_php/login.php" method="post" id="login-form">
                <div>
                  <label for="email">E-Mail:</label>
                  <input type="email" name="email" id="email">
                </div>
                <div>
                  <label for="password">Password:</label>
                  <input type="password" name="password" id="password">
                </div>
                <input class="submit" type="submit" name="login_button" id="login_button" value="Accedi">
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
