<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="./04-ticket/local_css/04-ticket.css" />
    <link rel="stylesheet" href="global/01-css/contatti.css">
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

      if (!isset($_SESSION['ut_id']) && isset($_SESSION["email"]) && isset($_SESSION["password"])) {
        header('01-login.html');
        exit();
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
        <button data-toggle="collapse" data-toggle="formTicket" class="openBtn">
          <h1>Nuovo Ticket</h1>
          <span class="material-symbols-outlined">add</span>
        </button>
        <div class="collapse" id="formTicket">
          <form action="/04-ticket/local_php/submit_ticket.php" method="post" name="ticket">
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
        </div>

        <div class="tab">
          
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
    
    <script src="./04-ticket/local_js/04-ticket.js"></script>
    <script src="./04-ticket/local_js/04-submitTicket.js"></script>
    <script src="./04-ticket/local_js/04-visualizeTicket.js"></script>
  </body>
</html>
