<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Area Utente</title>
    <link rel="stylesheet" href="./02-home/local_css/02-home.css" />
    <link rel="stylesheet" href="./05-areautente/local_css/05-areautente.css" />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@48,400,0,0"
    />
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <script src="./ext_resources/04-js/tabs.js"></script>
  </head>
  <body>
    <?php
    session_start();

    if (!isset($_SESSION['ut_id'])) {
      header('01-login.html');
      exit();
    }
    ?>
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
        <div class="profile-pic" style="text-align: center">
          <img src="./global/02-images/default-pic.png" alt="Profile-Pic" />
          <div class="dati" style="text-align: center">
            <h2>Mario Rossi</h2>
          </div>
        </div>
        <!-- Tabs Impostazioni -->
        <div class="tab">
          <button
            class="tablinks"
            id="defaultOpen"
            onclick="openTab(event, 'Profilo')"
          >
          <span class="material-symbols-outlined">account_circle</span>Profilo
          </button>
          <button class="tablinks" onclick="openTab(event, 'Condominio')">
            <span class="material-symbols-outlined">domain</span>Condominio
          </button>
          <button class="tablinks" onclick="openTab(event, 'Impostazioni')">
            <span class="material-symbols-outlined">settings</span>Impostazioni
          </button>
          <button class="delete_acc">
            <span class="material-symbols-outlined">logout</span>Log Out
          </button>
        </div>
      </div>
      <div style="background-color: blanchedalmond; flex: 1">
        <!-- Tab Content-->
        <section id="Profilo" class="tabcontent">
          <h2>Profilo</h2>
        </section>
        <section id="Condominio" class="tabcontent">
          <h2>Condominio</h2>
        </section>
        <section id="Impostazioni" class="tabcontent">
          <h2>Impostazioni</h2>
        </section>
      </div>
    </div>
    <script>
      document.getElementById("defaultOpen").click();
    </script>
  </body>
</html>
