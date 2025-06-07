
-- 1. consultas de selección básica
-- muestra todos los registros de la tabla usuarios
select *
  from usuarios;

-- 2. consultas con filtros (where)
-- obtiene usuarios con rol cliente (rol_id = 2)
select usu_id,
       usu_nombre,
       usu_correo
  from usuarios
 where rol_id = 2;

-- obtiene pedidos realizados en una fecha específica
select ped_id,
       ped_codigo,
       ped_fecha_creacion
  from pedido
 where ped_fecha_creacion = '2025-06-10';

-- 3. consultas con join
-- combina pedidos con información de usuario y estado
select ped.ped_codigo,
       u.usu_nombre as cliente,
       e.est_nombre as estado,
       ped.ped_fecha_creacion
  from pedido ped
 inner join usuarios u
    on ped.usu_id = u.usu_id
 inner join estado_pedido e
    on ped.est_id = e.est_id;

-- obtiene todos los detalles de personalización para un pedido específico (ej. ped_id = 7)
select vp.val_nombre,
       op.opc_nombre
  from detalle_personalizacion dp
 inner join valor_personalizacion vp
    on dp.val_id = vp.val_id
 inner join opcion_personalizacion op
    on vp.opc_id = op.opc_id
 inner join personalizacion p
    on dp.per_id = p.per_id
 inner join pedido ped
    on p.per_id = ped.per_id
 where ped.ped_id = 7;

-- 4. consultas de agrupamiento y agregación (group by, having)
-- cuenta cuántos pedidos existen para cada estado
select e.est_nombre,
       count(ped.ped_id) as total_pedidos
  from estado_pedido e
  left join pedido ped
    on e.est_id = ped.est_id
 group by e.est_nombre;

-- cuenta el número de personalizaciones realizadas por cada usuario (solo si hay más de cero)
select u.usu_nombre,
       count(p.per_id) as total_personalizaciones
  from usuarios u
  left join personalizacion p
    on u.usu_id = p.usu_id
 group by u.usu_nombre
 having count(p.per_id) > 0;

-- 5. subconsultas (subqueries)
-- lista usuarios que han hecho al menos un pedido
select usu_nombre,
       usu_correo
  from usuarios
 where usu_id in (
       select distinct usu_id
         from pedido
 );

-- obtiene pedidos cuyo estado coincide con "finalizado"
select ped_codigo,
       ped_fecha_creacion
  from pedido
 where est_id = (
        select est_id
          from estado_pedido
         where est_nombre = 'finalizado'
      );

-- 6. consultas con union / union all
-- combina urls de renders y fotos finales en una sola lista
select ren_imagen as url_imagen,
       ren_fecha_aprobacion as fecha
  from render_3d
union all
select fot_imagen_final as url_imagen,
       fot_fecha_subida as fecha
  from foto_producto_final;

-- 7. consultas de inserción (insert)
-- inserta un nuevo tipo de documento
insert into tipo_de_documento (tipdoc_id, tipdoc_nombre)
values (4, 'tarjeta de identidad');

-- agrega un nuevo usuario
insert into usuarios (usu_id, usu_nombre, usu_correo, usu_telefono, usu_password, rol_id, tipdoc_id)
values (16, 'usuario ejemplo', 'ejemplo@gmail.com', '3001000016', 'hash-ejemplo016', 2, 1);

-- 8. consultas de actualización (update)
-- actualiza el estado de un pedido a "tallado" (est_id = 2) para ped_id = 1
update pedido
   set est_id = 2
 where ped_id = 1;

-- cambia el correo de un usuario con usu_id = 2
update usuarios
   set usu_correo = 'luisp_nuevo@gmail.com'
 where usu_id = 2;

-- 9. consultas de eliminación (delete)
-- elimina un valor de personalización específico (val_id = 17)
delete
  from valor_personalizacion
 where val_id = 17;

-- elimina un pedido (ped_id = 15)
-- primero eliminar fotos y renders asociados para evitar errores de integridad
delete
  from foto_producto_final
 where ped_id = 15;

delete
  from render_3d
 where ped_id = 15;

delete
  from pedido
 where ped_id = 15;

-- 10. creación y modificación de estructura (ddl)
-- agrega una columna de dirección en la tabla usuarios
alter table usuarios
  add column usu_direccion varchar(200);

-- crea un índice único sobre ped_codigo
create unique index idx_ped_codigo on pedido(ped_codigo);

-- elimina una tabla temporal (si existe)
drop table if exists temporal_ejemplo;

-- 11. vistas (view)
-- crea una vista para mostrar pedidos completos con usuario y estado
create view vista_pedidos_completos as
select ped.ped_id,
       ped.ped_codigo,
       u.usu_nombre as cliente,
       e.est_nombre as estado,
       ped.ped_fecha_creacion
  from pedido ped
 inner join usuarios u
    on ped.usu_id = u.usu_id
 inner join estado_pedido e
    on ped.est_id = e.est_id;

-- crea una vista para listar detalles de personalización por pedido
create view vista_detalles_personalizacion as
select ped.ped_id,
       u.usu_nombre,
       op.opc_nombre,
       vp.val_nombre
  from pedido ped
 inner join personalizacion p
    on ped.per_id = p.per_id
 inner join detalle_personalizacion dp
    on p.per_id = dp.per_id
 inner join valor_personalizacion vp
    on dp.val_id = vp.val_id
 inner join opcion_personalizacion op
    on vp.opc_id = op.opc_id
 inner join usuarios u
    on ped.usu_id = u.usu_id;

-- 12. procedimientos almacenados y funciones (stored procedures & functions)
-- crea procedimiento para actualizar estado de pedido
delimiter $$
create procedure sp_actualizar_estado_pedido(
    in p_ped_id int,
    in p_nuevo_estado int
)
begin
    update pedido
       set est_id = p_nuevo_estado
     where ped_id = p_ped_id;
end $$
delimiter ;

-- crea función para contar pedidos de un usuario
delimiter $$
create function fn_contar_pedidos_usuario(p_usu_id int)
returns int
deterministic
begin
    declare total int;
    select count(ped_id) into total
      from pedido
     where usu_id = p_usu_id;
    return total;
end $$
delimiter ;

-- 13. transacciones (begin, commit, rollback)
-- ejemplo de transacción atómica para crear personalización y pedido nuevo
start transaction;

insert into personalizacion (per_id, per_fecha, usu_id)
values (16, '2025-06-20', 2);

insert into detalle_personalizacion (det_id, per_id, val_id)
values (76, 16, 1),
       (77, 16, 5),
       (78, 16, 7),
       (79, 16, 12),
       (80, 16, 14);

insert into pedido (ped_id, ped_codigo, ped_fecha_creacion, ped_comentarios, est_id, per_id, usu_id)
values (16, 'p-20250620-016', '2025-06-20', 'pedido transaccional', 1, 16, 2);