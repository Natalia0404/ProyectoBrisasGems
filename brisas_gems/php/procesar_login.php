<?php
require_once 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $correo = trim($_POST['correo']);
  $password = $_POST['password'];

  // 1. Buscar al usuario por correo
  $stmt = $conn->prepare("SELECT usu_id, usu_password, usu_activo FROM usuarios WHERE usu_correo = ?");
  $stmt->bind_param("s", $correo);
  $stmt->execute();
  $resultado = $stmt->get_result();

  if ($resultado->num_rows === 1) {
    $usuario = $resultado->fetch_assoc();

    // 2. Verificar contraseña
    if (!password_verify($password, $usuario['usu_password'])) {
      echo "<script>alert('Contraseña incorrecta.'); window.history.back();</script>";
      exit;
    }

    // 3. Verificar si la cuenta está activa
    if (!$usuario['usu_activo']) {
      echo "<script>alert('Tu cuenta aún no está activada.'); window.history.back();</script>";
      exit;
    }

    // 4. Simulación de sesión iniciada
    echo "<script>alert('Inicio de sesión exitoso.'); window.location.href='../index.html';</script>";

  } else {
    echo "<script>alert('Correo no registrado.'); window.history.back();</script>";
  }

  $stmt->close();
  $conn->close();
} else {
  header("Location: ../login.html");
  exit;
}