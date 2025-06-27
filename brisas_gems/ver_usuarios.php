<?php
require_once 'php/conexion.php';

$query = "SELECT usu_id, usu_nombre, usu_correo, usu_telefono, usu_docnum, rol_id, tipdoc_id, usu_activo 
          FROM usuarios ORDER BY usu_id DESC";
$resultado = $conn->query($query);

if (!$resultado) {
    die("Error al consultar la base de datos: " . $conn->error);
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Listado de Usuarios</title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body class="container py-5">
  <h1 class="mb-4">Usuarios registrados en Brisas Gems</h1>

  <?php if ($resultado->num_rows > 0): ?>
    <table class="table table-bordered">
      <thead class="table-light">
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Correo</th>
          <th>Teléfono</th>
          <th>Documento</th>
          <th>Tipo Doc</th>
          <th>Rol</th>
          <th>Activo</th>
        </tr>
      </thead>
      <tbody>
        <?php while ($fila = $resultado->fetch_assoc()): ?>
          <tr>
            <td><?= $fila['usu_id'] ?></td>
            <td><?= $fila['usu_nombre'] ?></td>
            <td><?= $fila['usu_correo'] ?></td>
            <td><?= $fila['usu_telefono'] ?></td>
            <td><?= $fila['usu_docnum'] ?></td>
            <td><?= $fila['tipdoc_id'] ?></td>
            <td><?= $fila['rol_id'] ?></td>
            <td><?= $fila['usu_activo'] ? '✅' : '❌' ?></td>
          </tr>
        <?php endwhile; ?>
      </tbody>
    </table>
  <?php else: ?>
    <p class="alert alert-warning">No hay usuarios registrados aún.</p>
  <?php endif; ?>

</body>
</html>