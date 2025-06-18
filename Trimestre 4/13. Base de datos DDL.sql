-- ==================================
-- CREACION DE BASE DE DATOS Y TABLAS
-- ==================================
-- drop database brisas_gems;
create database brisas_gems;
use brisas_gems;

create table tipo_de_documento(
	tipdoc_id 		int primary key auto_increment,
	tipdoc_nombre 	varchar (100) not null
);

create table rol(
	rol_id 		int primary key auto_increment,
	rol_nombre 	varchar (100) not null
);

create table estado_pedido(
	est_id 		int primary key auto_increment,
	est_nombre 	varchar (100) not null
);

create table opcion_personalizacion (
	opc_id 		int primary key auto_increment,
	opc_nombre 	varchar (100) not null
);

create table usuarios (
	usu_id 			int primary key,
	usu_nombre 		varchar (150) not null,
	usu_correo 		varchar (100) not null unique ,
	usu_telefono 	varchar (20),
	usu_password 	varchar (255) not null,
	rol_id 			int,
	tipdoc_id 		int,
	foreign key (tipdoc_id) references tipo_de_documento (tipdoc_id),
	foreign key (rol_id) references rol (rol_id)
);

create table personalizacion (
	per_id 			int primary key auto_increment,
    per_fecha 		date not null,
    usu_id_cliente 	int,
    foreign key (usu_id_cliente) references usuarios (usu_id)
);

create table valor_personalizacion (
	val_id 		int primary key auto_increment,
    val_nombre 	varchar  (100) not null,
    opc_id 		int,
    foreign key (opc_id) references opcion_personalizacion (opc_id)
);

create table detalle_personalizacion (
	det_id 	int primary key auto_increment,
    per_id 	int,
    val_id 	int,
    foreign key (per_id) references personalizacion (per_id),
    foreign key (val_id) references valor_personalizacion (val_id)
);
    
create table pedido (
	ped_id 				int primary key auto_increment,
    ped_codigo 			varchar (100) not null,
    ped_fecha_creacion 	date not null,
    ped_comentarios 	varchar (250),
    est_id 				int,
    per_id 				int,
    usu_id_admin 		int,
    foreign key (est_id) references estado_pedido (est_id),
    foreign key (per_id) references personalizacion (per_id),
    foreign key (usu_id_admin) references usuarios (usu_id)
);
    
create table foto_producto_final (
	fot_id 				int primary key auto_increment,
    fot_imagen_final 	varchar (250) not null,
    fot_fecha_subida 	date,
    ped_id 				int,
    foreign key (ped_id) references pedido (ped_id)
);
    
create table render_3d (
ren_id 					int primary key auto_increment,
ren_imagen 				varchar (100) not null,
ren_fecha_aprobacion 	date,
ped_id 					int,
foreign key (ped_id) references pedido (ped_id)
);