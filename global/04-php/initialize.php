<?php
define("ABS_PATH", dirname(__FILE__));
define("PRIVATE_PATH", ABS_PATH."/private");
define("PUBLIC_PATH", ABS_PATH."/public");

/**
 * session_start();
 * //automatically retrive past session data if they do not exist create new
 * $_SESSION["user_id] = random(); //dunno if random exist in php
 * $_SESSION["user_name"] = retrive_usrname();
 * 
 * // html follows
 */