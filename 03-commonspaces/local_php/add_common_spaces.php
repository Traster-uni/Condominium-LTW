<?php
    session_start();

    $connection = pg_connect("host=127.0.0.1 port=5432 dbname=condominium_ltw user=user_condominium password=condominium");
    // check for succesful connection
    if (!$connection) {
        echo "Errore, connessione non riuscita.<br>";
        exit;
    } else {
        echo "connected<br>";
    }

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    if ($_SESSION["REQUEST_METHOD"] == "POST"){
        $usr_id = $_SESSION['ut_id'];
        $aptb_id = $_SESSION['aptBlock_id'];
        $img_dir = $_SESSION['resource_dir'];
        $cs_name = htmlspecialchars($_POST[""]);
        $floor = htmlspecialchars($_POST[""]);
        $int_num = htmlspecialchars($_POST[""]);

        $qry_chk = "SELECT cs.common_space_name, cs.int_num, cs.floor_num
                    FROM common_spaces cs
                    WHERE cs.aptblock_it = $aptb_id";
        $qry_chk_res = pg_query($connection, $qry_chk);
        if (!$qry_chk_res){ // error checking
        echo "Something went wrong<br>";
        echo pg_result_error($qry_chk_res);
        }

        // fetch associative array related to qry result
        $qry_chk_arr = pg_fetch_assoc($qry_chk_res);

        if ($qry_chk_arr['floor_num'] == $floor){
            if ($qry_chk_arr['int_num'] == $int_num){
                echo "it already exists a common space in the same floor and appartment";
                header("Location: ../../03-commonspaces.php");
                // refresh??
            }            
        }

        // imgs_dir check for directory insert resolution
        $qry_insrt = "INSERT INTO common_spaces(common_space_name, int_num, floor_num, imgs_dir)
                        VALUES ($cs_name, $int_name, $floor, $img_idr)";
        $qry_insrt_res = pg_query($connection, $qry_insrt);
        if (!$qry_insrt_res){ // error checking
            echo "Something went wrong<br>";
            echo pg_result_error($qry_insrt_res);
        }
        unset($_SESSION['resource_dir']);
    }
    $pg_close($connection);