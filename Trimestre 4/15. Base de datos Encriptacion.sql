-- ========================================
-- ANTES: Inserciones sin encriptación real
-- ========================================
insert into usuarios (usu_id, usu_nombre, usu_correo, usu_telefono, usu_password, rol_id, tipdoc_id) 
values
	(1,  'ana administrador', 'ana@gmail.com', '3001000001', 'hash-ana001', 1, 1),
	(2,  'luis pérez','luisperez@gmail.com',   '3001000002', 'hash-luis002', 2, 1),
	(3,  'carla gómez','carlagomez@gmail.com',  '3001000003', 'hash-carla003', 2, 2),
	(4,  'diego torres', 'diegotorres@gmail.com', '3001000004', 'hash-diego004', 2, 1),
	(5,  'sofía rodríguez', 'sofiarodriguez@gmail.com','3001000005','hash-sofia005',  2, 2),
	(6,  'camilo díaz', 'camilodiaz@gmail.com',  '3001000006', 'hash-camilo006', 2, 1),
	(7,  'valentina castro', 'valentinacastro@gmail.com','3001000007','hash-valentina007',2, 2),
	(8,  'santiago morales', 'santiagomorales@gmail.com','3001000008','hash-santiago008',2, 1),
	(9,  'laura sánchez', 'laurasanchez@gmail.com','3001000009', 'hash-laura009', 2, 2),
	(10, 'marcela fernández', 'marcelaf@gmail.com',    '3001000010', 'hash-marcela010', 2, 1),
	(11, 'felipe castro', 'felipecastro@gmail.com','3001000011', 'hash-felipe011', 2, 2),
	(12, 'daniela mendoza', 'danielamendoza@gmail.com','3001000012','hash-daniela012',  2, 1),
	(13, 'alejandro rojas', 'alejandrorojas@gmail.com','3001000013','hash-alejandro013',2, 2),
	(14, 'juliana álvarez', 'julianaalvarez@gmail.com','3001000014','hash-juliana014', 2, 1),
	(15, 'sebastián díaz', 'sebastiandiaz@gmail.com','3001000015','hash-sebastian015',2, 2);

select * from usuarios;
SET SQL_SAFE_UPDATES = 0; -- !!Esto desactiva el modo seguro en esta sesión !!
delete from usuarios;

-- se usa la funcion substring para aplicar sha2 solo desde el caracter 6 
update usuarios
set usu_password = SHA2(SUBSTRING(usu_password, 6), 256)
where usu_password like 'hash-%';


-- esto tendria sentido solo sin prefijo
update usuarios
set usu_password = SHA2(usu_password, 256);