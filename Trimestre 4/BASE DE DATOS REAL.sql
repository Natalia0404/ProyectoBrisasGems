-- ==================================
-- CREACION DE BASE DE DATOS Y TABLAS
-- VERSION 2.0 - CON SOPORTE PARA SESIONES ANONIMAS
-- Compatible con MySQL 5.7+ y MariaDB 10.2+
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

CREATE TABLE opcion_personalizacion (
    opc_id      INT PRIMARY KEY AUTO_INCREMENT,
    opc_nombre  VARCHAR(100) NOT NULL UNIQUE
) COMMENT='Categorias de personalizacion (forma, gema, material, etc.)';

CREATE TABLE valor_personalizacion (
    val_id      INT PRIMARY KEY AUTO_INCREMENT,
    val_nombre  VARCHAR(100) NOT NULL,
    val_imagen  VARCHAR(250),
    opc_id      INT,
    FOREIGN KEY (opc_id) REFERENCES opcion_personalizacion (opc_id) ON DELETE CASCADE
) COMMENT='Valores especificos para cada opcion de personalizacion';

CREATE TABLE personalizacion (
    per_id          INT PRIMARY KEY AUTO_INCREMENT,
    per_fecha       DATE NOT NULL,
    
    -- CAMBIO: Ahora soporta usuarios autenticados O sesiones anonimas
    usu_id_cliente  INT NULL COMMENT 'Usuario registrado (si esta logueado)',
    ses_id          INT NULL COMMENT 'Sesion anonima (si NO esta logueado)',
    
    -- VALIDACION: Se hace con TRIGGER (ver seccion de triggers)
    
    FOREIGN KEY (usu_id_cliente) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    FOREIGN KEY (ses_id) REFERENCES sesion_anonima (ses_id) ON DELETE SET NULL,
    
    INDEX idx_usuario (usu_id_cliente),
    INDEX idx_sesion (ses_id)
) COMMENT='Configuraciones de joyas personalizadas (anonimas o de usuarios)';

CREATE TABLE detalle_personalizacion (
    det_id  INT PRIMARY KEY AUTO_INCREMENT,
    per_id  INT,
    val_id  INT,
    FOREIGN KEY (per_id) REFERENCES personalizacion (per_id) ON DELETE CASCADE,
    FOREIGN KEY (val_id) REFERENCES valor_personalizacion (val_id)
) COMMENT='Detalle de opciones elegidas en cada personalizacion';


-- =============================
-- 4. EXPERIENCIA DEL CLIENTE
-- =============================

CREATE TABLE contacto_formulario (
    con_id          INT PRIMARY KEY AUTO_INCREMENT,
    
    -- CAMBIO: Ahora tambien soporta sesiones anonimas
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
    
    -- NUEVO: Vincular personalizacion previa (si existe)
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


CREATE TABLE portafolio_inspiracion (
    por_id           INT PRIMARY KEY AUTO_INCREMENT,
    por_titulo       VARCHAR(150) NOT NULL,
    por_descripcion  TEXT,
    por_imagen       VARCHAR(250) NOT NULL,
    por_video        VARCHAR(250),
    por_categoria    VARCHAR(100),
    por_fecha        DATETIME DEFAULT CURRENT_TIMESTAMP,
    usu_id           INT COMMENT 'Diseñador que subio el diseño',
    FOREIGN KEY      (usu_id) REFERENCES usuarios(usu_id) ON DELETE SET NULL
) COMMENT='Galeria de inspiracion y diseños previos';


-- =============================
-- 3. GESTION DE PEDIDOS
-- =============================

CREATE TABLE estado_pedido(
    est_id          INT PRIMARY KEY AUTO_INCREMENT,
    est_nombre      VARCHAR(100) NOT NULL UNIQUE,
    est_descripcion VARCHAR(200)
) COMMENT='Estados del ciclo de vida de un pedido';


-- TABLA CORREGIDA FINAL (Solo ajuste de nombre de índice)
CREATE TABLE pedido (
    ped_id              INT PRIMARY KEY AUTO_INCREMENT,
    ped_codigo          VARCHAR(100) NOT NULL UNIQUE,
    ped_fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ped_comentarios     VARCHAR(250),
    ped_identificador_cliente VARCHAR(150) NULL COMMENT 'Nombre/tel si no hay usuario registrado',
    
    -- Relaciones
    est_id              INT COMMENT 'Estado actual del pedido',
    per_id              INT COMMENT 'Personalizacion asociada (si existe)',
    con_id              INT NULL COMMENT 'Contacto que origino el pedido (si aplica)',
    ses_id              INT NULL COMMENT 'Sesion anonima origen (si aplica)',
    usu_id_cliente      INT NULL COMMENT 'Usuario registrado que hizo el pedido',
    usu_id_empleado     INT COMMENT 'Diseñador/admin asignado',
    
    -- Foreign Keys
    FOREIGN KEY (est_id) REFERENCES estado_pedido (est_id),
    FOREIGN KEY (per_id) REFERENCES personalizacion (per_id),
    FOREIGN KEY (con_id) REFERENCES contacto_formulario(con_id) ON DELETE SET NULL,
    FOREIGN KEY (ses_id) REFERENCES sesion_anonima (ses_id) ON DELETE SET NULL,
    FOREIGN KEY (usu_id_cliente) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    FOREIGN KEY (usu_id_empleado) REFERENCES usuarios (usu_id) ON DELETE SET NULL,
    
    -- Índices
    INDEX idx_codigo (ped_codigo),
    INDEX idx_estado (est_id),
    INDEX idx_empleado (usu_id_empleado),
    INDEX idx_cliente (usu_id_cliente),
    INDEX idx_sesion (ses_id)
) COMMENT='Pedidos de produccion de joyas personalizadas';

-- TABLA AÑADIDA: Historial completo de cambios de estado
CREATE TABLE historial_estado_pedido (
    his_id              INT PRIMARY KEY AUTO_INCREMENT,
    ped_id              INT NOT NULL,
    est_id              INT NOT NULL,
    his_fecha_cambio    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    his_comentarios     TEXT NULL COMMENT 'Comentarios sobre el cambio de estado',
    his_imagen          VARCHAR(250) NULL COMMENT 'Ruta a imagen o archivo opcional que justifica el estado (ej: foto de produccion)',
    usu_id_responsable  INT NULL COMMENT 'Admin/Diseñador que realizo el cambio',

    -- Foreign Keys
    FOREIGN KEY (ped_id) REFERENCES pedido(ped_id) ON DELETE CASCADE,
    FOREIGN KEY (est_id) REFERENCES estado_pedido(est_id),
    FOREIGN KEY (usu_id_responsable) REFERENCES usuarios(usu_id) ON DELETE SET NULL,

    -- Índices
    INDEX idx_pedido (ped_id),
    INDEX idx_fecha (his_fecha_cambio)
) COMMENT='Historial completo de cambios de estado de pedidos para auditoría y timeline.';

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
    ren_fecha_aprobacion DATE,
    ped_id              INT,
    FOREIGN KEY (ped_id) REFERENCES pedido (ped_id) ON DELETE CASCADE
) COMMENT='Renders 3D para aprobacion de diseño';


-- =============================
-- VISTAS UTILES
-- =============================

-- Vista para obtener informacion completa de personalizaciones
CREATE VIEW v_personalizaciones_completas AS
SELECT 
    p.per_id,
    p.per_fecha,
    
    -- Informacion del cliente (registrado o anonimo)
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
    
    -- IDs para joins posteriores
    p.usu_id_cliente,
    p.ses_id,
    sa.ses_convertido,
    sa.usu_id_convertido
    
FROM personalizacion p
LEFT JOIN usuarios u ON p.usu_id_cliente = u.usu_id
LEFT JOIN sesion_anonima sa ON p.ses_id = sa.ses_id;

-- =============================
-- TRIGGERS DE VALIDACION
-- =============================

DELIMITER //

-- Trigger: Validar que personalizacion tenga usu_id_cliente O ses_id (INSERT)
CREATE TRIGGER trg_personalizacion_validar_origen_insert
BEFORE INSERT ON personalizacion
FOR EACH ROW
BEGIN
    -- Validar que EXACTAMENTE uno de los dos este presente
    IF (NEW.usu_id_cliente IS NULL AND NEW.ses_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Debe especificar usu_id_cliente O ses_id, no pueden estar ambos vacios';
    END IF;
    
    IF (NEW.usu_id_cliente IS NOT NULL AND NEW.ses_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puede especificar AMBOS usu_id_cliente Y ses_id, solo uno';
    END IF;
END//

-- Trigger: Validar que personalizacion tenga usu_id_cliente O ses_id (UPDATE)
CREATE TRIGGER trg_personalizacion_validar_origen_update
BEFORE UPDATE ON personalizacion
FOR EACH ROW
BEGIN
    -- Validar que EXACTAMENTE uno de los dos este presente
    IF (NEW.usu_id_cliente IS NULL AND NEW.ses_id IS NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Debe especificar usu_id_cliente O ses_id, no pueden estar ambos vacios';
    END IF;
    
    IF (NEW.usu_id_cliente IS NOT NULL AND NEW.ses_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: No puede especificar AMBOS usu_id_cliente Y ses_id, solo uno';
    END IF;
END//

-- Trigger: Validar expiracion de sesiones antes de insert
CREATE TRIGGER trg_sesion_anonima_before_insert
BEFORE INSERT ON sesion_anonima
FOR EACH ROW
BEGIN
    -- Si no se especifica fecha de expiracion, calcular automaticamente (+30 dias)
    IF NEW.ses_fecha_expiracion IS NULL THEN
        SET NEW.ses_fecha_expiracion = DATE_ADD(NEW.ses_fecha_creacion, INTERVAL 30 DAY);
    END IF;
END//

-- Trigger: Cuando se convierte una sesion, actualizar personalizaciones
CREATE TRIGGER trg_sesion_convertida_after_update
AFTER UPDATE ON sesion_anonima
FOR EACH ROW
BEGIN
    -- Si cambio de NO convertido a SI convertido
    IF OLD.ses_convertido = FALSE AND NEW.ses_convertido = TRUE AND NEW.usu_id_convertido IS NOT NULL THEN
        
        -- Actualizar personalizaciones vinculadas a esta sesion
        UPDATE personalizacion 
        SET usu_id_cliente = NEW.usu_id_convertido,
            ses_id = NULL  -- Ya no es anonima
        WHERE ses_id = NEW.ses_id;
        
        -- Actualizar contactos vinculados a esta sesion
        UPDATE contacto_formulario
        SET usu_id = NEW.usu_id_convertido,
            ses_id = NULL  -- Ya no es anonima
        WHERE ses_id = NEW.ses_id;
        
        UPDATE pedido
		SET usu_id_cliente = NEW.usu_id_convertido,
			ses_id = NULL
		WHERE ses_id = NEW.ses_id AND usu_id_cliente IS NULL;
    END IF;
END//

DELIMITER ;

-- ==================================
-- INSERCIONES DE PRUEBA
-- ==================================

-- =============================
-- 1. SISTEMA Y USUARIOS
-- =============================

INSERT INTO tipo_de_documento (tipdoc_nombre) VALUES
('Cedula de ciudadania'),
('Cedula de extranjeria'),
('Pasaporte');

INSERT INTO rol (rol_nombre) VALUES
('usuario'),
('administrador'),
('diseñador');

-- Usuario "Guest" para compatibilidad (opcional)
INSERT INTO usuarios (
    usu_nombre,
    usu_correo,
    usu_telefono,
    usu_password,
    usu_docnum,
    usu_origen,
    usu_activo,
    tipdoc_id,
    rol_id
) VALUES (
    'Usuario Invitado',
    'guest@brisasgems.com',
    '0000000000',
    '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa',
    'GUEST-9999',
    'admin',
    TRUE,
    1,
    1
);

-- Usuarios del sistema (contraseña: 12345678)
INSERT INTO usuarios (usu_nombre, usu_correo, usu_telefono, usu_password, rol_id, tipdoc_id, usu_activo, usu_origen, usu_docnum) VALUES
-- Administradores
('Pedro Paramo', 'pedro@brisas.com', '3001000001', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 1, 1, 'admin', '1000001'),
('Susana San Juan', 'susana.sanjuan@brisas.com', '3001000002', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 1, 1, 'admin', '1000002'),
('Juan Preciado', 'juanp@brisas.com', '3001000003', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 2, 1, 'admin', '1000003'),
('Bartolome San Juan', 'bartolome@brisas.com', '3001000010', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 2, 2, 1, 'admin', '1000010'),

-- Diseñadores
('Doña Doloritas', 'doloritas@brisas.com', '3001000004', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000004'),
('Miguel Paramo', 'miguel@brisas.com', '3001000005', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 2, 0, 'admin', '1000005'),
('Eduviges Dyada', 'eduviges@brisas.com', '3001000006', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000006'),
('Padre Renteria', 'rent@brisas.com', '3001000011', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 3, 1, 1, 'admin', '1000011'),

-- Clientes
('Abundio', 'abundio@brisas.com', '3001000007', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 2, 1, 'registro', '1000007'),
('Fulgor Sedano', 'fulgor@brisas.com', '3001000008', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 1, 1, 'registro', '1000008'),
('Damiana Cisneros', 'cisneros@brisas.com', '3001000009', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 2, 1, 'registro', '1000009'),
('Dorotea', 'doro@brisas.com', '3001000012', '$2a$12$wyNXiyvtu/w.HPklG0r2XuLr5cueIyr/fOy/gQu4EL0oGt4eCDgYa', 1, 1, 1, 'registro', '1000012');

-- =============================
-- SESIONES ANONIMAS DE PRUEBA
-- =============================

INSERT INTO sesion_anonima (ses_token, ses_fecha_creacion, ses_fecha_expiracion, ses_convertido, usu_id_convertido) VALUES
-- Sesion 1: Usuario anonimo ACTIVO (no se ha registrado)
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', '2024-12-01 10:00:00', '2025-01-01 10:00:00', FALSE, NULL),

-- Sesion 2: Usuario CONVERTIDO (se registro como Abundio - usu_id = 9)
('b2c3d4e5-f6g7-8901-bcde-f12345678901', '2024-11-15 14:30:00', '2024-12-15 14:30:00', TRUE, 9),

-- Sesion 3: Sesion EXPIRADA y no convertida
('c3d4e5f6-g7h8-9012-cdef-012345678902', '2024-10-01 08:00:00', '2024-11-01 08:00:00', FALSE, NULL),

-- Sesion 4: Usuario que personalizo pero no contacto
('d4e5f6g7-h8i9-0123-def0-123456789013', '2024-12-05 16:45:00', '2025-01-05 16:45:00', FALSE, NULL);

-- =============================
-- 2. PERSONALIZACION DE PRODUCTOS
-- =============================

INSERT INTO opcion_personalizacion (opc_nombre) VALUES 
('Forma de la gema'),
('Gema central'),
('Material'),
('Tamaño de la gema'),
('Talla del anillo');

INSERT INTO valor_personalizacion (val_nombre, opc_id) VALUES
-- Forma
('Redonda', 1), ('Ovalada', 1),
-- Gema
('Diamante', 2), ('Esmeralda', 2), ('Zafiro', 2), ('Rubi', 2),
-- Material
('Oro Amarillo', 3), ('Oro Blanco', 3), ('Oro Rosa', 3),
-- Tamaño
('7 mm', 4), ('8 mm', 4),
-- Talla
('Talla 4', 5), ('Talla 4.5', 5), ('Talla 5', 5), ('Talla 5.5', 5), 
('Talla 6', 5), ('Talla 6.5', 5), ('Talla 7', 5), ('Talla 7.5', 5), 
('Talla 8', 5), ('Talla 8.5', 5), ('Talla 9', 5);

-- Personalizaciones (usuarios registrados + anonimos)
INSERT INTO personalizacion (per_fecha, usu_id_cliente, ses_id) VALUES
-- Usuarios registrados
('2023-10-15', 9, NULL),
('2023-11-20', 10, NULL),
('2024-01-05', 11, NULL),

-- Sesiones anonimas
('2024-12-01', NULL, 1),
('2024-11-15', NULL, 2),
('2024-12-05', NULL, 4);

-- Detalles de personalizacion
INSERT INTO detalle_personalizacion (per_id, val_id) VALUES
(1, 1), (1, 3), (1, 7), (1, 11), (1, 13),
(2, 2), (2, 4), (2, 8), (2, 12), (2, 16),
(3, 1), (3, 5), (3, 9), (3, 11), (3, 17),
(4, 2), (4, 6), (4, 7), (4, 12), (4, 19),
(5, 1), (5, 4), (5, 8), (5, 11), (5, 15),
(6, 2), (6, 3), (6, 9), (6, 12), (6, 18);

-- =============================
-- 3. GESTION DE PEDIDOS
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
-- Pedidos registrados (usu_id_cliente debe ser el ID del cliente)
('P-202401-A01', '2024-01-20 11:15:00', 'Cliente Abundio. Anillo esmeralda.', 1, 1, 6, 9, NULL, NULL, NULL),
('P-202401-A02', '2024-01-21 09:30:00', 'Cliente Fulgor. Collar oro blanco.', 1, 2, 7, 10, NULL, NULL, NULL),
('P-202402-B03', '2024-02-01 15:45:00', 'Damiana, esperando pago anticipo.', 2, 3, 8, 11, NULL, NULL, NULL),

-- Pedido de sesion convertida (Cliente: Abundio=9, Sesion: 2)
('P-202411-ANON01', '2024-11-16 10:00:00', 'Sesion anonima -> Abundio.', 3, 5, 6, 9, 2, NULL, NULL),

-- Pedidos externos (WhatsApp) (Cliente: NULL, Sesion: NULL)
('P-202412-WA01', '2024-12-03 14:30:00', 'WhatsApp - Anillo compromiso.', 1, NULL, 7, NULL, NULL, NULL, 'Laura Martinez - 3101234567'),
('P-202412-WA02', '2024-12-06 09:15:00', 'Llamada - Collar perlas.', 2, NULL, 8, NULL, NULL, NULL, 'Carlos Ruiz - 3209876543');

-- inserciones de prueba de historial
-- Pedido P-202401-A01 (ped_id 1): Abundio
INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, usu_id_responsable) VALUES
(1, 1, '2024-01-20 11:15:00', 'Pedido creado automáticamente desde formulario de contacto.', 2), -- Creado
(1, 2, '2024-01-22 10:00:00', 'Cliente confirmó cotización, esperando primer pago.', 3); -- Susana San Juan (Admin)

-- Pedido P-202402-B03 (ped_id 3): Damiana
INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, usu_id_responsable) VALUES
(3, 1, '2024-02-01 15:45:00', 'Ingreso manual por admin Bartolome.', 5),
(3, 2, '2024-02-02 11:30:00', 'Aprobado y esperando anticipo de diseño.', 5),
(3, 3, '2024-02-05 09:00:00', 'Anticipo recibido. Asignado a Diseñador Miguel. Se inicia 3D.', 6); -- Diseñador Miguel

-- Pedido P-202411-ANON01 (ped_id 4): Sesión convertida
INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, usu_id_responsable) VALUES
(4, 1, '2024-11-16 10:00:00', 'Origen: Sesión anónima #2.', 2),
(4, 3, '2024-11-17 14:00:00', 'Cliente Abundio (convertido) contactó. Diseño en proceso.', 2);

-- Simulación de un cambio con imagen (usando un placeholder)
INSERT INTO historial_estado_pedido (ped_id, est_id, his_fecha_cambio, his_comentarios, his_imagen, usu_id_responsable) VALUES
(4, 5, '2024-12-01 09:00:00', 'Tallado inicial completado.', 'files/produccion/P-202411-ANON01-tallado.jpg', 6);

-- =============================
-- 4. EXPERIENCIA DEL CLIENTE
-- =============================

INSERT INTO contacto_formulario (usu_id, ses_id, con_nombre, con_correo, con_telefono, con_mensaje, con_via, con_terminos, con_estado, per_id, usu_id_admin, con_notas) VALUES
-- 1. Usuarios Registrados CON Personalización
(9, NULL, 'Abundio', 'abundio@brisas.com', '3001000007', '¿Podrían enviarme la cotización de la joya que personalicé? [Redonda, Diamante, Oro Amarillo, 7mm, Talla 7]', 'formulario', TRUE, 'pendiente', 1, NULL, 'Seguimiento de P-202401-A01'),
(11, NULL, 'Damiana Cisneros', 'cisneros@brisas.com', '3001000009', 'Necesito cambiar la talla del anillo que diseñé (per_id 3) antes de que empiece la producción.', 'formulario', TRUE, 'pendiente', 3, NULL, NULL),

-- 2. Usuarios Registrados SIN Personalización
(10, NULL, 'Fulgor Sedano', 'fulgor@brisas.com', '3001000008', 'Quisiera saber si tienen zafiros azules en stock para un anillo de graduación.', 'formulario', TRUE, 'pendiente', NULL, NULL, NULL),
(4, NULL, 'Juan Preciado', 'juanp@brisas.com', '3001000003', 'Busco información sobre los horarios de la tienda física para recoger un encargo.', 'whatsapp', TRUE, 'pendiente', NULL, NULL, 'Cliente frecuente'),

-- 3. Anónimos CON Personalización (tienen ses_id)
(NULL, 1, 'Cliente Anonimo', 'anonimo1@gmail.com', '3105551234', 'Quiero cotización de este diseño. [Ovalada, Zafiro, Oro Amarillo, 8mm, Talla 8.5]', 'formulario', TRUE, 'pendiente', 4, NULL, 'Viene del personalizador.'),
(NULL, 4, 'Visitante Web', 'visitante@gmail.com', '3105559876', '¿Es posible hacer este diseño con platino en lugar de oro rosa? [Ovalada, Diamante, Oro Rosa, 8mm, Talla 6.5]', 'formulario', TRUE, 'pendiente', 6, NULL, NULL),

-- 4. Externos (sin usu_id ni ses_id - mensajes manuales por WhatsApp)
(NULL, NULL, 'Refugio', 'refugio@mail.com', '3209876543', 'No puedo acceder a mi cuenta, ¿cómo puedo recuperar mi contraseña?', 'whatsapp', TRUE, 'pendiente', NULL, NULL, NULL),
(NULL, NULL, 'Cliente Interesado', 'interesado@email.com', '3105554433', 'Información sobre anillos de compromiso y el proceso de diseño 3D.', 'whatsapp', TRUE, 'pendiente', NULL, NULL, NULL);

-- Actualizar pedidos con con_id
UPDATE pedido SET con_id = 6 WHERE ped_codigo = 'P-202412-WA01';

-- =============================
-- VERIFICACIONES FINALES
-- =============================

-- Ver personalizaciones con origen
SELECT 
    per_id,
    per_fecha,
    CASE 
        WHEN usu_id_cliente IS NOT NULL THEN CONCAT('Usuario #', usu_id_cliente)
        WHEN ses_id IS NOT NULL THEN CONCAT('Sesion #', ses_id)
        ELSE 'ERROR'
    END AS origen
FROM personalizacion;

-- Ver conversiones de sesiones
SELECT 
    sa.ses_id,
    SUBSTRING(sa.ses_token, 1, 20) AS token_preview,
    sa.ses_convertido,
    u.usu_nombre AS usuario_convertido,
    COUNT(DISTINCT p.per_id) AS personalizaciones,
    COUNT(DISTINCT c.con_id) AS contactos
FROM sesion_anonima sa
LEFT JOIN usuarios u ON sa.usu_id_convertido = u.usu_id
LEFT JOIN personalizacion p ON p.ses_id = sa.ses_id
LEFT JOIN contacto_formulario c ON c.ses_id = sa.ses_id
GROUP BY sa.ses_id;