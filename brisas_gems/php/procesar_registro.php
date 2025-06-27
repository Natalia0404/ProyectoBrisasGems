<?php
// procesar_registro.php

require_once 'conexion.php'; // Conexión a la base de datos
// require_once '../funciones/token_generator.php'; // Generador de tokens (puedes usar bin2hex directamente)

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  // 1. Capturar datos del formulario
  $nombre     = trim($_POST['nombre']);
  $correo     = trim($_POST['correo']);
  $telefono   = trim($_POST['telefono']);
  $tipdoc_id  = intval($_POST['tipdoc_id']);
  $docnum     = trim($_POST['usu_docnum']);
  $password   = password_hash($_POST['password'], PASSWORD_DEFAULT);
  $rol_id     = isset($_POST['rol_id']) ? intval($_POST['rol_id']) : 1; // Cliente por defecto

  // 2. Verificar si el correo ya está registrado
  $stmt = $conn->prepare("SELECT usu_id FROM usuarios WHERE usu_correo = ?");
  $stmt->bind_param("s", $correo);
  $stmt->execute();
  $stmt->store_result();

  if ($stmt->num_rows > 0) {
    echo "<script>alert('Este correo ya está registrado.'); window.history.back();</script>";
    exit;
  }

  // 3. Insertar usuario como inactivo
  $stmt = $conn->prepare("INSERT INTO usuarios 
    (usu_nombre, usu_correo, usu_telefono, usu_password, usu_docnum, rol_id, tipdoc_id, usu_activo) 
    VALUES (?, ?, ?, ?, ?, ?, ?, 0)");
  $stmt->bind_param("ssssssi", $nombre, $correo, $telefono, $password, $docnum, $rol_id, $tipdoc_id);

  if ($stmt->execute()) {
    $usu_id = $stmt->insert_id;

    // 4. Generar token de activación
    $token = bin2hex(random_bytes(32));
    $fecha_exp = date('Y-m-d H:i:s', strtotime('+1 day'));

    // 5. Guardar el token en la tabla 'tokens'
    $stmt_token = $conn->prepare("INSERT INTO tokens (token, tipo, fecha_expiracion, usu_id) VALUES (?, 'activacion', ?, ?)");
    $stmt_token->bind_param("ssi", $token, $fecha_exp, $usu_id);
    $stmt_token->execute();

    // 6. Simulación de envío de correo con enlace de activación
    $enlace = "http://localhost/activar.php?token=" . $token;
    echo "<script>alert('Registro exitoso. Revisa tu correo para activar la cuenta.');
    window.location.href='../login.html';</script>";

    // En producción: usar una función como mail() o PHPMailer para enviar el $enlace
    // mail($correo, "Activa tu cuenta", "Haz clic aquí para activar: $enlace");

  } else {
    echo "<pre>Error al registrar el usuario: " . $stmt->error . "</pre>";
    exit;
  }

  $stmt->close();
  $conn->close();

} else {
  // Si no se accede por POST, redireccionar
  header("Location: registro.html");
  exit;
}
?>