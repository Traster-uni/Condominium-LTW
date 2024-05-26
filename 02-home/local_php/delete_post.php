<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=rinaldo password=service");

    if ($_SERVER["REQUEST_METHOD"] == "DELETE") {

        $post_id = $_GET['post_id'];

        $del_qry = "DELETE FROM posts 
                    WHERE post_id = $post_id";
        $result = pg_query($connection, $del_qry);
    }

    pg_free_result($result);
    pg_close();
