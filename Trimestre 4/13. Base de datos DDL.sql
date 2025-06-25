-- ==================================
-- CREACIÓN DE BASE DE DATOS Y TABLAS
-- ==================================

drop database if exists brisas_gems;
create database brisas_gems;
use brisas_gems;

-- =============================
-- 1. SISTEMA Y USUARIOS
-- =============================

-- Tipos de documento
create table tipo_de_documento(
	tipdoc_id 		int primary key auto_increment,
	tipdoc_nombre 	varchar(100) not null
);

-- Roles de usuario
create table rol(
	rol_id 		int primary key auto_increment,
	rol_nombre 	varchar(50) not null
);

-- Usuarios 
create table usuarios (
	usu_id 			int primary key auto_increment,
	usu_nombre 		varchar(150) not null,
	usu_correo 		varchar(100) not null unique,
	usu_telefono 	varchar(20),
	usu_password 	varchar(255) not null,
    usu_docnum		varchar(20),
	rol_id 			int,
	tipdoc_id 		int,
    usu_activo      boolean not null default 0,
	foreign key (tipdoc_id) references tipo_de_documento (tipdoc_id),
	foreign key (rol_id) references rol (rol_id)
);

--  Token de activacion y recuperacion 
create table tokens (
    tok_id             int primary key auto_increment,
    token              varchar(255) not null,
    tipo               enum('activacion', 'recuperacion') not null default 'recuperacion', -- NUEVO
    fecha_expiracion   datetime not null,
    usu_id             int,
    foreign key (usu_id) references usuarios (usu_id)
);


-- =============================
-- 2. PERSONALIZACIÓN DE PRODUCTOS
-- =============================

-- Opciones de personalización (ej. Gema, Forma, Metal, Tamaño de piedra, Talla del anillo)
create table opcion_personalizacion (
	opc_id 		int primary key auto_increment,
	opc_nombre 	varchar(100) not null
);

-- Valores posibles para cada opción (ej. Rubí, Esmeralda, Redonda, Ovalada, Oro, Plata, etc.)
create table valor_personalizacion (
	val_id 		int primary key auto_increment,
    val_nombre 	varchar(100) not null,
    val_imagen 	varchar(250),
    opc_id 		int,
    foreign key (opc_id) references opcion_personalizacion (opc_id)
);

-- Personalizaciones realizadas por un cliente
create table personalizacion (
	per_id 			int primary key auto_increment,
    per_fecha 		date not null,
    usu_id_cliente 	int,
    foreign key (usu_id_cliente) references usuarios (usu_id)
);

-- Detalles de personalización seleccionados por el cliente
create table detalle_personalizacion (
	det_id 	int primary key auto_increment,
    per_id 	int,
    val_id 	int,
    foreign key (per_id) references personalizacion (per_id),
    foreign key (val_id) references valor_personalizacion (val_id)
);


-- =============================
-- 3. GESTIÓN DE PEDIDOS
-- =============================

-- Estados del pedido (ej. En diseño, En producción, Finalizado, etc.)
create table estado_pedido(
	est_id 		int primary key auto_increment,
	est_nombre 	varchar(100) not null
);

-- Pedidos asociados a una personalización
create table pedido (
	ped_id 				int primary key auto_increment,
    ped_codigo 			varchar(100) not null,
    ped_fecha_creacion 	date not null,
    ped_comentarios 	varchar(250),
    est_id 				int,
    per_id 				int,
    usu_id_empleado 	int,
    foreign key (est_id) references estado_pedido (est_id),
    foreign key (per_id) references personalizacion (per_id),
    foreign key (usu_id_empleado) references usuarios (usu_id)
);

-- Imagen final del producto terminado
create table foto_producto_final (
	fot_id 				int primary key auto_increment,
    fot_imagen_final 	varchar(250) not null,
    fot_fecha_subida 	date,
    ped_id 				int,
    foreign key (ped_id) references pedido (ped_id)
);

-- Render 3D del diseño personalizado
create table render_3d (
	ren_id 				int primary key auto_increment,
	ren_imagen 			varchar(100) not null,
	ren_fecha_aprobacion date,
	ped_id 				int,
	foreign key (ped_id) references pedido (ped_id)
);

-- =============================
-- 4. EXPERIENCIA DEL CLIENTE
-- =============================

-- Contacto por formulario o WhatsApp
create table contacto_formulario (
    con_id          int primary key auto_increment,
    usu_id          int null,
    con_nombre      varchar(150) not null,
    con_email       varchar(100),
    con_telefono    varchar(30),
    con_mensaje     text not null,
    con_fecha_envio datetime not null default current_timestamp,
    con_via         enum('formulario', 'whatsapp') default 'formulario',
    con_terminos    boolean not null,
    foreign key (usu_id) references usuarios(usu_id) on delete set null
);

create table portafolio_inspiracion (
    por_id           int primary key auto_increment,
    por_titulo       varchar(150) not null,
    por_descripcion  text,
    por_imagen       varchar(250) not null,
    por_video        varchar(250),
    por_categoria    varchar(100),
    por_fecha        datetime default current_timestamp,
    usu_id           int,
    foreign key 	 (usu_id) references usuarios(usu_id) on delete set null
);
