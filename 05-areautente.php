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
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    $connect = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if (!$connect) {
      echo "Errore, connessione non riuscita.<br>";
      exit();
    }
    if (!isset($_SESSION['ut_id']) && !isset($_SESSION['email'])) {
      header("Location: ../../01-login.php");
      exit();
    }
    $id_utente = $_SESSION["ut_id"];
    $qry_check_res = pg_query($connect, "SELECT utreq_id FROM ut_owner WHERE utreq_id = $id_utente");
    $qry_check_arr = pg_num_rows($check_registered);
    if (!$qry_check_arr) {
      header('01-login2.html');
    } else {
      header('01-login1.html');
    }

    $qry_name = "SELECT ut_r.nome
                  FROM ut_registered ut_r
                  WHERE ut_r.ut_id = $id_utente";
    $qry_name_res = pg_query($connect, $qry_name);
    if (!$qry_name_res){ // error checking
      echo "Something went wrong<br>";
      echo pg_result_error($qry_name_res);
    }
    $qry_name_arr = pg_fetch_assoc($qry_check_res);
    $nome = $qry_name_arr['nome'];

    ?>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("./global/06-html/navbar.html");
      });
    </script>
    <!--end of Navigation bar-->

    <div class="flexbox">
      <div style="background-color: rgb(101, 189, 113); width: 20%">
        <div class="profile-pic" style="text-align: center">
          <img src="./global/02-images/default-pic.png" alt="Profile-Pic" />
          <div class="dati" style="text-align: center">
            <!-- <h2> Mario Rossi </h2> -->
            <!-- <h2><?php echo htmlspecialchars($qry_name_arr['nome'])?></h2> -->
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
          <form action ="global/04-php/logout.php", method="POST">
            <button class="delete_acc">
              <span class="material-symbols-outlined">logout</span>Log Out
          </form>
        </div>
      </div>
      <div style="background-color: white; flex: 1">
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
