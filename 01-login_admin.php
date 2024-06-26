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

    $id_admin = $_SESSION['ut_id'];

    // Se l'admin ha già un condominio lo reindirizzo direttamente alla home
    $check_aptblock = pg_query($connection, "SELECT ut_id FROM req_aptblock_create WHERE ut_id = $id_admin AND stat = 'accepted'");
    if (pg_num_rows($check_aptblock)) {
      pg_close($connection);
      header("Location: ../../02-home.php");
      session_regenerate_id(true);
    }

    $result_exists = pg_query($connection, "SELECT city, addr_aptb FROM req_aptblock_create WHERE stat = 'accepted'");
    $result_sent = pg_query($connection, "SELECT city, addr_aptb FROM req_aptblock_create WHERE ut_id = $id_admin AND stat = 'pending'");
    $array_exists = array();
    $array_sent = array();

    // Array per controllare se esiste già un condominio con la città e l'indirizzo messi in input
    while ($row = pg_fetch_assoc($result_exists)) {
      $array_exists[] = [
        'città' => $row['city'],
        'indirizzo' => $row['addr_aptb']
      ];
    }
    // Array per controllare se esiste già una richiesta da parte dell'admin per un condominio con la città e l'indirizzo messi in input
    while ($row = pg_fetch_assoc($result_sent)) {
      $array_sent[] = [
        'città' => $row['city'],
        'indirizzo' => $row['addr_aptb']
      ];
    }

    $check_exists = json_encode($array_exists);
    $check_sent = json_encode($array_sent);

    $check_request = pg_query($connection, "SELECT ut_id FROM req_aptblock_create WHERE ut_id = $id_admin AND stat = 'pending'");
    pg_close($connection);
    ?>

    <script type="text/javascript">
      var check_exists = <?php echo $check_exists; ?>;
      var check_sent = <?php echo $check_sent; ?>;
    </script>

    <div class="container">
      <div class="top blue">
        <h1 class="logo">CONDOMINIUM</h1>
      </div>
      <div class="bottom">
        <div class="left">
          <p class="sottotitolo">La community per il tuo condominio</p>
          <div class="buttons">
            <button class="button" id="aptblock-button"> CREA CONDOMINIO </button>
          </div>
          <?php if (pg_num_rows($check_request) > 0): ?>
            <p>Hai inviato una richiesta per la creazione di un condominio. Attendi che venga accettata o inviane un'altra.</p>
          <?php endif; ?>

          <!--Modale per la creazione condominio-->
          <div class="modal" id="modal-aptblock">
            <div class="modal-content">
              <div class="modal-header"><h2>Creazione condominio</h2></div>
              <div class="modal-body">
                <form action="./01-login/local_php/new_aptblock.php" method="POST" id="aptblockForm">
                  <div>
                    <label for="città">Città:</label>
                    <select name="città" id="città" required>
                      <option value="">Seleziona</option>
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
                    <label for="indirizzo">Indirizzo:</label>
                    <input type="text" name="indirizzo" id="indirizzo" required>
                  </div>
                  <div>
                    <label for="cap">CAP:</label>
                    <input type="text" inputmode="numeric" name="cap" id="cap" required>
                  </div>
                  <input class="button" type="submit" value="Crea" id="submit">
                </form>
              </div>
            </div>
          </div>
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
  <script src="./01-login/local_js/01-login_admin.js"></script>
  </body>
</html>
