<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=user_condominium");
    //Verifico che la connessione è avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    }

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    if (!isset($_SESSION['ut_id']) && !isset($_SESSION['email']) && !isset($_SESSION['aptblock_id'])) {
        header("Location: ./01-login.php");
    }
    //Prendo i dati dalla form e li vado ad inserire nella tabella sul DB
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $target_fname = null;
    
        // Check if file was uploaded
        if (isset($_FILES['upload-img']) && $_FILES['upload-img']['error'] != UPLOAD_ERR_NO_FILE) {
            // Check for file upload errors
            if (!isset($_FILES['upload-img']['error']) || is_array($_FILES['upload-img']['error'])) {
                echo "Invalid parameters.";
                exit;
            }
    
            switch ($_FILES['upload-img']['error']) {
                case UPLOAD_ERR_OK:
                    break;
                case UPLOAD_ERR_INI_SIZE:
                case UPLOAD_ERR_FORM_SIZE:
                    echo "Exceeded filesize limit.";
                    exit;
                case UPLOAD_ERR_PARTIAL:
                    echo "Uploaded file was only partially uploaded.";
                    exit;
                default:
                    echo "Unknown error.";
                    exit;
            }
    
            // Check filesize
            if ($_FILES['upload-img']['size'] > 1000000) {
                echo "Exceeded filesize limit.";
                exit;
            }
    
            // Check file type
            $finfo = new finfo(FILEINFO_MIME_TYPE);
            $ext = array_search(
                $finfo->file($_FILES['upload-img']['tmp_name']),
                array('jpg' => 'image/jpeg', 'png' => 'image/png'),
                true
            );
            if ($ext === false) {
                echo "Invalid file format.";
                exit;
            }
    
            // Set paths according to OS
            $div = DIRECTORY_SEPARATOR;
            $root = $_SERVER["DOCUMENT_ROOT"] . $div . "04-ticket" . $div . "ticket_imgs";
    
            // Ensure email is set in session
            if (!isset($_SESSION['email'])) {
                echo "Session email not set.";
                exit;
            }
    
            $email = $_SESSION['email'];
            $fName = strtolower(basename($_FILES["upload-img"]["name"]));
            $fName = str_replace(" ", "_", $fName);
            $data = date("Y-m-d_H-i-s");
    
            $target_dir = "users" . $div . $email . $div . "pictures" . $div . $data;
            //$target_dir = sprintf("users%s%s%spictures%s%s", $div, $email, $div, $div, $data);
            $relative_path = "04-ticket" . $div . "ticket_imgs" . $div . $target_dir . $div . $fName; // Store relative path
            $target_fname = $root . $div . $target_dir . $div . $fName;
    
            // Create directory if it doesn't exist
            if (!file_exists($root . $div . $target_dir)) {
                if (!mkdir($root . $div . $target_dir, 0700, true) && !is_dir($root . $div . $target_dir)) {
                    echo "Failed to create directories.";
                    exit;
                }
            }
    
            // Move uploaded file
            if (move_uploaded_file($_FILES["upload-img"]["tmp_name"], $target_fname)) {
                echo "File uploaded correctly<br><br>";
                echo "Upload: " . $_FILES["upload-img"]["name"] . "<br>";
                echo "Type: " . $_FILES["upload-img"]["type"] . "<br>";
                echo "Size: " . ($_FILES["upload-img"]["size"] / 1024) . " kB<br>";
                echo "Temp file: " . $_FILES["upload-img"]["tmp_name"] . "<br>";
                echo "LOCATION: $relative_path";
            } else {
                echo "File was not uploaded correctly.";
                exit;
            }
        }
            

        $titolo = htmlspecialchars($_POST["titolo"]);
        $comm_text = htmlspecialchars($_POST["descrizione"]);
        
        $id = $_SESSION["ut_id"];
        $data = date("Y-m-d H:i:s");

        //Query per prendere l'id dell'admin
        $query = "SELECT req_aptblock_create.ut_id AS admin_id 
                    FROM req_ut_access 
                    JOIN req_aptblock_create ON req_ut_access.aptblock_id = req_aptblock_create.aptblockreq_id 
                    WHERE req_ut_access.status = 'accepted' 
                    AND req_ut_access.ut_id = $id";
        $admin_id = pg_fetch_result(pg_query($connection, $query), 0, 'admin_id');
        /* $qry_ut_owner = "SELECT ut_o.utreq_id as ut_owner_id
                            FROM ut_registered ut_r 
                            JOIN req_ut_access req_a ON ut_r.ut_id = req_a.ut_id
                            JOIN ut_owner ut_o ON ut_o.utreq_id = req_a.utreq_id
                            WHERE ut_r.ut_id = $id";
        $ut_owner_id = pg_fetch_result(pg_query($connection, $qry_ut_owner), 0, 'ut_owner_id'); */

        //Preparo la query
        if ($relative_path) {
            //                                                                          changed, was imgs_fname
            $qry_ticket = "INSERT INTO tickets(ud_id, aptblock_admin, title, comm_text, img_fname, time_born, time_lastreplay, status) 
                        VALUES ($id, $admin_id, '$titolo', '$comm_text', '$relative_path', '$data', '$data', 'open')";
        } else {
            $qry_ticket = "INSERT INTO tickets(ud_id, aptblock_admin, title, comm_text, time_born, time_lastreplay, status) 
                        VALUES ($id, $admin_id, '$titolo', '$comm_text', '$data', '$data', 'open')";
        }
        $result_ticket_insert = pg_query($connection, $qry_ticket);

        // Verifica se l'inserimento è avvenuto con successo
        if ($result_ticket_insert) {
            echo "Ticket sent successfully!";
            header("Location: ../../04-ticket.php");
        } else {
            echo "Ticket not sent, ERROR: " . pg_result_error($result_ticket_insert);
        }
    }

    // Chiudi la connessione al database
    pg_close($connection);