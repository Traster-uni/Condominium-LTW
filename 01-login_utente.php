<!DOCTYPE html>
<html lang="it">
  <head>
    <title>Condominium</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="./01-login/local_css/01-login.css" />
    <link rel="stylesheet" href="./global/01-css/popup.css">
    <link rel="stylesheet" href="./global/01-css/fonts.css">
    <link rel="stylesheet" href="global/01-css/global.css" />
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
  </head>
  <body>

    <?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    // Verifico che la connessione è avvenuta con successo
    if (!$connection) {
      echo "Errore, connessione non riuscita.<br>";
      exit;
    }

    $id_utente = $_SESSION['ut_id'];

    // Se l'utente ha già un condominio lo reindirizzo direttamente alla home
    $check_access = pg_query($connection, "SELECT aptblock_id FROM req_ut_access WHERE ut_id = $id_utente AND status = 'accepted'");
    if (pg_num_rows($check_access)) {
      $_SESSION['aptblock_id'] = pg_fetch_result($check_access, 0, 0);
      pg_close($connection);
      header("Location: ../../02-home.php");
      session_regenerate_id(true);
    }

    $result_sent = pg_query($connection, "SELECT aptblock_id FROM req_ut_access WHERE ut_id = $id_utente");
    $array_sent = array();

    // Array per controllare se l'utente ha già fatto richiesta per questo condominio
    while ($row = pg_fetch_assoc($result_sent)) {
      $array_sent[] = $row['aptblock_id'];
    }
    $check_sent = json_encode($array_sent);

    $check_request = pg_query($connection, "SELECT ut_id FROM req_ut_access WHERE ut_id = $id_utente AND status = 'pending'");
    pg_close($connection);
    ?>

    <script type="text/javascript">
      var check_sent = <?php echo $check_sent; ?>;
    </script>

    <div class="grid">
      <div class="lightgreen"></div>

      <div>
        <header class="title center green">
          <h1 class="logo">CONDOMINIUM</h1>
        </header>

        <div class="buttons">
          <p>Inserisci il codice fornito dall'amministratore del tuo condominio e la tua carta d'identità per entrare.</p>
          <form class="id-form" enctype="multipart/form-data" action="./01-login/local_php/request_access.php" method="POST">
            <input type="file" name="upload-img" id="upload-img" required>
            <input class="id" type="number" name="id" id="id" required>
            <button class="id-button" id="submit" name="invio"> RICHIEDI ACCESSO </button>
          </form>
          <?php
          if (pg_num_rows($check_request) > 0): ?>
          <p>Hai inviato una richiesta per entrare nel tuo condominio, attendi che venga accettata.</p>
          <?php endif; ?>
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
  <script src="./01-login/local_js/01-login_utente.js"></script>
  <!--<script src="global/05-js/hover_text.js"></script>-->
  </body>
</html>
