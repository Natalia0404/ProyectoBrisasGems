<?php
require_once '../conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $token = $_POST['token'];
  $password = $_POST['password'];
  $confirm_password = $_POST['confirm_password'];

  // Validar que ambas contraseñas coincidan
  if ($password !== $confirm_password) {
    echo "<script>alert('Las contraseñas no coinciden.'); window.history.back();</script>";
    exit;
  }

  // Buscar el token en la base de datos y validar tipo y expiración
  $stmt = $conn->prepare("SELECT usu_id, fecha_expiracion FROM tokens WHERE token = ? AND tipo = 'recuperacion'");
  $stmt->bind_param("s", $token);
  $stmt->execute();
  $stmt->store_result();

  if ($stmt->num_rows === 0) {
    echo "<script>alert('Token inválido o ya fue utilizado.'); window.location.href='../login.html';</script>";
    exit;
  }

  $stmt->bind_result($usu_id, $fecha_expiracion);
  $stmt->fetch();

  if (strtotime($fecha_expiracion) < time()) {
    echo "<script>alert('El token ha expirado.'); window.location.href='../recuperar.html';</script>";
    exit;
  }

  // Hashear nueva contraseña y actualizar
  $hashed_password = password_hash($password, PASSWORD_DEFAULT);
  $stmt_update = $conn->prepare("UPDATE usuarios SET usu_password = ? WHERE usu_id = ?");
  $stmt_update->bind_param("si", $hashed_password, $usu_id);
  $stmt_update->execute();

  // Eliminar token usado
  $stmt_delete = $conn->prepare("DELETE FROM tokens WHERE token = ?");
  $stmt_delete->bind_param("s", $token);
  $stmt_delete->execute();

  echo "<script>alert('Contraseña restablecida con éxito.'); window.location.href='../login.html';</script>";
} else {
  header("Location: ../recuperar.html");
  exit;
}
