<?php
$host = "localhost";
$user = "root";
$password = "5964";
$database = "brisas_gems";
$port = 3307; 

$conn = new mysqli($host, $user, $password, $database, $port);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
?>