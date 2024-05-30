<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="./global/01-css/contatti.css">
    <link rel="stylesheet" href="./global/01-css/popup.css">
    <link rel="stylesheet" href="./04-ticket/local_css/04-ticket.css" />
    <link rel="stylesheet" href="./global/01-css/fonts.css">
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Lato"
    />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Montserrat"
    />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"
    />
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <script src="./ext_resources/04-js/tabs.js"></script>
    <script src="./ext_resources/04-js/bootstrap.bundle.js"></script>
    <title>Ticket</title>
  </head>
  <body>
    <?php
      session_start();
      $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
      if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
      }

      if (!isset($_SESSION['ut_id']) && !isset($_SESSION['email'])) {
        header("Location: ../../01-login.php");
      }

      $id_utente = $_SESSION["ut_id"];
      $check_admin = pg_num_rows(pg_query($connection, "SELECT ut_id FROM aptblock_admin WHERE ut_id = $id_utente"));
    ?>
    <!--Navigation bar-->
    <div id="navbar"></div>
    <script>
      $(function () {
        $("#navbar").load("./global/06-html/navbar.html");
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
        <?php if ($check_admin): ?>
          <div id="richieste-pending"></div>
          <script>
            $(function () {
              $("#richieste-pending").load("./global/06-html/richieste_pending.php");
            });
          </script>
        <?php else: ?>
          <div id="prenotazioni-attive"></div>
          <script>
            $(function () {
              $("#prenotazioni-attive").load("./global/06-html/prenotazioni_attive.php");
            });
          </script>
        <?php endif; ?>
      </div>
      <div id="central-body" style="background-color: rgb(255, 255, 255)">
        <!-- <button data-toggle="collapse" data-toggle="formTicket" class="openBtn">
          <h1>Nuovo Ticket</h1>
          <span class="material-symbols-outlined">add</span>
        </button>
        <div class="collapse" id="formTicket">
          <form action="./04-ticket/local_php/submit_ticket.php" method="post" name="ticket">
            <h4>Titolo</h4>
            <input type="text" name="titolo" id="titolo" size="50" required />
            <h4>Descrizione</h4>
            <textarea
              class="descrizione"
              name="descrizione"
              id="descrizione"
              cols="50"
              rows="10"
              minlength="50"
              required
            ></textarea>
            <br />
            <input type="file" type="image" />
            <input
              type="submit"
              value="Submit"
            />
            <input type="reset" />
          </form>
        </div> -->

        <div id="form-container">
          
        </div>

        <!-- Modale -->
        <div id="ticket-modal" class="modal">
          <div class="modal-content">
            <span class="close">&times;</span>
            <h2>Dettagli del Ticket</h2>
            <p id="ticket-title" class="ticket-title"></p>
            <p id="ticket-creation-date"></p>
            <p id="ticket-status"></p>
            <p id="ticket-lastReply"></p>
            <p id="ticket-content"></p>
            <div id="ticket-replies"></div>
          </div>
        </div>

        <div class="tab" id="ticket-tab">
          
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
    
    <script src="./04-ticket/local_js/04-visualizeTicket.js"></script>
    <!-- <script src="./04-ticket/local_js/04-ticket.js"></script> -->
    <script src="./04-ticket/local_js/04-submitTicket.js"></script>
    
  </body>
</html>
