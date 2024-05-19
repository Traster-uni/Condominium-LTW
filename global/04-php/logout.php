<?php
    session_unset(); // Unset all session variables
    session_destroy(); // Destroy the session
    header("Location: ../../01-login.html"); // Redirect to login page
    exit();