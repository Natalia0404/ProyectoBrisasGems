-- ==================================
-- CREACION DE BASE DE DATOS Y TABLAS
-- VERSION 3.0 - CON CATEGORIAS Y SESIONES
-- ==================================

DROP DATABASE IF EXISTS brisas_gems;
CREATE DATABASE brisas_gems;
USE brisas_gems;

-- =============================
-- 1. SISTEMA Y USUARIOS
-- =============================

CREATE TABLE tipo_de_documento(
    tipdoc_id       INT PRIMARY KEY AUTO_INCREMENT,
    tipdoc_nombre   VARCHAR(100) NOT NULL
) COMMENT='Tipos de documento de identidad';

CREATE TABLE rol(
    rol_id      INT PRIMARY KEY AUTO_INCREMENT,
    rol_nombre  VARCHAR(50) NOT NULL
) COMMENT='Roles del sistema (usuario, administrador, diseñador)';

CREATE TABLE usuarios (
    usu_id          INT PRIMARY KEY AUTO_INCREMENT,
    usu_nombre      VARCHAR(150) NOT NULL,
    usu_correo      VARCHAR(100) NOT NULL UNIQUE,
    usu_telefono    VARCHAR(20),
    usu_password    VARCHAR(255) NOT NULL,
    usu_docnum      VARCHAR(20) UNIQUE,
    rol_id          INT,
    tipdoc_id       INT,
    usu_activo      BOOLEAN NOT NULL DEFAULT TRUE,
    usu_origen      ENUM('registro', 'formulario', 'admin') NOT NULL DEFAULT 'registro',
    FOREIGN KEY (tipdoc_id) REFERENCES tipo_de_documento (tipdoc_id),
    FOREIGN KEY (rol_id) REFERENCES rol (rol_id)
) COMMENT='Tabla principal de usuarios del sistema';

CREATE TABLE tokens (
    tok_id             INT PRIMARY KEY AUTO_INCREMENT,
    token              VARCHAR(255) NOT NULL,
    tipo               ENUM('activacion', 'recuperacion') NOT NULL DEFAULT 'recuperacion',
    fecha_expiracion   DATETIME NOT NULL,
    usu_id             INT,
    FOREIGN KEY (usu_id) REFERENCES usuarios (usu_id) ON DELETE CASCADE
) COMMENT='Tokens de activacion y recuperacion de contraseña';

-- Sesiones anonimas
CREATE TABLE sesion_anonima (
    ses_id                  INT PRIMARY KEY AUTO_INCREMENT,
    ses_token               VARCHAR(100) UNIQUE NOT NULL COMMENT 'UUID generado en frontend',
    ses_fecha_creacion      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ses_fecha_expiracion    DATETIME NOT NULL COMMENT 'Tipicamente +30 dias desde creacion',
    ses_convertido          BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Se registro el usuario anonimo',
    usu_id_convertido       INT NULL COMMENT 'Usuario registrado si se convirtio',
    
    FOREIGN KEY (usu_id_convertido) REFERENCES usuarios(usu_id) ON DELETE SET NULL,
    
    INDEX idx_token (ses_token),
    INDEX idx_fecha_expiracion (ses_fecha_expiracion),
    INDEX idx_convertido (ses_convertido)
) COMMENT='Rastrea actividad de usuarios anonimos antes de registrarse';

-- =============================
-- 2. PERSONALIZACION DE PRODUCTOS
-- =============================

-- 1. NUEVA TABLA: Categoría General
CREATE TABLE categoria_producto (
    cat_id      INT PRIMARY KEY AUTO_INCREMENT,
    cat_nombre  VARCHAR(100) NOT NULL, -- Ej: 'Anillos', 'Pulseras'
    cat_slug    VARCHAR(100) UNIQUE    -- Ej: 'anillos', 'pulseras'
) COMMENT='Tipo de producto base';

-- 2. MODIFICADA: Opciones (Ahora pertenecen a una categoría)
CREATE TABLE opcion_personalizacion (
    opc_id      INT PRIMARY KEY AUTO_INCREMENT,
    opc_nombre  VARCHAR(100) NOT NULL,
    cat_id      INT NOT NULL, -- << RELACION CON CATEGORIA
    FOREIGN KEY (cat_id) REFERENCES categoria_producto(cat_id) ON DELETE CASCADE
) COMMENT='Preguntas de personalización (Forma, Metal...)';

-- 3. IGUAL: Valores
CREATE TABLE valor_personalizacion (
    val_id      INT PRIMARY KEY AUTO_INCREMENT,
    val_nombre  VARCHAR(100) NOT NULL,
    val_imagen  VARCHAR(250),
    opc_id      INT,
    FOREIGN KEY (opc_id) REFERENCES opcion_personalizacion (opc_id) ON DELETE CASCADE
) COMMENT='Respuestas/Botones (Oro, Plata, Redondo...)';

-- 4. MODIFICADA: Personalización (La Cabecera del pedido)
CREATE TABLE personalizacion (
    per_id          INT PRIMARY KEY AUTO_INCREMENT,
    per_fecha       DATE NOT NULL,
    usu_id_cliente  INT NULL,
    ses_id          INT NULL,
    
    cat_id          INT NOT NULL, -- << QUE ESTA DISEÑANDO

    FOREIGN KEY (usu_id_cliente) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    FOREIGN KEY (ses_id) REFERENCES sesion_anonima (ses_id) ON DELETE SET NULL,
    FOREIGN KEY (cat_id) REFERENCES categoria_producto (cat_id),
    
    INDEX idx_usuario (usu_id_cliente),
    INDEX idx_sesion (ses_id)
) COMMENT='Cabecera de la personalización';

-- 5. IGUAL: Detalle
CREATE TABLE detalle_personalizacion (
    det_id  INT PRIMARY KEY AUTO_INCREMENT,
    per_id  INT,
    val_id  INT,
    
    FOREIGN KEY (per_id) REFERENCES personalizacion (per_id) ON DELETE CASCADE,
    FOREIGN KEY (val_id) REFERENCES valor_personalizacion (val_id)
) COMMENT='Detalle de opciones elegidas'; -- << AQUI FALTABA EL PUNTO Y COMA

-- =============================
-- 4. EXPERIENCIA DEL CLIENTE
-- =============================

CREATE TABLE contacto_formulario (
    con_id          INT PRIMARY KEY AUTO_INCREMENT,
    usu_id          INT NULL COMMENT 'Usuario registrado (si esta logueado)',
    ses_id          INT NULL COMMENT 'Sesion anonima (si viene de personalizacion)',
    con_nombre      VARCHAR(150) NOT NULL,
    con_correo      VARCHAR(100),
    con_telefono    VARCHAR(30),
    con_mensaje     TEXT NOT NULL,
    con_fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    con_via         ENUM('formulario', 'whatsapp') DEFAULT 'formulario',
    con_terminos    BOOLEAN NOT NULL,
    con_estado      ENUM('pendiente','atendido','archivado') NOT NULL DEFAULT 'pendiente',
    con_notas       TEXT,
    per_id          INT NULL COMMENT 'Personalizacion vinculada en el mensaje',
    usu_id_admin    INT NULL COMMENT 'Admin que atendio el contacto',
    
    FOREIGN KEY (usu_id) REFERENCES usuarios(usu_id) ON DELETE SET NULL,
    FOREIGN KEY (ses_id) REFERENCES sesion_anonima(ses_id) ON DELETE SET NULL,
    FOREIGN KEY (per_id) REFERENCES personalizacion(per_id) ON DELETE SET NULL,
    FOREIGN KEY (usu_id_admin) REFERENCES usuarios(usu_id) ON DELETE SET NULL,
    
    INDEX idx_usuario (usu_id),
    INDEX idx_sesion (ses_id),
    INDEX idx_estado (con_estado),
    INDEX idx_fecha (con_fecha_envio)
) COMMENT='Formularios de contacto y consultas de clientes';


-- =============================
-- 3. GESTION DE PEDIDOS
-- =============================

CREATE TABLE estado_pedido(
    est_id          INT PRIMARY KEY AUTO_INCREMENT,
    est_nombre      VARCHAR(100) NOT NULL UNIQUE,
    est_descripcion VARCHAR(200)
) COMMENT='Estados del ciclo de vida de un pedido';

CREATE TABLE pedido (
    ped_id              INT PRIMARY KEY AUTO_INCREMENT,
    ped_codigo          VARCHAR(100) NOT NULL UNIQUE,
    ped_fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ped_comentarios     VARCHAR(250),
    ped_identificador_cliente VARCHAR(150) NULL COMMENT 'Nombre/tel si no hay usuario registrado',
    
    est_id              INT COMMENT 'Estado actual del pedido',
    per_id              INT COMMENT 'Personalizacion asociada (si existe)',
    con_id              INT NULL COMMENT 'Contacto que origino el pedido',
    ses_id              INT NULL COMMENT 'Sesion anonima origen',
    usu_id_cliente      INT NULL COMMENT 'Usuario registrado que hizo el pedido',
    usu_id_empleado     INT COMMENT 'Diseñador/admin asignado',
    
    FOREIGN KEY (est_id) REFERENCES estado_pedido (est_id),
    FOREIGN KEY (per_id) REFERENCES personalizacion (per_id),
    FOREIGN KEY (con_id) REFERENCES contacto_formulario(con_id) ON DELETE SET NULL,
    FOREIGN KEY (ses_id) REFERENCES sesion_anonima (ses_id) ON DELETE SET NULL,
    FOREIGN KEY (usu_id_cliente) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    FOREIGN KEY (usu_id_empleado) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    
    INDEX idx_codigo (ped_codigo),
    INDEX idx_estado (est_id),
    INDEX idx_empleado (usu_id_empleado),
    INDEX idx_cliente (usu_id_cliente),
    INDEX idx_sesion (ses_id)
) COMMENT='Pedidos de produccion de joyas personalizadas';

CREATE TABLE historial_estado_pedido (
    his_id              INT PRIMARY KEY AUTO_INCREMENT,
    ped_id              INT NOT NULL,
    est_id              INT NOT NULL,
    his_fecha_cambio    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    his_comentarios     TEXT NULL,
    his_imagen          VARCHAR(250) NULL,
    usu_id_responsable  INT NULL,

    FOREIGN KEY (ped_id) REFERENCES pedido(ped_id) ON DELETE CASCADE,
    FOREIGN KEY (est_id) REFERENCES estado_pedido(est_id),
    FOREIGN KEY (usu_id_responsable) REFERENCES usuarios(usu_id) ON DELETE SET NULL,

    INDEX idx_pedido (ped_id),
    INDEX idx_fecha (his_fecha_cambio)
) COMMENT='Historial completo de cambios de estado';

CREATE TABLE foto_producto_final (
    fot_id              INT PRIMARY KEY AUTO_INCREMENT,
    fot_imagen_final    VARCHAR(250) NOT NULL,
    fot_fecha_subida    DATE,
    ped_id              INT,
    FOREIGN KEY (ped_id) REFERENCES pedido (ped_id) ON DELETE CASCADE
) COMMENT='Fotografias del producto terminado';

CREATE TABLE render_3d (
    ren_id              INT PRIMARY KEY AUTO_INCREMENT,
    ren_imagen          VARCHAR(100) NOT NULL,
    ren_fecha_dimension DATE,
    ped_id              INT,
    FOREIGN KEY (ped_id) REFERENCES pedido (ped_id) ON DELETE CASCADE
) COMMENT='Renders 3D para aprobacion de diseño';

-- =============================
-- VISTAS Y TRIGGERS
-- =============================

CREATE VIEW v_personalizaciones_completas AS
SELECT 
    p.per_id,
    p.per_fecha,
    cp.cat_nombre AS categoria, -- Nueva columna en la vista
    CASE 
        WHEN p.usu_id_cliente IS NOT NULL THEN u.usu_nombre
        WHEN p.ses_id IS NOT NULL THEN CONCAT('Anonimo-', SUBSTRING(sa.ses_token, 1, 8))
        ELSE 'Desconocido'
    END AS cliente_nombre,
    CASE 
        WHEN p.usu_id_cliente IS NOT NULL THEN u.usu_correo
        ELSE NULL
    END AS cliente_correo,
    CASE 
        WHEN p.usu_id_cliente IS NOT NULL THEN 'registrado'
        WHEN p.ses_id IS NOT NULL THEN 'anonimo'
        ELSE 'desconocido'
    END AS tipo_cliente,
    p.usu_id_cliente,
    p.ses_id,
    sa.ses_convertido,
    sa.usu_id_convertido
FROM personalizacion p
LEFT JOIN usuarios u ON p.usu_id_cliente = u.usu_id
LEFT JOIN sesion_anonima sa ON p.ses_id = sa.ses_id
LEFT JOIN categoria_producto cp ON p.cat_id = cp.cat_id;

DELIMITER //

CREATE TRIGGER trg_personalizacion_validar_origen_insert
BEFORE INSERT ON personalizacion
FOR EACH ROW
BEGIN
    IF (NEW.usu_id_cliente IS NULL AND NEW.ses_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: Debe especificar usu_id_cliente O ses_id';
    END IF;
    IF (NEW.usu_id_cliente IS NOT NULL AND NEW.ses_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No puede especificar AMBOS';
    END IF;
END//

CREATE TRIGGER trg_personalizacion_validar_origen_update
BEFORE UPDATE ON personalizacion
FOR EACH ROW
BEGIN
    IF (NEW.usu_id_cliente IS NULL AND NEW.ses_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: Debe especificar usu_id_cliente O ses_id';
    END IF;
    IF (NEW.usu_id_cliente IS NOT NULL AND NEW.ses_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: No puede especificar AMBOS';
    END IF;
END//

CREATE TRIGGER trg_sesion_anonima_before_insert
BEFORE INSERT ON sesion_anonima
FOR EACH ROW
BEGIN
    IF NEW.ses_fecha_expiracion IS NULL THEN
        SET NEW.ses_fecha_expiracion = DATE_ADD(NEW.ses_fecha_creacion, INTERVAL 30 DAY);
    END IF;
END//

CREATE TRIGGER trg_sesion_convertida_after_update
AFTER UPDATE ON sesion_anonima
FOR EACH ROW
BEGIN
    IF OLD.ses_convertido = FALSE AND NEW.ses_convertido = TRUE AND NEW.usu_id_convertido IS NOT NULL THEN
        UPDATE personalizacion SET usu_id_cliente = NEW.usu_id_convertido, ses_id = NULL WHERE ses_id = NEW.ses_id;
        UPDATE contacto_formulario SET usu_id = NEW.usu_id_convertido, ses_id = NULL WHERE ses_id = NEW.ses_id;
        UPDATE pedido SET usu_id_cliente = NEW.usu_id_convertido, ses_id = NULL WHERE ses_id = NEW.ses_id AND usu_id_cliente IS NULL;
    END IF;
END//

DELIMITER ;

-- ==================================
-- INSERCIONES DE PRUEBA (ACTUALIZADAS)
-- ==================================

INSERT INTO tipo_de_documento (tipdoc_nombre) VALUES ('Cedula de ciudadania'), ('Cedula de extranjeria'), ('Pasaporte');
INSERT INTO rol (rol_nombre) VALUES ('usuario'), ('administrador'), ('diseñador');

INSERT INTO usuarios (usu_nombre, usu_correo, usu_telefono, usu_password, usu_docnum, usu_origen, usu_activo, tipdoc_id, rol_id) VALUES 
('Usuario Invitado', 'guest@brisasgems.com', '0000000000', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 'GUEST-9999', 'admin', TRUE, 1, 1);

INSERT INTO usuarios (usu_nombre, usu_correo, usu_telefono, usu_password, rol_id, tipdoc_id, usu_activo, usu_origen, usu_docnum) VALUES
('Pedro Paramo', 'pedro@brisas.com', '3001000001', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 1, 1, 'admin', '1000001'),
('Susana San Juan', 'susana.sanjuan@brisas.com', '3001000002', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 1, 1, 'admin', '1000002'),
('Juan Preciado', 'juanp@brisas.com', '3001000003', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 2, 1, 'admin', '1000003'),
('Bartolome San Juan', 'bartolome@brisas.com', '3001000010', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 2, 1, 'admin', '1000010'),
('Doña Doloritas', 'doloritas@brisas.com', '3001000004', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000004'),
('Miguel Paramo', 'miguel@brisas.com', '3001000005', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 2, 0, 'admin', '1000005'),
('Eduviges Dyada', 'eduviges@brisas.com', '3001000006', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000006'),
('Padre Renteria', 'rent@brisas.com', '3001000011', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000011'),
('Abundio', 'abundio@brisas.com', '3001000007', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 2, 1, 'registro', '1000007'),
('Fulgor Sedano', 'fulgor@brisas.com', '3001000008', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 1, 1, 'registro', '1000008'),
('Damiana Cisneros', 'cisneros@brisas.com', '3001000009', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 2, 1, 'registro', '1000009'),
('Dorotea', 'doro@brisas.com', '3001000012', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 1, 1, 'registro', '1000012');

INSERT INTO sesion_anonima (ses_token, ses_fecha_creacion, ses_fecha_expiracion, ses_convertido, usu_id_convertido) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', '2024-12-01 10:00:00', '2025-01-01 10:00:00', FALSE, NULL),
('b2c3d4e5-f6g7-8901-bcde-f12345678901', '2024-11-15 14:30:00', '2024-12-15 14:30:00', TRUE, 9),
('c3d4e5f6-g7h8-9012-cdef-012345678902', '2024-10-01 08:00:00', '2024-11-01 08:00:00', FALSE, NULL),
('d4e5f6g7-h8i9-0123-def0-123456789013', '2024-12-05 16:45:00', '2025-01-05 16:45:00', FALSE, NULL);

-- =============================
-- 2.1 INSERCION DE CATEGORIAS (NUEVO)
-- =============================
INSERT INTO categoria_producto (cat_nombre, cat_slug) VALUES
('Anillos', 'anillos'),
('Pulseras', 'pulseras');

-- =============================
-- 2.2 INSERCION DE OPCIONES (CON CAT_ID=1 para Anillos)
-- =============================
INSERT INTO opcion_personalizacion (opc_nombre, cat_id) VALUES 
('Forma de la gema', 1),
('Gema central', 1),
('Material', 1),
('Tamaño de la gema', 1),
('Talla del anillo', 1);

INSERT INTO valor_personalizacion (val_nombre, opc_id) VALUES
('Redonda', 1), ('Ovalada', 1),
('Diamante', 2), ('Esmeralda', 2), ('Zafiro', 2), ('Rubi', 2),
('Oro Amarillo', 3), ('Oro Blanco', 3), ('Oro Rosa', 3),
('7 mm', 4), ('8 mm', 4),
('Talla 4', 5), ('Talla 4.5', 5), ('Talla 5', 5), ('Talla 5.5', 5), ('Talla 6', 5);

-- =============================
-- 2.3 PERSONALIZACIONES (CON CAT_ID=1)
-- =============================
INSERT INTO personalizacion (per_fecha, usu_id_cliente, ses_id, cat_id) VALUES
('2023-10-15', 9, NULL, 1),
('2023-11-20', 10, NULL, 1),
('2024-01-05', 11, NULL, 1),
('2024-12-01', NULL, 1, 1),
('2024-11-15', NULL, 2, 1),
('2024-12-05', NULL, 4, 1);

INSERT INTO detalle_personalizacion (per_id, val_id) VALUES
(1, 1), (1, 3), (1, 7), (1, 11), (1, 13),
(2, 2), (2, 4), (2, 8), (2, 12), (2, 16),
(3, 1), (3, 5), (3, 9), (3, 11),
(4, 2), (4, 6), (4, 7), (4, 12),
(5, 1), (5, 4), (5, 8), (5, 11), (5, 15),
(6, 2), (6, 3), (6, 9), (6, 12);

-- =============================
-- RESTO DE INSERCIONES
-- =============================

INSERT INTO estado_pedido (est_nombre, est_descripcion) VALUES
('cotizacion_pendiente', 'Solicitud recibida, preparando cotizacion'),
('pago_diseno_pendiente', 'Diseño aprobado, esperando pago'),
('diseno_en_proceso', 'Creando modelo 3D y planos'),
('diseno_aprobado', 'Cliente aprobo diseño, inicia produccion'),
('tallado', 'Fundicion y moldeado de metal'),
('engaste', 'Fijando gemas a la montura'),
('pulido', 'Acabados finales y pulido'),
('inspeccion_calidad', 'Revision de estandares'),
('finalizado', 'Joya terminada, lista para entrega'),
('cancelado', 'Pedido cancelado');

INSERT INTO pedido (ped_codigo, ped_fecha_creacion, ped_comentarios, est_id, per_id, usu_id_empleado, usu_id_cliente, ses_id, con_id, ped_identificador_cliente) VALUES
('P-202401-A01', '2024-01-20 11:15:00', 'Cliente Abundio. Anillo esmeralda.', 1, 1, 6, 9, NULL, NULL, NULL),
('P-202401-A02', '2024-01-21 09:30:00', 'Cliente Fulgor. Collar oro blanco.', 1, 2, 7, 10, NULL, NULL, NULL),
('P-202402-B03', '2024-02-01 15:45:00', 'Damiana, esperando pago anticipo.', 2, 3, 8, 11, NULL, NULL, NULL),
('P-202411-ANON01', '2024-11-16 10:00:00', 'Sesion anonima -> Abundio.', 3, 5, 6, 9, 2, NULL, NULL),
('P-202412-WA01', '2024-12-03 14:30:00', 'WhatsApp - Anillo compromiso.', 1, NULL, 7, NULL, NULL, NULL, 'Laura Martinez - 3101234567'),
('P-202412-WA02', '2024-12-06 09:15:00', 'Llamada - Collar perlas.', 2, NULL, 8, NULL, NULL, NULL, 'Carlos Ruiz - 3209876543');

INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, usu_id_responsable) VALUES
(1, 1, '2024-01-20 11:15:00', 'Pedido creado automáticamente desde formulario de contacto.', 2),
(1, 2, '2024-01-22 10:00:00', 'Cliente confirmó cotización, esperando primer pago.', 3),
(3, 1, '2024-02-01 15:45:00', 'Ingreso manual por admin Bartolome.', 5),
(3, 2, '2024-02-02 11:30:00', 'Aprobado y esperando anticipo de diseño.', 5),
(3, 3, '2024-02-05 09:00:00', 'Anticipo recibido. Asignado a Diseñador Miguel. Se inicia 3D.', 6),
(4, 1, '2024-11-16 10:00:00', 'Origen: Sesión anónima #2.', 2),
(4, 3, '2024-11-17 14:00:00', 'Cliente Abundio (convertido) contactó. Diseño en proceso.', 2);

INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, his_imagen, usu_id_responsable) VALUES
(4, 5, '2024-12-01 09:00:00', 'Tallado inicial completado.', 'files/produccion/P-202411-ANON01-tallado.jpg', 6);

INSERT INTO contacto_formulario (usu_id, ses_id, con_nombre, con_correo, con_telefono, con_mensaje, con_via, con_terminos, con_estado, per_id, usu_id_admin, con_notas) VALUES
(9, NULL, 'Abundio', 'abundio@brisas.com', '3001000007', '¿Podrían enviarme la cotización...', 'formulario', TRUE, 'pendiente', 1, NULL, 'Seguimiento de P-202401-A01'),
(11, NULL, 'Damiana Cisneros', 'cisneros@brisas.com', '3001000009', 'Necesito cambiar la talla...', 'formulario', TRUE, 'pendiente', 3, NULL, NULL),
(10, NULL, 'Fulgor Sedano', 'fulgor@brisas.com', '3001000008', 'Quisiera saber si tienen zafiros...', 'formulario', TRUE, 'pendiente', NULL, NULL, NULL),
(4, NULL, 'Juan Preciado', 'juanp@brisas.com', '3001000003', 'Busco información sobre los horarios...', 'whatsapp', TRUE, 'pendiente', NULL, NULL, 'Cliente frecuente'),
(NULL, 1, 'Cliente Anonimo', 'anonimo1@gmail.com', '3105551234', 'Quiero cotización...', 'formulario', TRUE, 'pendiente', 4, NULL, 'Viene del personalizador.'),
(NULL, 4, 'Visitante Web', 'visitante@gmail.com', '3105559876', '¿Es posible hacer este diseño...', 'formulario', TRUE, 'pendiente', 6, NULL, NULL),
(NULL, NULL, 'Refugio', 'refugio@mail.com', '3209876543', 'No puedo acceder a mi cuenta...', 'whatsapp', TRUE, 'pendiente', NULL, NULL, NULL),
(NULL, NULL, 'Cliente Interesado', 'interesado@email.com', '3105554433', 'Información sobre anillos...', 'whatsapp', TRUE, 'pendiente', NULL, NULL, NULL);

UPDATE pedido SET con_id = 6 WHERE ped_codigo = 'P-202412-WA01';