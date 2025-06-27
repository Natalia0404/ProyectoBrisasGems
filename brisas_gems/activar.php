<?php
// activar.php
require_once 'php/conexion.php';

if (isset($_GET['token'])) {
  $token = $_GET['token'];

  // Buscar token en base de datos (de tipo 'activacion')
  $stmt = $conn->prepare("SELECT t.usu_id, t.fecha_expiracion, u.usu_activo
                          FROM tokens t
                          JOIN usuarios u ON u.usu_id = t.usu_id
                          WHERE t.token = ? AND t.tipo = 'activacion'");
  $stmt->bind_param("s", $token);
  $stmt->execute();
  $resultado = $stmt->get_result();

  if ($resultado->num_rows === 1) {
    $row = $resultado->fetch_assoc();
    $usu_id = $row['usu_id'];
    $fecha_exp = $row['fecha_expiracion'];
    $activo = $row['usu_activo'];

    // Verificar si ya está activo
    if ($activo) {
      echo "<script>alert('Tu cuenta ya estaba activada.'); window.location.href='login.html';</script>";
      exit;
    }

    // Verificar si el token no ha expirado
    if (strtotime($fecha_exp) > time()) {
      // Activar usuario
      $stmt_update = $conn->prepare("UPDATE usuarios SET usu_activo = 1 WHERE usu_id = ?");
      $stmt_update->bind_param("i", $usu_id);
      $stmt_update->execute();

      // Eliminar token de activación
      $stmt_delete = $conn->prepare("DELETE FROM tokens WHERE token = ?");
      $stmt_delete->bind_param("s", $token);
      $stmt_delete->execute();

      echo "<script>alert('Cuenta activada con éxito. Ya puedes iniciar sesión.'); window.location.href='login.html';</script>";
    } else {
      echo "<script>alert('El token ha expirado. Por favor solicita un nuevo registro.'); window.location.href='registro.html';</script>";
    }
  } else {
    echo "<script>alert('Token inválido o inexistente.'); window.location.href='registro.html';</script>";
  }

  $stmt->close();
  $conn->close();
} else {
  header("Location: index.html");
  exit;
}
