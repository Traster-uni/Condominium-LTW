<?php
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
// allow script to wait for a connection
// set_time_limit(0);

// Verifico che la connessione sia avvenuta con successo
// if (!$connection) {
//     echo "Errore, connessione non riuscita.<br>";
//     exit;
// } else {
//     echo "connected";
// }
define("ABS_PATH", "C:\\LTW-Condominium\\tests\\");
ini_set('display_errors', 1);
print_r($_FILES);
try {

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Check for: Undefined | Multiple Files | $_FILES Corruption Attack
        // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
        if (!isset($_FILES['upload-img']['error']) || is_array($_FILES['upload-img']['error'])) {
            // Check $_FILES['upload-img']['error'] value.
            // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
            switch ($_FILES['upload-img']['error']) {
                case UPLOAD_ERR_OK:
                    break;
                case UPLOAD_ERR_NO_FILE:
                    throw new RuntimeException('No file sent.');
                case UPLOAD_ERR_FORM_SIZE:
                    throw new RuntimeException('Exceeded filesize limit.');
                default:
                    throw new RuntimeException('Unknown errors.');
            }
        }

        // check filesize. 
        // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
        if ($_FILES['upload-img']['size'] > 1000000) {
            throw new RuntimeException('Exceeded filesize limit.');
        }

        // checking file type 
        // courtesy of user CertaiN (user contributed notes): https://www.php.net/manual/it/features.file-upload.php
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        if (false === $ext = array_search(
            $finfo->file($_FILES['upload-img']['tmp_name']),
            array(
                'jpg' => 'image/jpeg',
                'png' => 'image/png'
            ),
            true
        )) {
            throw new RuntimeException('Invalid file format.');
        }
        
        // execute upload
        if (isset($_POST["invio"])){
            if (is_uploaded_file($_FILES["upload-img"]["tmp_name"])){
                // filter_var: filters a variable with a given filter 
                $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
                
                $fName = strtolower(basename($_FILES["upload-img"]["name"]));
                $fName = str_replace(" ", "_", $fName);
                
                $target_dir = sprintf(ABS_PATH."/users/%s/pictures/photos/", $email);
                $target_dirfname = sprintf($target_dir."%s", $fName);
                echo "$target_dirfname";
                // check for directory
                if (!is_dir($target_dirfname)){
                    mkdir($target_dir);
                }
                // actually upload the file
                if (move_uploaded_file($_FILES["upload-img"]["tmp_name"], $target_fname)) {
                    // usr feedback and refresh
                    echo 'File uploaded correctly<br><br>';
                    echo "Upload: " . $_FILES["upload-img"]["name"] . "<br>";
                    echo "Type: " . $_FILES["upload-img"]["type"] . "<br>";
                    echo "Size: " . ($_FILES["upload-img"]["size"] / 1024) . " kB<br>";
                    echo "Temp file: " . $_FILES["upload-img"]["tmp_name"] . "<br>";
                    echo "LOCATION: $target_dir";
                } else {
                    $err =  $_FILES['upload-img']['error'];
                    throw new RuntimeException("File was not uploaded correctly, ERROR_MSG: $err");
                }
            }
        }
    }
} catch (RuntimeException $e) {
    echo $e->getMessage();
}
// page refresh
// header("Location: ../../prova_upload.php");

?>

