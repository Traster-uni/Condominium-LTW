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
</body>
</html>