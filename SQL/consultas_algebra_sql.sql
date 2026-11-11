-- =====================================================================
-- Consultas en álgebra relacional y su traducción a SQL
-- Sistema de gestión de ventas de ropa deportiva
-- Compatibles con SQLite (DB Browser) y MySQL 8.0.31+
-- Supuesto: detalle_venta.descuento es un monto en dólares por línea,
--           así que subtotal = cantidad * precio_unitario - descuento.
-- La Consulta 3 es la que ya tenías en tu informe (no se repite aquí).
-- =====================================================================


-- ---------------------------------------------------------------------
-- CONSULTA 1 — Selección (σ): variantes con stock crítico
-- Objetivo: listar las variantes (talla y color) con 15 unidades o menos.
-- Álgebra:  σ stock_actual ≤ 15 (VARIANTE)
-- ---------------------------------------------------------------------
SELECT *
FROM variante
WHERE stock_actual <= 15;


-- ---------------------------------------------------------------------
-- CONSULTA 2 — Diferencia (−) con proyección (π) y reunión (⋈):
--              clientes sin ninguna venta completada
-- Objetivo: obtener los clientes que no tienen ventas con estado
--           COMPLETADA (solo pendientes, canceladas o ninguna).
-- Álgebra:  π nombres, telefono, email (
--               CLIENTE ⋈ ( π id_cliente (CLIENTE)
--                           − π id_cliente (σ estado = 'COMPLETADA' (VENTA)) )
--           )
-- ---------------------------------------------------------------------
SELECT c.nombres, c.telefono, c.email
FROM cliente c
WHERE c.id_cliente IN (
    SELECT id_cliente FROM cliente
    EXCEPT
    SELECT id_cliente FROM venta WHERE estado = 'COMPLETADA'
);
-- Alternativa si tu MySQL es anterior a 8.0.31 (no tiene EXCEPT):
-- SELECT c.nombres, c.telefono, c.email
-- FROM cliente c
-- WHERE NOT EXISTS (
--     SELECT 1 FROM venta v
--     WHERE v.id_cliente = c.id_cliente AND v.estado = 'COMPLETADA'
-- );


-- ---------------------------------------------------------------------
-- CONSULTA 4 — Reunión natural (⋈) de cinco relaciones:
--              historial de compras por cliente
-- Álgebra:  π CLIENTE.nombres, VENTA.fecha, VENTA.estado, PRODUCTO.nombre,
--             talla, color, cantidad, subtotal (
--               CLIENTE ⋈ VENTA ⋈ DETALLE_VENTA ⋈ VARIANTE ⋈ PRODUCTO )
--           donde subtotal = cantidad · precio_unitario − descuento
-- ---------------------------------------------------------------------
SELECT c.nombres                                        AS cliente,
       v.fecha,
       v.estado,
       p.nombre                                         AS producto,
       va.talla,
       va.color,
       dv.cantidad,
       dv.cantidad * dv.precio_unitario - dv.descuento  AS subtotal
FROM cliente c
JOIN venta v          ON v.id_cliente   = c.id_cliente
JOIN detalle_venta dv ON dv.id_venta    = v.id_venta
JOIN variante va      ON va.id_variante = dv.id_variante
JOIN producto p       ON p.id_producto  = va.id_producto
ORDER BY c.nombres, v.id_venta;


-- ---------------------------------------------------------------------
-- CONSULTA 5 — Agrupamiento (γ) con selección (σ) y reunión (⋈):
--              ingresos por categoría (sin ventas canceladas)
-- Álgebra:  σ ingresos ≥ 100 (
--             γ CATEGORIA.nombre ; SUM(cantidad) → unidades_vendidas,
--                 SUM(cantidad · precio_unitario − descuento) → ingresos (
--               σ estado ≠ 'CANCELADA' (
--                 CATEGORIA ⋈ PRODUCTO ⋈ VARIANTE ⋈ DETALLE_VENTA ⋈ VENTA ) ) )
-- ---------------------------------------------------------------------
SELECT c.nombre                                               AS categoria,
       SUM(dv.cantidad)                                       AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_unitario - dv.descuento)   AS ingresos
FROM categoria c
JOIN producto p       ON p.id_categoria = c.id_categoria
JOIN variante va      ON va.id_producto = p.id_producto
JOIN detalle_venta dv ON dv.id_variante = va.id_variante
JOIN venta v          ON v.id_venta     = dv.id_venta
WHERE v.estado <> 'CANCELADA'
GROUP BY c.id_categoria, c.nombre
HAVING SUM(dv.cantidad * dv.precio_unitario - dv.descuento) >= 100
ORDER BY ingresos DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 6 — División (÷): proveedores que han suministrado TODAS las
--              variantes de la 'Camiseta Oficial Deportivo'
-- Álgebra:  π razon_social ( PROVEEDOR ⋈ ( R ÷ S ) )
--           R = π id_proveedor, id_variante ( COMPRA ⋈ DETALLE_COMPRA )
--           S = π id_variante ( σ nombre = 'Camiseta Oficial Deportivo'
--                               ( PRODUCTO ⋈ VARIANTE ) )
-- SQL no tiene operador de división: se resuelve con doble NOT EXISTS
-- ("no existe una variante de la camiseta que el proveedor no haya surtido").
-- ---------------------------------------------------------------------
SELECT pr.razon_social
FROM proveedor pr
WHERE NOT EXISTS (
    SELECT 1
    FROM variante va
    JOIN producto p ON p.id_producto = va.id_producto
    WHERE p.nombre = 'Camiseta Oficial Deportivo'
      AND NOT EXISTS (
          SELECT 1
          FROM compra co
          JOIN detalle_compra dc ON dc.id_compra = co.id_compra
          WHERE co.id_proveedor = pr.id_proveedor
            AND dc.id_variante  = va.id_variante
      )
);
