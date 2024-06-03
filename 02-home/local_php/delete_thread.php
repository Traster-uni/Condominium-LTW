<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    if ($_SERVER["REQUEST_METHOD"] == "DELETE") {

        $thread_id = $_GET['thread_id'];

        $del_qry = "DELETE FROM post_thread 
                    WHERE thread_id = $thread_id";
        $result = pg_query($connection, $del_qry);
    }
    
    pg_free_result($result);
    pg_close();