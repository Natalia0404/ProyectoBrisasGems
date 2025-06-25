<?php
// Datos de conexión para XAMPP (localhost)
$host = 'localhost';
$usuario = 'root';
$contrasena = ''; // En XAMPP, normalmente se deja vacío
$basedatos = 'brisas_gems'; // Asegúrate de que así se llame tu base de datos

// Crear conexión
$conn = new mysqli($host, $usuario, $contrasena, $basedatos);

// Verificar conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
