-- ===========
-- INSERCIONES
-- ===========

-- tabla tipo_de_documento
insert into tipo_de_documento (tipdoc_nombre)
values
	('Cédula de ciudadanía'),
	('Cédula de extranjería'),
	('Pasaporte');

-- tabla rol
insert into rol (rol_nombre) 
values
	('usuario'),
	('administrador'),
	('diseñador');

-- tabla usuarios
insert into usuarios (usu_nombre, usu_correo, usu_telefono, usu_password, rol_id, tipdoc_id) 
values
	-- administradores
	('ana administrador',     'ana@gmail.com',            '3001000001', 'hash-ana001',     2, 1),
	('catalina lópez',        'catalina.admin@gmail.com', '3001000002', 'hash-catalina002', 2, 1),
	('jorge herrera',         'jorgeherrera@gmail.com',   '3001000003', 'hash-jorge003',    2, 2),

	-- diseñadores
	('soledad martínez',      'soledad@gmail.com',        '3001000004', 'hash-soledad004',  3, 1),
	('tomás agudelo',         'tomas@gmail.com',          '3001000005', 'hash-tomas005',    3, 2),
	('paula cárdenas',        'paula@gmail.com',          '3001000006', 'hash-paula006',    3, 1),

	-- clientes
	('valentina castro',      'valentinacastro@gmail.com','3001000007','hash-valentina007',1, 2),
	('santiago morales',      'santiagomorales@gmail.com','3001000008','hash-santiago008',1, 1),
	('laura sánchez',         'laurasanchez@gmail.com',   '3001000009','hash-laura009',    1, 2),
	('marcela fernández',     'marcelaf@gmail.com',       '3001000010','hash-marcela010',  1, 1),
	('felipe castro',         'felipecastro@gmail.com',   '3001000011','hash-felipe011',   1, 2),
	('daniela mendoza',       'danielamendoza@gmail.com', '3001000012','hash-daniela012',  1, 1),
	('alejandro rojas',       'alejandrorojas@gmail.com', '3001000013','hash-alejandro013',1, 2),
	('juliana álvarez',       'julianaalvarez@gmail.com', '3001000014','hash-juliana014',  1, 1),
	('sebastián díaz',        'sebastiandiaz@gmail.com',  '3001000015','hash-sebastian015',1, 2);
    
    select * from usuarios;

-- tabla tokens (versión sin tok_id manual)
insert into tokens (token, tipo, fecha_expiracion, usu_id) values
	('token-activo-ana',     'activacion',   '2025-07-01 23:59:59', 1),
	('token-recu-luis',      'recuperacion', '2025-06-30 23:59:59', 2),
	('token-recu-carla',     'recuperacion', '2025-06-30 23:59:59', 3),
	('token-activo-diego',   'activacion',   '2025-07-01 23:59:59', 4);


-- ===============================
-- 2. PERSONALIZACIÓN DE PRODUCTOS
-- ===============================

-- tabla opcion_personalizacion
insert into opcion_personalizacion (opc_nombre) 
values
	('seleccionar gema'),
	('seleccionar forma'),
	('seleccionar material del anillo'),
	('modificar tamaño de joya'),
	('seleccionar talla del anillo');

-- 5. tabla valor_personalizacion (sin val_id, con opc_id basado en el orden de inserción anterior)
insert into valor_personalizacion (val_nombre, opc_id) 
values
	-- opciones para “seleccionar gema” (opc_id = 1)
	('esmeralda',    1),
	('diamante',     1),
	('ruby',         1),

	-- opciones para “seleccionar forma” (opc_id = 2)
	('redonda',      2),
	('cuadrada',     2),
	('ovalada',      2),

	-- opciones para “seleccionar material del anillo” (opc_id = 3)
	('oro amarillo', 3),
	('oro blanco',   3),
	('plata',        3),
	('platino',      3),

	-- opciones para “modificar tamaño de joya” (opc_id = 4)
	('6 mm',         4),
	('7 mm',         4),
	('9 mm',         4),

	-- opciones para “seleccionar talla del anillo” (opc_id = 5)
	('talla 6',      5),
	('talla 7',      5),
	('talla 8',      5),
	('talla 9',      5);


-- tabla personalizacion (sin per_id, autoincremental)
insert into personalizacion (per_fecha, usu_id_cliente) 
values
	('2025-06-01', 1),
	('2025-06-02', 2),
	('2025-06-03', 3),
	('2025-06-04', 4),
	('2025-06-05', 5),
	('2025-06-06', 6),
	('2025-06-07', 7),
	('2025-06-08', 8),
	('2025-06-09', 9),
	('2025-06-10', 10),
	('2025-06-11', 11),
	('2025-06-12', 12),
	('2025-06-13', 13),
	('2025-06-14', 14),
	('2025-06-15', 15);


-- tabla detalle_personalizacion (cada per_id tiene 5 selecciones)
insert into detalle_personalizacion (det_id, per_id, val_id) 
values
	-- per_id = 1 (ana)
	(1,  1,  1),   -- gema: esmeralda
	(2,  1,  4),   -- forma: redonda
	(3,  1,  7),   -- material: oro amarillo
	(4,  1,  12),  -- tamaño: mediano
	(5,  1,  15),  -- talla anillo: talla 7

	-- per_id = 2 (luis)
	(6,  2,  2),   -- gema: diamante
	(7,  2,  5),   -- forma: cuadrada
	(8,  2,  8),   -- material: oro blanco
	(9,  2,  11),  -- tamaño: pequeño
	(10, 2,  14),  -- talla anillo: talla 6

	-- per_id = 3 (carla)
	(11, 3,  3),   -- gema: zafiro
	(12, 3,  6),   -- forma: ovalada
	(13, 3,  9),   -- material: plata
	(14, 3,  13),  -- tamaño: grande
	(15, 3,  16),  -- talla anillo: talla 8

	  -- per_id = 4 (diego)
	(16, 4,  1),   -- gema: esmeralda
	(17, 4,  5),   -- forma: cuadrada
	(18, 4,  10),  -- material: platino
	(19, 4,  11),  -- tamaño: pequeño
	(20, 4,  17),  -- talla anillo: talla 9

	  -- per_id = 5 (sofía)
	(21, 5,  2),   -- gema: diamante
	(22, 5,  4),   -- forma: redonda
	(23, 5,  7),   -- material: oro amarillo
	(24, 5,  13),  -- tamaño: grande
	(25, 5,  14),  -- talla anillo: talla 6

	  -- per_id = 6 (camilo)
	(26, 6,  3),   -- gema: zafiro
	(27, 6,  6),   -- forma: ovalada
	(28, 6,  8),   -- material: oro blanco
	(29, 6,  12),  -- tamaño: mediano
	(30, 6,  15),  -- talla anillo: talla 7

	  -- per_id = 7 (valentina)
	(31, 7,  1),   -- gema: esmeralda
	(32, 7,  4),   -- forma: redonda
	(33, 7,  10),  -- material: platino
	(34, 7,  11),  -- tamaño: pequeño
	(35, 7,  16),  -- talla anillo: talla 8

	  -- per_id = 8 (santiago)
	(36, 8,  2),   -- gema: diamante
	(37, 8,  5),   -- forma: cuadrada
	(38, 8,  9),   -- material: plata
	(39, 8,  13),  -- tamaño: grande
	(40, 8,  17),  -- talla anillo: talla 9

	-- per_id = 9 (laura)
	(41, 9,  3),   -- gema: zafiro
	(42, 9,  6),   -- forma: ovalada
	(43, 9,  7),   -- material: oro amarillo
	(44, 9,  12),  -- tamaño: mediano
	(45, 9,  14),  -- talla anillo: talla 6

	-- per_id = 10 (marcela)
	(46, 10, 1),   -- gema: esmeralda
	(47, 10, 5),   -- forma: cuadrada
	(48, 10, 8),   -- material: oro blanco
	(49, 10, 13),  -- tamaño: grande
	(50, 10, 15),  -- talla anillo: talla 7

	-- per_id = 11 (felipe)
	(51, 11, 2),   -- gema: diamante
	(52, 11, 4),   -- forma: redonda
	(53, 11, 9),   -- material: plata
	(54, 11, 11),  -- tamaño: pequeño
	(55, 11, 16),  -- talla anillo: talla 8

	-- per_id = 12 (daniela)
	(56, 12, 3),   -- gema: zafiro
	(57, 12, 5),   -- forma: cuadrada
	(58, 12, 10),  -- material: platino
	(59, 12, 12),  -- tamaño: mediano
	(60, 12, 17),  -- talla anillo: talla 9

	-- per_id = 13 (alejandro)
	(61, 13, 1),   -- gema: esmeralda
	(62, 13, 6),   -- forma: ovalada
	(63, 13, 7),   -- material: oro amarillo
	(64, 13, 13),  -- tamaño: grande
	(65, 13, 14),  -- talla anillo: talla 6

	-- per_id = 14 (juliana)
	(66, 14, 2),   -- gema: diamante
	(67, 14, 4),   -- forma: redonda
	(68, 14, 8),   -- material: oro blanco
	(69, 14, 11),  -- tamaño: pequeño
	(70, 14, 15),  -- talla anillo: talla 7

	-- per_id = 15 (sebastián)
	(71, 15, 3),   -- gema: zafiro
	(72, 15, 5),   -- forma: cuadrada
	(73, 15, 9),   -- material: plata
	(74, 15, 12),  -- tamaño: mediano
	(75, 15, 17);  -- talla anillo: talla 9

-- =============================
-- 3. GESTIÓN DE PEDIDOS
-- =============================

-- tabla estado_pedido
insert into estado_pedido (est_id, est_nombre)
values
	(1, 'diseño'),
	(2, 'tallado'),
	(3, 'engaste'),
	(4, 'pulido'),
	(5, 'finalizado');

-- tabla pedido 
insert into pedido (ped_id, ped_codigo, ped_fecha_creacion, ped_comentarios, est_id, per_id, usu_id_empleado) 
values
	(1,  'p-20250601-001', '2025-06-01', 'pedido de ana',            1,  1,  1),
	(2,  'p-20250602-002', '2025-06-02', 'pedido de luis',           2,  2,  2),
	(3,  'p-20250603-003', '2025-06-03', 'pedido de carla',          3,  3,  3),
	(4,  'p-20250604-004', '2025-06-04', 'pedido de diego',          4,  4,  4),
	(5,  'p-20250605-005', '2025-06-05', 'pedido de sofía',          5,  5,  5),
	(6,  'p-20250606-006', '2025-06-06', 'pedido de camilo',         1,  6,  6),
	(7,  'p-20250607-007', '2025-06-07', 'pedido de valentina',      2,  7,  7),
	(8,  'p-20250608-008', '2025-06-08', 'pedido de santiago',       3,  8,  8),
	(9,  'p-20250609-009', '2025-06-09', 'pedido de laura',          4,  9,  9),
	(10, 'p-20250610-010', '2025-06-10', 'pedido de marcela',        5, 10, 10),
	(11, 'p-20250611-011', '2025-06-11', 'pedido de felipe',         1, 11, 11),
	(12, 'p-20250612-012', '2025-06-12', 'pedido de daniela',        2, 12, 12),
	(13, 'p-20250613-013', '2025-06-13', 'pedido de alejandro',      3, 13, 13),
	(14, 'p-20250614-014', '2025-06-14', 'pedido de juliana',        4, 14, 14),
	(15, 'p-20250615-015', '2025-06-15', 'pedido de sebastián',       5, 15, 15);

-- tabla foto_producto_final
-- solo para pedidos cuyo estado NO es “diseño” (est_id > 1)
insert into foto_producto_final (fot_id, fot_imagen_final, fot_fecha_subida, ped_id) 
values
	(1,  'https://tienda.com/fotos/ped2.jpg',  '2025-06-03', 2),
	(2,  'https://tienda.com/fotos/ped3.jpg',  '2025-06-04', 3),
	(3,  'https://tienda.com/fotos/ped4.jpg',  '2025-06-05', 4),
	(4,  'https://tienda.com/fotos/ped5.jpg',  '2025-06-06', 5),
	(5,  'https://tienda.com/fotos/ped7.jpg',  '2025-06-08', 7),
	(6,  'https://tienda.com/fotos/ped8.jpg',  '2025-06-09', 8),
	(7,  'https://tienda.com/fotos/ped9.jpg',  '2025-06-10', 9),
	(8,  'https://tienda.com/fotos/ped10.jpg', '2025-06-11', 10),
	(9,  'https://tienda.com/fotos/ped12.jpg', '2025-06-13', 12),
	(10, 'https://tienda.com/fotos/ped13.jpg', '2025-06-14', 13),
	(11, 'https://tienda.com/fotos/ped14.jpg', '2025-06-15', 14),
	(12, 'https://tienda.com/fotos/ped15.jpg', '2025-06-16', 15);

-- tabla render_3d
-- similarmente, para los mismos pedidos (est_id > 1)
insert into render_3d (ren_id, ren_imagen, ren_fecha_aprobacion, ped_id) 
values
	(1,  'https://tienda.com/renders/ped2.png',  '2025-06-02', 2),
	(2,  'https://tienda.com/renders/ped3.png',  '2025-06-03', 3),
	(3,  'https://tienda.com/renders/ped4.png',  '2025-06-04', 4),
	(4,  'https://tienda.com/renders/ped5.png',  '2025-06-05', 5),
	(5,  'https://tienda.com/renders/ped7.png',  '2025-06-07', 7),
	(6,  'https://tienda.com/renders/ped8.png',  '2025-06-08', 8),
	(7,  'https://tienda.com/renders/ped9.png',  '2025-06-09', 9),
	(8,  'https://tienda.com/renders/ped10.png', '2025-06-10', 10),
	(9,  'https://tienda.com/renders/ped12.png', '2025-06-12', 12),
	(10, 'https://tienda.com/renders/ped13.png', '2025-06-13', 13),
	(11, 'https://tienda.com/renders/ped14.png', '2025-06-14', 14),
	(12, 'https://tienda.com/renders/ped15.png', '2025-06-15', 15);


-- =============================
-- 4. EXPERIENCIA DEL CLIENTE
-- =============================

-- tabla contacto Contactos con y sin usuarios asociados
insert into contacto_formulario (con_id, usu_id, con_nombre, con_email, con_telefono, con_mensaje, con_via, con_terminos)
values
(1, 2, 'Luis Pérez', 'luisperez@gmail.com', '3001000002', 'Estoy interesado en un diseño nuevo.', 'formulario', true),
(2, null, 'Carolina López', 'carolina@gmail.com', '3001234567', '¿Puedo personalizar una joya con una piedra propia?', 'whatsapp', true),
(3, 5, 'Sofía Rodríguez', 'sofiarodriguez@gmail.com', '3001000005', '¿Cuánto demora el proceso completo?', 'formulario', true),
(4, null, 'Mauricio Díaz', 'mauricio.d@gmail.com', '3109876543', 'Quiero una cita personalizada.', 'formulario', true);

-- Inspiraciones de diseño para el portafolio
insert into portafolio_inspiracion (por_id, por_titulo, por_descripcion, por_imagen, por_video, por_categoria, usu_id)
values
(1, 'Anillo Aurora', 'Inspirado en los colores del amanecer.', 'https://tienda.com/inspiracion/aurora.jpg', null, 'anillo', 1),
(2, 'Colgante Estelar', 'Diseño con diamantes en forma de estrella.', 'https://tienda.com/inspiracion/estelar.jpg', 'https://tienda.com/videos/estelar.mp4', 'colgante', 3),
(3, 'Sortija Real', 'Sortija clásica con rubí central.', 'https://tienda.com/inspiracion/sortija.jpg', null, 'anillo', 4),
(4, 'Anillo Personalizado', 'Basado en un diseño de cliente', 'https://tienda.com/inspiracion/personalizado.jpg', null, 'cliente', 2);
