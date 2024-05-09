<?php
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    //Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {

        $nome = htmlspecialchars($_POST["nome"]);
        $cognome = htmlspecialchars($_POST["cognome"]);
        $dnascita = htmlspecialchars($_POST["data-nascita"]);
        $telefono = htmlspecialchars($_POST["telefono"]);
        $fiscalcode = htmlspecialchars($_POST["fiscal-code"]);
        $address = htmlspecialchars($_POST["address"]);
        $citta = htmlspecialchars($_POST["citta"]);
        $email = htmlspecialchars($_POST["email"]);
        $password = htmlspecialchars($_POST["password"]);
        $data = date("Y-m-d");

        //Preparo la query
        $q = "INSERT INTO ut_registered(nome, cognome, d_nascita, telefono, address, citta_residenza, ut_email, passwd, data_iscrizione) VALUES ('$nome', '$cognome', '$dnascita', '$telefono', '$address', '$citta', '$email', '$password', '$data')";
        $result = pg_query($connection, $q);

        // Verifica se l'inserimento è avvenuto con successo
        if ($result) {
            echo "Registrazione avvenuta con successo!";
            header("Location: /02-home.html");
        } else {
            echo "Errore durante la registrazione: " . pg_last_error($connection);
        }
    }

    // Chiudi la connessione al database
    pg_close($connection);
?>
    