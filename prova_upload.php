<?php
        session_start();
        define("ABS_PATH", __DIR__);
        define("PRIVATE_PATH", ABS_PATH."/private");
        define("PUBLIC_PATH", ABS_PATH."/public");
?>  
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prova Upload</title>
</head>
<body>
    <form enctype="multipart/form-data", action="global/04-php/upload.php" method="post">
        <input type="hidden" name="MAX_FILE_SIZE" value="30000" />
        <input type="file" name="upload-img" id="upload-img">
        <br>
        <input type="submit" value="invia" name="invio">
    </form>
    <?php

    // Verifico che la connessione sia avvenuta con successo
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected";
    }

    try {

        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        
            // Check for: Undefined | Multiple Files | $_FILES Corruption Attack
            // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
            if (!isset($_FILES['upfile']['error']) || is_array($_FILES['upfile']['error'])) {
                throw new RuntimeException('Invalid parameters.');
            }
    
            // Check $_FILES['upfile']['error'] value.
            // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
            switch ($_FILES['upfile']['error']) {
                case UPLOAD_ERR_OK:
                    break;
                case UPLOAD_ERR_NO_FILE:
                    throw new RuntimeException('No file sent.');
                case UPLOAD_ERR_INI_SIZE:
                case UPLOAD_ERR_FORM_SIZE:
                    throw new RuntimeException('Exceeded filesize limit.');
                default:
                    throw new RuntimeException('Unknown errors.');
            }
    
            // check filesize. 
            // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
            if ($_FILES['upfile']['size'] > 1000000) {
                throw new RuntimeException('Exceeded filesize limit.');
            }

            // checking file type 
            // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
            $finfo = new finfo(FILEINFO_MIME_TYPE);
            if (false === $ext = array_search(
                $finfo->file($_FILES['upfile']['tmp_name']),
                array(
                    'jpg' => 'image/jpeg',
                    'png' => 'image/png',
                    'gif' => 'image/gif',
                ),
                true
            )) {
                throw new RuntimeException('Invalid file format.');
            }
            
            // execute upload
            if (isset($_POST["invio"])){
                if (is_uploaded_file($_FILES["file"]["name"])){
                    // filter_var: filters a variable with a given filter 
                    $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
                    
                    $fName = strtolower(basename($_FILES["file"]["name"]));
                    $fName = str_replace(" ", "", $fName);
                    
                    $target_dir = sprintf(ABS_PATH."/users/%s/pictures/photos/", $email);
                    $target_fname = sprintf($target_dir."%s", $fName);
                    
                    // check for directory
                    if (!is_dir($target_fname)){
                        mkdir($target_dir);
                    }

                    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_fname)) {
                        // usr feedback and refresh
                        echo 'File uploaded correctly<br><br>';
                        echo "Upload: " . $_FILES["file"]["name"] . "<br>";
                        echo "Type: " . $_FILES["file"]["type"] . "<br>";
                        echo "Size: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
                        echo "Temp file: " . $_FILES["file"]["tmp_name"] . "<br>";
                        echo "LOCATION: $target_dir";
                        echo '<a href="global/04-php/upload.php">carica un altro file</a>';
                    } else {
                        $err =  $_FILES['userfile']['error'];
                        throw new RuntimeException("File was not uploaded correctly, ERROR_MSG: $err");
                    }
                }
            }
        }
    } catch (RuntimeException $e) {
        echo $e->getMessage();
    }
    ?>
</body>
</html>