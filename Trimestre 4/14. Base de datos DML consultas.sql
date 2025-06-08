-- ===============
-- JOINS CONSULTAS
-- ===============


-- 1. inner join — detalles de pedidos con info del usuario y estado
-- Así puedes listar pedidos con el nombre del cliente y el estado del pedido, útil para tu administración.
select 
    p.id_pedido,
    u.nombre as nombre_usuario,
    p.fecha_pedido,
    ep.estado as estado_pedido
from pedido p
inner join usuarios u on p.id_usuario = u.id_usuario
inner join estado_pedido ep on p.id_estado = ep.id_estado;

-- 2. left join — todos los usuarios y sus pedidos si existen
-- Para ver qué usuarios aún no han realizado pedidos.
select 
    u.nombre,
    p.id_pedido,
    p.fecha_pedido
from usuarios u
left join pedido p on u.id_usuario = p.id_usuario;

-- 3. join con alias — personalizaciones y valores para un pedido específico
-- Muestra las personalizaciones elegidas para un pedido, mostrando nombre de opción y su valor.
select 
    dp.id_detalle_personalizacion,
    op.opcion_personalizacion,
    vp.valor_personalizacion
from detalle_personalizacion dp
join opcion_personalizacion op on dp.id_opcion_personalizacion = op.id_opcion_personalizacion
join valor_personalizacion vp on dp.id_valor_personalizacion = vp.id_valor_personalizacion
where dp.id_pedido = 123; -- cambia 123 por el id que quieras


-- 4. cross join — combinar todas las opciones y valores
-- Para explorar todas las combinaciones posibles (aunque no todas existan realmente en tus datos).
select 
    op.opcion_personalizacion,
    vp.valor_personalizacion
from opcion_personalizacion op
cross join valor_personalizacion vp;

-- 5. self join — usuarios con el mismo rol
-- Para ver qué usuarios comparten el mismo rol, útil para gestión de permisos o grupos.
select 
    u1.nombre as usuario1,
    u2.nombre as usuario2,
    r.descripcion as rol
from usuarios u1
join usuarios u2 on u1.id_rol = u2.id_rol and u1.id_usuario != u2.id_usuario
join rol r on u1.id_rol = r.id_rol
order by rol, usuario1;

