-- Show all procedures and functions in the population database
select routine_type,
       routine_name
from   information_schema.routines
where  routine_schema='population';



-- ============================
-- VISTA: v_pedidos_con_estado_render
-- Muestra los pedidos con su fecha y un indicador si tienen render 3D asociado.
-- También incluye cuántos estados de pedido diferentes existen actualmente.
-- ============================

create view v_pedidos_con_estado_render as
select 
    p.ped_id,
    cast(p.ped_fecha_creacion as date) as fecha_pedido,
    if(coalesce(r.r3d_url, '') = '', 'Sin render', 'Con render') as estado_render,
    (
        select count(distinct estado_pedido_id)
        from pedido
    ) as estados_pedido_usados
from pedido p
left join render_3d r on p.ped_id = r.ped_id;


-- ============================
-- VISTA: v_usuarios_seguridad
-- Muestra información de los usuarios sin exponer la contraseña encriptada.
-- Útil para consultas administrativas o públicas.
-- ============================

create view v_usuarios_seguridad as
select 
    usu_id,
    usu_nombre,
    usu_apellido,
    usu_correo,
    rol_id,
    tipo_documento_id
from usuarios;


-- ============================
-- VISTA: v_detalles_personalizacion_pedido
-- Une datos de pedidos con las personalizaciones, opciones y valores seleccionados.
-- Útil para entender las decisiones de personalización de los clientes.
-- ============================

create view v_detalles_personalizacion_pedido as
select 
    p.ped_id,
    u.usu_nombre,
    o.opc_nombre,
    vp.vp_valor
from pedido p
join usuarios u on p.usu_id = u.usu_id
join personalizacion pr on p.ped_id = pr.ped_id
join detalle_personalizacion dp on pr.pers_id = dp.pers_id
join valor_personalizacion vp on dp.vp_id = vp.vp_id
join opcion_personalizacion o on vp.opc_id = o.opc_id;


-- ============================
-- VISTA: v_reporte_pedidos_completo
-- Proporciona un resumen claro de cada pedido con cliente, estado, fecha y si tiene render.
-- Muy útil para reportes administrativos o dashboards.
-- ============================

create view v_reporte_pedidos_completo as
select 
    p.ped_id,
    concat(u.usu_nombre, ' ', u.usu_apellido) as cliente,
    ep.est_ped_nombre as estado_pedido,
    date(p.ped_fecha_creacion) as fecha,
    if(r.r3d_url is null, 'No', 'Sí') as tiene_render
from pedido p
join usuarios u on p.usu_id = u.usu_id
join estado_pedido ep on p.estado_pedido_id = ep.estado_pedido_id
left join render_3d r on p.ped_id = r.ped_id;
