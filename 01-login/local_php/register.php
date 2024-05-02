<?php
    $connection = pg_connect("host=localhost dbname=Condominium_LTW user=admin password=admin");
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $nome = htmlspecialchars($_POST["nome"];)
        $cognome = htmlspecialchars($_POST["cognome"];)
        $dnascita = htmlspecialchars($_POST["data-nascita"];)
        $telefono = htmlspecialchars($_POST["telefono"];)
        $fiscalcode = htmlspecialchars($_POST["fiscal-code"];)
        $citta = htmlspecialchars($_POST["citta"];)
        $email = htmlspecialchars($_POST["email"];)

        $q = "INSERT INTO "
    }