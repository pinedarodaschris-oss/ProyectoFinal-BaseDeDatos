# Sistema de Gestión de Ventas de Ropa Deportiva

Base de datos relacional para una tienda de ropa deportiva. Gestiona el catálogo (categorías, marcas, productos y variantes con su stock), clientes, empleados, ventas con su detalle y pagos, y las compras a proveedores.

Proyecto de la asignatura **Base de datos** (Unidad 1, ciclo 3 A), Universidad Nacional de Loja, FEIRNNR – Carrera de Computación.

> Todos los datos de ejemplo son ficticios y se usan únicamente con fines académicos.

## Contenido del proyecto

```
ProyectoBaseDeDatos/
├── Base_de_Datos/
│   ├── ventas_ropa_deportiva.db        # Base de datos SQLite con las 12 tablas y datos de ejemplo
│   └── ventas_ropa_deportiva.sqbpro    # Proyecto de DB Browser for SQLite
├── SQL/
│   └── consultas_algebra_sql.sql       # Consultas en álgebra relacional traducidas a SQL
└── diagramas/
    ├── Diagrama_Modelo-Entidad.png     # Diagrama Entidad-Relación
    └── Modelo-Relacional.drawio        # Modelo relacional (editable en draw.io)
```

## Requisitos

- [DB Browser for SQLite](https://sqlitebrowser.org/) para abrir la base de datos y ejecutar las consultas.
- [draw.io](https://app.diagrams.net/) para editar el modelo relacional (opcional).

## Cómo usarlo

1. Abre `Base_de_Datos/ventas_ropa_deportiva.sqbpro` en DB Browser for SQLite. También puedes abrir directamente el archivo `ventas_ropa_deportiva.db`.
2. Ve a la pestaña **Execute SQL**.
3. Abre `SQL/consultas_algebra_sql.sql` y ejecuta cada consulta por separado (selecciona la sentencia y pulsa *Ejecutar línea actual*).

El proyecto abre la base con las llaves foráneas activadas (`foreign_keys=1`).

## Modelo de datos

La base tiene 12 tablas, cada una con 6 registros de ejemplo.

| Grupo | Tabla | Clave primaria | Claves foráneas |
|---|---|---|---|
| Catálogo | `categoria` | `id_categoria` | — |
| Catálogo | `marca` | `id_marca` | — |
| Catálogo | `producto` | `id_producto` | `id_categoria`, `id_marca` |
| Catálogo | `variante` | `id_variante` | `id_producto` |
| Ventas | `cliente` | `id_cliente` | — |
| Ventas | `empleado` | `id_empleado` | — |
| Ventas | `venta` | `id_venta` | `id_cliente`, `id_empleado` |
| Ventas | `detalle_venta` | `id_detalle` | `id_venta`, `id_variante` |
| Ventas | `pago` | `id_pago` | `id_venta` |
| Abastecimiento | `proveedor` | `id_proveedor` | — |
| Abastecimiento | `compra` | `id_compra` | `id_proveedor` |
| Abastecimiento | `detalle_compra` | `id_detalle` | `id_compra`, `id_variante` |

Decisiones de diseño:

- **`producto` y `variante` separados:** el precio y la descripción pertenecen a la prenda, mientras que el stock depende de la talla y el color.
- **Relaciones muchos a muchos:** se resuelven con `detalle_venta` y `detalle_compra`, que guardan el precio vigente en cada transacción.
- **Varios pagos por venta:** una venta puede pagarse combinando métodos (efectivo, tarjeta o transferencia).
- **Restricciones:** `cedula`, `ruc` y `sku` son únicos, y hay `CHECK` para impedir precios negativos y cantidades menores o iguales a 0.

## Consultas

El archivo `SQL/consultas_algebra_sql.sql` contiene cada consulta con su objetivo, su expresión en álgebra relacional y su SQL.

| N.º | Operador | Qué obtiene |
|---|---|---|
| 1 | Selección (σ) | Variantes con stock crítico (15 unidades o menos) |
| 2 | Diferencia (−), proyección (π) y reunión (⋈) | Clientes sin ninguna venta completada |
| 4 | Reunión (⋈) de cinco tablas | Historial de compras por cliente |
| 5 | Agrupamiento (γ) con selección y reunión | Ingresos por categoría, sin ventas canceladas |
| 6 | División (÷) | Proveedores que surtieron todas las variantes de la «Camiseta Oficial Deportivo» |

La Consulta 3 (selección y proyección sobre productos de hombre) está en el informe y no se repite en este archivo.

Supuesto: `detalle_venta.descuento` es un monto en dólares por línea, de modo que `subtotal = cantidad * precio_unitario - descuento`.

Las consultas son compatibles con SQLite y con MySQL 8.0.31 o superior (por el uso de `EXCEPT`). El archivo incluye una alternativa para versiones anteriores de MySQL.

## Limitaciones conocidas

- `venta.total` y `compra.total` se guardan como datos independientes: el motor no los calcula ni los valida contra sus detalles, por lo que en los datos de ejemplo pueden no coincidir con la suma de `detalle_venta` o `detalle_compra`.
- `venta.estado` toma los valores `COMPLETADA`, `PENDIENTE` y `CANCELADA`, pero no tiene una restricción que lo obligue.

## Autor

- **Estudiante:** _(tu nombre)_
- **Docente:** Edwin René Guamán Quinche
- **Repositorio:** _(enlace de Git)_
