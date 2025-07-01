<?php
// procesar_registro.php

require_once 'conexion.php'; // Conexión a la base de datos

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  // 1. Capturar datos del formulario
  $nombre     = trim($_POST['nombre']);
  $correo     = trim($_POST['correo']);
  $telefono   = trim($_POST['telefono']);
  $tipdoc_id  = intval($_POST['tipdoc_id']);
  $docnum     = trim($_POST['usu_docnum']);
  $password   = password_hash($_POST['password'], PASSWORD_DEFAULT);
  $rol_id     = isset($_POST['rol_id']) ? intval($_POST['rol_id']) : 1; // Cliente por defecto

  // 2. Validar tipo de documento
  if ($tipdoc_id === 0) {
    echo "<script>alert('Por favor selecciona un tipo de documento válido.'); window.history.back();</script>";
    exit;
  }

  // 3. Verificar que el tipo de documento exista
  $check_doc = $conn->prepare("SELECT tipdoc_id FROM tipo_de_documento WHERE tipdoc_id = ?");
  $check_doc->bind_param("i", $tipdoc_id);
  $check_doc->execute();
  $check_doc->store_result();

  if ($check_doc->num_rows === 0) {
    echo "<script>alert('Tipo de documento no válido.'); window.history.back();</script>";
    $check_doc->close();
    exit;
  }
  $check_doc->close();

  // 4. Verificar si el correo ya está registrado
  $stmt = $conn->prepare("SELECT usu_id FROM usuarios WHERE usu_correo = ?");
  $stmt->bind_param("s", $correo);
  $stmt->execute();
  $stmt->store_result();

  if ($stmt->num_rows > 0) {
    echo "<script>alert('Este correo ya está registrado.'); window.history.back();</script>";
    $stmt->close();
    exit;
  }
  $stmt->close();

  // 5. Insertar usuario como inactivo
  $stmt = $conn->prepare("INSERT INTO usuarios 
    (usu_nombre, usu_correo, usu_telefono, usu_password, usu_docnum, rol_id, tipdoc_id, usu_activo) 
    VALUES (?, ?, ?, ?, ?, ?, ?, 0)");
  $stmt->bind_param("ssssssi", $nombre, $correo, $telefono, $password, $docnum, $rol_id, $tipdoc_id);

  if ($stmt->execute()) {
    $usu_id = $stmt->insert_id;

    // 6. Generar token de activación
    $token = bin2hex(random_bytes(32));
    $fecha_exp = date('Y-m-d H:i:s', strtotime('+1 day'));

    // 7. Guardar el token
    $stmt_token = $conn->prepare("INSERT INTO tokens (token, tipo, fecha_expiracion, usu_id) VALUES (?, 'activacion', ?, ?)");
    $stmt_token->bind_param("ssi", $token, $fecha_exp, $usu_id);

    if ($stmt_token->execute()) {
      $enlace = "http://localhost/brisas_gems/activar.php?token=$token";

      // ✅ Mostrar el enlace en pantalla para pruebas
      echo "<h3>✅ Registro exitoso</h3>";
      echo "<p>Simulación de envío de correo:</p>";
      echo "<p><strong>Enlace de activación:</strong> <a href='$enlace'>$enlace</a></p>";
      echo "<p><a href='../login.html'>Ir al login</a></p>";
    } else {
      echo "<pre>❌ Error al guardar el token: " . $stmt_token->error . "</pre>";
    }

    $stmt_token->close();
  } else {
    echo "<pre>❌ Error al registrar el usuario: " . $stmt->error . "</pre>";
  }

  $stmt->close();
  $conn->close();

} else {
  header("Location: registro.html");
  exit;
}
?>