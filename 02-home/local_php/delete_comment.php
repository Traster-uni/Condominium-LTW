<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    if ($_SERVER["REQUEST_METHOD"] == "DELETE") {

        $comment_id = $_GET['comment_id'];

        $del_qry = "DELETE FROM thread_comment 
                    WHERE comment_id = $comment_id";
        $result = pg_query($connection, $del_qry);
    }
    
    pg_free_result($result);
    pg_close();