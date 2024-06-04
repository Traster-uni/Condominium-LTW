<!DOCTYPE html>
<html lang="it">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Condominium</title>
    <link rel="icon" type="image/x-icon" href="favicon.png">
    <link rel="stylesheet" href="./01-login/local_css/01-login.css" />
    <link rel="stylesheet" href="./global/01-css/popup.css">
    <link rel="stylesheet" href="global/01-css/global.css" />
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

    <div class="container">
      <div class="top blue">
        <h1 class="logo">CONDOMINIUM</h1>
      </div>
      <div class="bottom">
        <div class="left-utente">
            <p class="messaggio">Inserisci il codice fornito dall'amministratore del tuo condominio e la tua carta d'identità per entrare.</p>
            <div class="buttons">
              <form class="id-form" enctype="multipart/form-data" action="./01-login/local_php/request_access.php" method="POST">
                <input class="id" type="number" name="id" id="id" placeholder="ID" required>
                <input type="file" name="upload-img" id="upload-img" style="display: none;" required>
                <button class="doc" id="doc">Carica documento</button>
                <p class="file" id="file"></p>
                <button class="accesso" id="submit" name="invio"> RICHIEDI ACCESSO </button>
              </form>
            </div>
            <?php if (pg_num_rows($check_request) > 0): ?>
              <p>Hai inviato una richiesta per entrare nel tuo condominio, attendi che venga accettata.</p>
            <?php endif; ?>
        </div>

        <div class="info">
          <div>Interagisci con i tuoi condomini e il tuo amministratore pubblicando post e commentando</div>
          <div>Controlla gli eventi e gli avvisi importanti sul calendario</div>
          <div>Prenota gli spazi comuni che ti servono</div>
          <div>Invia ticket al tuo amministratore per qualsiasi tipo di problema</div>
        </div>
      </div>
      <div class="logout">
        <form action ="global/04-php/logout.php", method="POST">
          <button>
            <span class="material-symbols-outlined">logout</span>Log Out
          </button>
        </form>
      </div>
    </div>

    
    <script src="./01-login/local_js/01-login_utente.js"></script>
  </body>
</html>
