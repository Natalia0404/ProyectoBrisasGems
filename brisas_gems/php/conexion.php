<?php
$host = "localhost";
$user = "root";
$password = ""; // SIN contraseña
$database = "brisas_gems";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
?>