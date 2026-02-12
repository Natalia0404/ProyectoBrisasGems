-- Primero, crea la base de datos si no existe
CREATE DATABASE IF NOT EXISTS vecindario_db;

-- Selecciona la base de datos para usarla
USE vecindario_db;

-- Tabla para los Usuarios (Vecinos)
-- Permitirá el registro y autenticación de usuarios. [cite: 14]
CREATE TABLE usuarios (
    usu_id INT PRIMARY KEY AUTO_INCREMENT,
    usu_nombre VARCHAR(150) NOT NULL,
    usu_correo VARCHAR(100) NOT NULL UNIQUE,
    usu_password VARCHAR(255) NOT NULL,
    usu_direccion VARCHAR(200), -- Para la autenticación por dirección
    usu_activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tabla para los Avisos
-- Permitirá publicar y ver avisos de distintas categorías. 
CREATE TABLE avisos (
    avi_id INT PRIMARY KEY AUTO_INCREMENT,
    avi_titulo VARCHAR(100) NOT NULL,
    avi_descripcion TEXT NOT NULL,
    avi_fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Usamos ENUM para las categorías predefinidas, como lo vimos antes.
    avi_categoria ENUM('AYUDA', 'ALERTAS', 'COMPRAS', 'REUNIONES', 'MASCOTAS', 'EVENTOS') NOT NULL,
    
    -- Usamos ENUM para el estado del aviso (para marcarlo como atendido). 
    avi_estado ENUM('PUBLICADO', 'ATENDIDO') NOT NULL DEFAULT 'PUBLICADO',
    
    -- Clave foránea para saber qué usuario publicó el aviso.
    usu_id INT,
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id)
);

-- Tabla para los Comentarios
-- Permitirá a los usuarios comentar en los avisos. 
CREATE TABLE comentarios (
    com_id INT PRIMARY KEY AUTO_INCREMENT,
    com_contenido TEXT NOT NULL,
    com_fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Clave foránea para saber qué usuario hizo el comentario.
    usu_id INT,
    -- Clave foránea para saber a qué aviso pertenece el comentario.
    avi_id INT,
    
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id),
    -- ON DELETE CASCADE significa que si se borra un aviso, sus comentarios también se borrarán.
    FOREIGN KEY (avi_id) REFERENCES avisos(avi_id) ON DELETE CASCADE
);