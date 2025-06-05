-- 1. Mostrar todos los pedidos junto con la información del cliente, el estado del pedido
--    y los detalles de personalización si existen.
--    Es útil para generar reportes de producción o atención al cliente.

select p.id_pedido,
       u.nombre as cliente,
       ep.nombre_estado,
       op.nombre_opcion,
       vp.valor
from pedido p
join usuarios u on p.id_usuario = u.id_usuario
join estado_pedido ep on p.id_estado = ep.id_estado
left join personalizacion per on p.id_pedido = per.id_pedido
left join detalle_personalizacion dp on per.id_personalizacion = dp.id_personalizacion
left join valor_personalizacion vp on dp.id_valor_personalizacion = vp.id_valor_personalizacion
left join opcion_personalizacion op on vp.id_opcion = op.id_opcion;

-- ---------------------------------------------------------

-- 2. Mostrar todas las personalizaciones que aún no tienen valor asignado.
--    Esto ayuda a detectar personalizaciones incompletas o pendientes por configurar.

select per.id_personalizacion, op.nombre_opcion
from personalizacion per
join detalle_personalizacion dp on per.id_personalizacion = dp.id_personalizacion
left join valor_personalizacion vp on dp.id_valor_personalizacion = vp.id_valor_personalizacion
join opcion_personalizacion op on dp.id_opcion = op.id_opcion
where vp.id_valor_personalizacion is null;

-- ---------------------------------------------------------

-- 3. Mostrar pedidos finalizados junto con la foto del producto terminado.
--    Ideal para control de calidad, archivo visual, o pruebas A/B de marketing.

select p.id_pedido,
       u.nombre as cliente,
       fpf.url_foto
from pedido p
join usuarios u on p.id_usuario = u.id_usuario
join estado_pedido ep on p.id_estado = ep.id_estado
left join foto_producto_final fpf on p.id_pedido = fpf.id_pedido
where ep.nombre_estado = 'Finalizado';

-- ---------------------------------------------------------

-- 4. CTE: Clientes que han hecho más de dos pedidos.
--    Puede servir para detectar clientes frecuentes y aplicar estrategias de fidelización.

with clientes_recurrentes as (
    select id_usuario,
           count(*) as total_pedidos
    from pedido
    group by id_usuario
    having count(*) > 2
)
select u.nombre, cr.total_pedidos
from clientes_recurrentes cr
join usuarios u on cr.id_usuario = u.id_usuario;

-- ---------------------------------------------------------

-- 5. Subconsulta: Mostrar las opciones de personalización más utilizadas (>3 veces).
--    Útil para saber qué configuraciones son más populares y enfocar stock o UX en ellas.

select nombre_opcion
from opcion_personalizacion
where id_opcion in (
    select vp.id_opcion
    from detalle_personalizacion dp
    join valor_personalizacion vp on dp.id_valor_personalizacion = vp.id_valor_personalizacion
    group by vp.id_opcion
    having count(*) > 3
);

-- ---------------------------------------------------------

-- 6. Unión de los nombres de opciones y los valores posibles.
--    Buena manera de generar un catálogo o verificar la coherencia de los nombres.

select nombre_opcion as nombre
from opcion_personalizacion
union
select valor as nombre
from valor_personalizacion;

-- ---------------------------------------------------------

-- 7. Crear tabla temporal con pedidos que están "En proceso".
--    Sirve para operaciones internas como monitoreo diario de producción.

create temporary table pedidos_en_proceso as
select p.id_pedido, u.nombre as cliente
from pedido p
join usuarios u on p.id_usuario = u.id_usuario
join estado_pedido ep on p.id_estado = ep.id_estado
where ep.nombre_estado = 'En proceso';

-- Puedes consultar la tabla temporal mientras dure la sesión:
select * from pedidos_en_proceso;
