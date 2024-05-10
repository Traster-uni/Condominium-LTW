<?php
function socket_setup($address, $port){

    if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
        echo "socket_create() faild;\n\treason: " . socket_strerror(socket_last_error()) . "\n";
    }

    if (socket_bind($sock, $address, $port) === false) {
        echo "socket_bind() faild;\n\treason: " . socket_strerror(socket_last_error($sock)) . "\n";
    }
}