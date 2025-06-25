<?php
// procesar_recuperacion.php
require_once '../conexion.php';
require_once '../funciones/token_generator.php'; // o puedes usar random_bytes directamente

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $correo = trim($_POST['correo']);

    // Buscar usuario por correo
    $stmt = $conn->prepare("SELECT usu_id FROM usuarios WHERE usu_correo = ?");
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0) {
        echo "<script>alert('Este correo no está registrado.'); window.history.back();</script>";
        exit;
    }

    $stmt->bind_result($usu_id);
    $stmt->fetch();

    // Generar token único
    $token = bin2hex(random_bytes(32));
    $fecha_exp = date('Y-m-d H:i:s', strtotime('+1 hour'));

    // Insertar token de recuperación
    $stmt_insert = $conn->prepare("INSERT INTO tokens (token, tipo, fecha_expiracion, usu_id)
                                   VALUES (?, 'recuperacion', ?, ?)");
    $stmt_insert->bind_param("ssi", $token, $fecha_exp, $usu_id);

    if ($stmt_insert->execute()) {
        $enlace = "http://localhost/restablecer.html?token=" . $token;
        echo "<script>alert('Te hemos enviado un enlace de recuperación a tu correo.'); window.location.href='login.html';</script>";

        // Aquí debes usar mail() o PHPMailer para enviar el enlace
        // mail($correo, "Recuperación de contraseña", "Haz clic para restablecer: $enlace");
    } else {
        echo "<script>alert('Error al generar el enlace.'); window.history.back();</script>";
    }

    $stmt->close();
    $stmt_insert->close();
    $conn->close();
} else {
    header("Location: ../recuperar.html");
    exit;
}
