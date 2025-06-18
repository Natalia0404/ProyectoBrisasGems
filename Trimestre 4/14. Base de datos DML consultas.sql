-- ===================
-- CONSULTAS CON JOINS
-- ===================


-- 1. inner join — detalles de pedidos con info del usuario y estado
-- Así puedes listar pedidos con el nombre del cliente y el estado del pedido, útil para tu administración.
select 
    p.ped_id,
    u.usu_nombre as nombre_usuario,
    p.ped_fecha_creacion,
    ep.est_nombre as estado_pedido
from pedido p
inner join usuarios u on p.usu_id_admin = u.usu_id
inner join estado_pedido ep on p.est_id = ep.est_id;

-- 2. left join — todos los usuarios y sus pedidos si existen
-- Para ver qué usuarios aún no han realizado pedidos.
select 
    u.usu_nombre,
    p.ped_id,
    p.ped_fecha_creacion
from usuarios u
left join pedido p on u.usu_id = p.usu_id_admin;

-- 3. join con alias — personalizaciones y valores para un pedido específico
-- Muestra las personalizaciones elegidas para un pedido, mostrando nombre de opción y su valor.
select 
    dp.det_id,
    op.opc_nombre,
    vp.val_nombre
from detalle_personalizacion dp
join valor_personalizacion vp on dp.val_id = vp.val_id
join opcion_personalizacion op on vp.opc_id = op.opc_id
join personalizacion per on dp.per_id = per.per_id
join pedido p on per.per_id = p.per_id
where p.ped_id = 1; -- puedes cambiar por cualquier ID rea


-- 4. cross join — combinar todas las opciones y valores
-- Para explorar todas las combinaciones posibles (aunque no todas existan realmente en tus datos).
select 
    op.opc_nombre,
    vp.val_nombre
from opcion_personalizacion op
cross join valor_personalizacion vp;

-- 5. self join — usuarios con el mismo rol
-- Para ver qué usuarios comparten el mismo rol, útil para gestión de permisos o grupos.
select 
    u1.usu_nombre as usuario1,
    u2.usu_nombre as usuario2,
    r.rol_nombre as rol
from usuarios u1
join usuarios u2 on u1.rol_id = u2.rol_id and u1.usu_id != u2.usu_id
join rol r on u1.rol_id = r.rol_id
order by rol, usuario1;

-- ===================
-- CONSULTAS AVANZADAS
-- ===================

