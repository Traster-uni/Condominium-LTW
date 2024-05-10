// provided by javier, javiern at gmail dot com at:https://www.php.net/manual/en/sockets.examples.php

<?php
error_reporting(E_ALL);

// allow script to wait for a connection
set_time_limit(0);

/* Activate the implicit output dump, so we will see what we are getting
  * while he comes */
ob_implicit_flush();

$address = '127.0.0.1';
$port = 10000;

if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
    echo "socket_create() faild;\n\treason: " . socket_strerror(socket_last_error()) . "\n";
}

if (socket_bind($sock, $address, $port) === false) {
    echo "socket_bind() faild;\n\treason: " . socket_strerror(socket_last_error($sock)) . "\n";
}

if (socket_listen($sock, 5) === false) {
    echo "socket_listen() faild;\n\treason: " . socket_strerror(socket_last_error($sock)) . "\n";
}

//clients array
$clients = array();

do {
    $read = array();
    $write = array();
    $except = array();
    $read[] = $sock;
    
    $read = array_merge($read,$clients);
    
    // Set up a blocking call to socket_select
    if(socket_select($read, $write, $except, $tv_sec = 5) < 1)
    {
        //    SocketServer::debug("Problem blocking socket_select?");
        continue;
    }
    
    // Handle new Connections
    if (in_array($sock, $read)) {        
        
        if (($msgsock = socket_accept($sock)) === false) {
            echo "socket_accept() faild;\n\treason: " . socket_strerror(socket_last_error($sock)) . "\n";
            break;
        }
        $clients[] = $msgsock;
        $key = array_keys($clients, $msgsock);
        /* Enviar instrucciones. */
        $msg = "\n Test server php \n" .
        "customer number: {$key[0]}\n" .
        "To exit, type 'quit'. To shut down the server type 'shutdown'.\n";
        socket_write($msgsock, $msg, strlen($msg));
        
    }
    
    // Handle Input
    foreach ($clients as $key => $client) { // for each client        
        if (in_array($client, $read)) {
            if (false === ($buf = socket_read($client, 2048, PHP_NORMAL_READ))) {
                echo "socket_read() faild;\n\treason: " . socket_strerror(socket_last_error($client)) . "\n";
                break 2;
            }
            if (!$buf = trim($buf)) {
                continue;
            }
            if ($buf == 'quit') {
                unset($clients[$key]);
                socket_close($client);
                break;
            }
            if ($buf == 'shutdown') {
                socket_close($client);
                break 2;
            }
            $talkback = "Client {$key}:\n\tsays: '$buf'.\n";
            socket_write($client, $talkback, strlen($talkback));
            echo "$buf\n";
        }
        
    }        
} while (true);

socket_close($sock);
?>