-- =============================
-- CONSULTAS AVANZADAS CON JOINS
-- ============================


-- 1. Mostrar todos los pedidos junto con la información del cliente, el estado del pedido
--    y los detalles de personalización si existen.
--    Es útil para generar reportes de producción o atención al cliente.

select 
    p.ped_id,
    u.usu_nombre as cliente,
    ep.est_nombre,
    op.opc_nombre,
    vp.val_nombre
from pedido p
join usuarios u on p.usu_id_admin = u.usu_id
join estado_pedido ep on p.est_id = ep.est_id
left join personalizacion per on p.per_id = per.per_id
left join detalle_personalizacion dp on per.per_id = dp.per_id
left join valor_personalizacion vp on dp.val_id = vp.val_id
left join opcion_personalizacion op on vp.opc_id = op.opc_id;

-- ---------------------------------------------------------

-- 2. Mostrar todas las personalizaciones que aún no tienen valor asignado.
--    Esto ayuda a detectar personalizaciones incompletas o pendientes por configurar.

select per.per_id, op.opc_nombre
from personalizacion per
join detalle_personalizacion dp on per.per_id = dp.per_id
left join valor_personalizacion vp on dp.val_id = vp.val_id
join opcion_personalizacion op on vp.opc_id = op.opc_id
where dp.val_id is null;

-- ---------------------------------------------------------

-- 3. Mostrar pedidos finalizados junto con la foto del producto terminado.
--    Ideal para control de calidad, archivo visual, o pruebas A/B de marketing.

select p.ped_id,
       u.usu_nombre as cliente,
       fpf.fot_imagen_final
from pedido p
join usuarios u on p.usu_id_admin = u.usu_id
join estado_pedido ep on p.est_id = ep.est_id
left join foto_producto_final fpf on p.ped_id = fpf.ped_id
where ep.est_nombre = 'finalizado';

-- ---------------------------------------------------------

-- 4. CTE: Clientes que han hecho más de dos pedidos.
--    Puede servir para detectar clientes frecuentes y aplicar estrategias de fidelización.

with clientes_recurrentes as (
    select usu_id_admin,
           count(*) as total_pedidos
    from pedido
    group by usu_id_admin
    having count(*) > 2
)
select u.usu_nombre, cr.total_pedidos
from clientes_recurrentes cr
join usuarios u on cr.usu_id_admin = u.usu_id;

-- ---------------------------------------------------------

-- 5. Subconsulta: Mostrar las opciones de personalización más utilizadas (>3 veces).
--    Útil para saber qué configuraciones son más populares y enfocar stock o UX en ellas.

select op.opc_nombre
from opcion_personalizacion op
where op.opc_id in (
    select vp.opc_id
    from detalle_personalizacion dp
    join valor_personalizacion vp on dp.val_id = vp.val_id
    group by vp.opc_id
    having count(*) > 3
);

-- ---------------------------------------------------------

-- 6. Unión de los nombres de opciones y los valores posibles.
--    Buena manera de generar un catálogo o verificar la coherencia de los nombres.

select opc_nombre as nombre
from opcion_personalizacion
union
select val_nombre as nombre
from valor_personalizacion;

-- ---------------------------------------------------------

-- 7. Crear tabla temporal con pedidos que están "En proceso".
--    Sirve para operaciones internas como monitoreo diario de producción.

create temporary table pedidos_en_proceso as
select p.ped_id, u.usu_nombre as cliente
from pedido p
join usuarios u on p.usu_id_admin = u.usu_id
join estado_pedido ep on p.est_id = ep.est_id
where ep.est_nombre = 'tallado'; -- ejemplo de estado "en proceso"

select * from pedidos_en_proceso;







-- ============================================
-- Consultas Relevantes con Operadores de Comparación
-- Proyecto: Brisas Gems – Tienda de Joyería Personalizada
-- Basado en Capítulo 7 de "MySQL Crash Course"
-- ============================================

USE brisas_gems;

-- ============================================
-- 1. Consultar pedidos recientes (últimas 2 semanas)
-- Operadores usados: BETWEEN, CURDATE(), DATE_SUB
-- Justificación: permite hacer seguimiento a pedidos recientes
-- ============================================
SELECT 
    p.ped_id,
    u.usu_nombre AS cliente,
    p.ped_fecha_creacion
FROM pedido p
JOIN usuarios u ON p.usu_id_admin = u.usu_id
WHERE p.ped_fecha_creacion BETWEEN DATE_SUB(CURDATE(), INTERVAL 14 DAY) AND CURDATE();

-- ============================================
-- 2. Usuarios que aún no han realizado pedidos
-- Operadores usados: NOT IN, subconsulta
-- Justificación: útil para identificar usuarios inactivos o potenciales clientes
-- ============================================
SELECT 
    u.usu_id,
    u.usu_nombre
FROM usuarios u
WHERE u.usu_id NOT IN (
    SELECT DISTINCT p.usu_id_admin
    FROM pedido p
);

-- ============================================
-- 3. Personalizaciones con valor "oro" o "plata"
-- Operadores usados: LIKE, OR
-- Justificación: permite analizar qué materiales son más populares
-- ============================================
SELECT 
    per.per_id,
    op.opc_nombre,
    vp.val_nombre
FROM detalle_personalizacion dp
JOIN valor_personalizacion vp ON dp.val_id = vp.val_id
JOIN opcion_personalizacion op ON vp.opc_id = op.opc_id
JOIN personalizacion per ON dp.per_id = per.per_id
WHERE vp.val_nombre LIKE '%oro%' OR vp.val_nombre LIKE '%plata%';

-- ===========================================================
-- Consulta: Cantidad total y promedio de personalizaciones por cliente en 2025
-- Usa funciones de agregación: COUNT(), AVG()
-- Usa función de fecha: YEAR()
-- Basada en Capítulo 8 del libro "MySQL Crash Course"
-- ===========================================================

USE brisas_gems;

SELECT 
    u.usu_nombre AS cliente,
    COUNT(p.per_id) AS total_personalizaciones_2025,
    ROUND(AVG(COUNT(p.per_id)) OVER(), 2) AS promedio_personalizaciones_por_cliente_2025
FROM 
    personalizacion p
JOIN 
    usuarios u ON p.usu_id_cliente = u.usu_id
WHERE 
    YEAR(p.per_fecha) = 2025
GROUP BY 
    u.usu_id, u.usu_nombre
ORDER BY 
    total_personalizaciones_2025 DESC;
    
    
-- ===============================================================
-- Consulta: Resumen legible de pedidos con funciones de texto
-- Usa CONCAT(), UPPER(), LEFT(), RIGHT(), SUBSTRING()
-- Basada en capítulo 8 del libro "MySQL Crash Course"
-- ===============================================================

USE brisas_gems;

SELECT 
    CONCAT(UPPER(LEFT(u.usu_nombre, 1)), LOWER(SUBSTRING(u.usu_nombre, 2))) AS nombre_cliente_formateado,
    CONCAT('Pedido-', RIGHT(p.ped_codigo, 4)) AS codigo_resumido,
    DATE_FORMAT(p.ped_fecha_creacion, '%Y-%m-%d') AS fecha,
    TRIM(p.ped_comentarios) AS comentarios_limpios
FROM 
    pedido p
JOIN 
    usuarios u ON p.usu_id_admin = u.usu_id
WHERE 
    p.ped_fecha_creacion >= '2025-01-01'
ORDER BY 
    p.ped_fecha_creacion DESC;
    
-- ===========================================================
-- Consulta: Días entre personalización y creación del pedido
-- Aplica funciones de fecha: DATEDIFF(), DATE_FORMAT(), EXTRACT()
-- Basada en capítulo 8 del libro "MySQL Crash Course"
-- ===========================================================

USE brisas_gems;

USE brisas_gems;

SELECT 
    p.ped_codigo AS codigo_pedido,
    DATE_FORMAT(per.per_fecha, '%Y-%m-%d') AS fecha_personalizacion,
    DATE_FORMAT(p.ped_fecha_creacion, '%Y-%m-%d') AS fecha_pedido,
    DATEDIFF(p.ped_fecha_creacion, per.per_fecha) AS dias_transcurridos,
    WEEKDAY(p.ped_fecha_creacion) AS dia_semana_pedido -- 0 = Lunes, 6 = Domingo
FROM 
    pedido p
JOIN 
    personalizacion per ON p.per_id = per.per_id
WHERE 
    DATEDIFF(p.ped_fecha_creacion, per.per_fecha) >= 0
ORDER BY 
    dias_transcurridos DESC;
    
    
    
    
    
-- Mostrar pedidos con la fecha sin hora (CAST()), identificar si tienen render o no (COALESCE() e IF()), y contar cuántos estados de pedido distintos se han usado (DISTINCT()).
-- 
-- 
    USE brisas_gems;

SELECT 
    p.ped_id,
    CAST(p.ped_fecha_creacion AS DATE) AS fecha_pedido,
    IF(COALESCE(r.r3d_url, '') = '', 'Sin render', 'Con render') AS estado_render,
    (SELECT COUNT(DISTINCT estado_pedido_id) FROM pedido) AS estados_pedido_usados
FROM 
    pedido p
LEFT JOIN 
    render_3d r ON r.ped_id = p.ped_id;