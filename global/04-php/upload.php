<?php
function upload_img($connection){
    /** $_FILES: contains all file data given to a server
     *  $_POST: contains post parameters given to a server
     *  When uploading files always check for these error messages
     *  in the following field:$_FILES['test']['name']
     *  https://www.php.net/manual/en/features.file-upload.errors.php
     * 
     *  Prepare the destination path to move your data in use global path 
     *  as good practice:
     *  
     *  To recover personal data quickly and easly insert in the filename
     *  some sort of identifier derived from the user
     */

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
                        echo '<a href="upload.php">carica un altro file</a>';
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
}
?>

