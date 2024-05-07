<?php
function upload_img(){
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
   if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
        // filter_var: filters a variable with a given filter 
        $fName = strtolower(basename($_FILES["file"]["name"]));
        $fName = str_replace(" ", "", $fName);

        $target_fname = sprintf(__DIR__ . "/users/%s/pictures/photos/%s", $email, $fName);
        if ($_FILES) {

        } else {
            $err =  $_FILES['userfile']['error'];
            throw new \Exception("File was not uploaded, ERROR_MSG: $err");
        }
    }
}
?>

