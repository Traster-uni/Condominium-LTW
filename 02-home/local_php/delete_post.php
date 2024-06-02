<?php
    session_start();
    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");

    if ($_SERVER["REQUEST_METHOD"] == "DELETE") {
        
        $post_id = $_GET['post_id'];
        $post_type = $_GET['type'];
        echo "$post_id, $post_type";
        if ($post_type === 'general'){
            $del_qry = "DELETE FROM tags_posts 
                            WHERE post_admin_id = $post_id;
                        DELETE FROM posts 
                            WHERE post_id = $post_id;";
        } else if ($post_type === 'admin'){
            $del_qry = "DELETE FROM tags_posts_admin 
                            WHERE post_admin_id = $post_id;
                        DELETE FROM posts_admin 
                            WHERE post_id = $post_id;";
        }

        $result = pg_query($connection, $del_qry);
    }

    pg_free_result($result);
    pg_close();
