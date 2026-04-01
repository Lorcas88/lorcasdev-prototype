# LorcasDev Prototipo

## Descripción del proyecto

Este proyecto corresponde al desarrollo del Módulo 3 del curso **Desarrollo de aplicaciones Fullstack Java**, cuyo objetivo es diseñar e implementar una base de datos relacional para un sistema tipo e-commerce.

En este caso, el modelo fue adaptado a un escenario real de negocio orientado a **servicios informáticos**, en lugar de productos físicos. Esta adaptación fue validada previamente, ya que permite representar de mejor forma un caso práctico.

El sistema modela:

- Clientes
- Servicios (equivalentes a categorías comerciales)
- Ítems (componentes o entregables de los servicios)
- Cotizaciones (quotes)
- Órdenes (orders)
- Pagos (payments)
- Disponibilidad operativa (availability_slots)

Además, se incluye la planificación de horas de trabajo asociadas a cada orden.

## Modelo de datos (ER)

El modelo entidad-relación representa las principales entidades del sistema y sus relaciones:

- Un cliente puede tener múltiples cotizaciones y órdenes
- Una cotización contiene múltiples ítems (quote_items)
- Una orden deriva de una cotización
- Una orden contiene múltiples ítems (order_items)
- Los ítems se definen como combinaciones entre servicios e ítems base (service_items)
- Una orden puede tener múltiples pagos
- Los ítems de una orden pueden distribuirse en distintos bloques de disponibilidad (order_item_slots)

Archivo incluido:

![Diagrama ER](/docs/er.png)

## Esquema relacional (DDL)

El archivo `schema.sql` contiene la definición completa de la base de datos en PostgreSQL.

Incluye:

- Tablas con claves primarias y foráneas
- Tipos ENUM para estados de negocio (orders, payments, quotes, etc.)
- Restricciones de integridad:
  - NOT NULL
  - UNIQUE
  - CHECK (ej: precios positivos, horas válidas)

- Índices para optimización de consultas frecuentes

El diseño prioriza consistencia, integridad y escalabilidad.

## Datos de prueba

El archivo `seed.sql` incluye datos de prueba suficientes para ejecutar y validar las consultas del sistema.

Contiene:

- Clientes
- Servicios
- Ítems
- Relaciones service_items
- Cotizaciones y sus ítems
- Órdenes y sus ítems
- Pagos
- Slots de disponibilidad
- Asignación de horas (order_item_slots)

Los datos permiten simular distintos escenarios:

- Órdenes completadas y en progreso
- Pagos parciales y completos
- Distribución de carga de trabajo
- Ítems con y sin ventas

## Consultas SQL

El archivo `queries.sql` contiene consultas orientadas a responder preguntas de negocio relevantes.

Consultas implementadas:

1. Búsqueda de ítems por nombre
2. Búsqueda de ítems por servicio (categoría)
3. Top productos por cantidad vendida
4. Top productos por monto vendido
5. Ventas por mes
6. Ventas por mes y por servicio
7. Ticket promedio en un rango de fechas
8. Capacidad disponible (equivalente a stock bajo)
9. Ítems sin ventas
10. Clientes frecuentes
11. Saldo pendiente por orden
12. Carga planificada por fecha

Estas consultas utilizan:

- JOIN
- Agregaciones (SUM, COUNT, AVG)
- GROUP BY
- Subconsultas
- Filtros por estado

## Transacciones

### Transacción 1: Creación de orden

Flujo implementado:

1. Creación de cotización
2. Inserción de ítems en la cotización
3. Cálculo de subtotal, descuento y total
4. Creación de la orden a partir de la cotización
5. Inserción de ítems de la orden
6. Recalculo de totales de la orden
7. Creación de slots de disponibilidad
8. Asignación de horas a slots
9. Actualización de horas reservadas
10. Validación de capacidad disponible

Validación de integridad:

```sql
SELECT 1 / 0
WHERE EXISTS (
    SELECT 1
    FROM availability_slots
    WHERE reserved_hours > total_hours
);
```

Si la capacidad es excedida, la transacción falla y debe ejecutarse un ROLLBACK.

### Transacción 2: Registro de pagos

Flujo implementado:

1. Registro de pago
2. Cálculo del total pagado por orden
3. Actualización automática del estado de la orden a "completed" si corresponde

Se permite manejo de pagos parciales.

## Instrucciones de uso

1. Crear la base de datos en PostgreSQL
2. Ejecutar el esquema:

```
psql -f schema.sql
```

3. Insertar datos de prueba:

```
psql -f seed.sql
```

4. Ejecutar consultas:

```
psql -f queries.sql
```

## Estructura del proyecto

```
/database
  schema.sql
  seed.sql
  queries.sql

/docs
  er.png

/frontend
  index.html
  product.html
  shopping_cart.html
  /components
    navbar.html
    footer.html
  /css
    styles.css
  /data
    data.json
  /img
    service-1.jpg
    service-2.jpg
    service-3.jpg
    service-4.jpg
    service-5.jpg
    service-6.jpg
    service-7.jpg
    service-8.jpg
  /js
    app.js
    layout.js
    product.js
    shopping_cart.js
    utils.js

README.md
```

## Frontend

El proyecto incluye un prototipo frontend estático que simula una tienda de
servicios informáticos. Actualmente **no está conectado a la base de datos ni a
un backend**, por lo que toda la información mostrada proviene de archivos
locales.

### ¿Cómo funciona?

- `frontend/index.html`: muestra el catálogo de servicios.
- `frontend/product.html`: muestra el detalle de un servicio usando el parámetro
  `id` en la URL.
- `frontend/shopping_cart.html`: muestra el carrito con resumen de subtotal,
  cargo adicional y total.
- `frontend/components/navbar.html`: barra de navegación reutilizable cargada
  dinámicamente.
- `frontend/components/footer.html`: pie de página reutilizable.
- `frontend/css/styles.css`: estilos visuales del prototipo.
- `frontend/data/data.json`: fuente de datos local que emula la respuesta de una
  base de datos o API.
- `frontend/js/app.js`: renderiza las cards del catálogo en la página principal.
- `frontend/js/product.js`: obtiene el servicio seleccionado, pinta su detalle y
  permite agregarlo al carrito.
- `frontend/js/shopping_cart.js`: renderiza el carrito, elimina ítems, vacía el
  carrito y calcula el resumen.
- `frontend/js/layout.js`: inserta dinámicamente el navbar y el footer en cada
  página.
- `frontend/js/utils.js`: contiene utilidades compartidas como formato de moneda
  CLP, manejo de `localStorage`, actualización del badge del carrito y carga de
  servicios.
- `frontend/img/`: contiene las imágenes de apoyo para cada servicio.

### Flujo actual del frontend

1. La página carga componentes comunes (`navbar` y `footer`) mediante `fetch`.
2. Los servicios se obtienen desde `frontend/data/data.json`.
3. El catálogo y el detalle se renderizan dinámicamente con JavaScript.
4. El carrito se guarda en `localStorage`, por lo que persiste en el navegador
   mientras no se limpie manualmente.
5. El botón de solicitud del carrito solo muestra una confirmación visual; no
   registra órdenes, pagos ni clientes en PostgreSQL.

## Consideraciones de diseño

- El modelo reemplaza "productos" por "ítems" y "categorías" por "servicios"
- No se maneja inventario físico; se utiliza disponibilidad de horas como equivalente funcional
- La lógica de negocio compleja (ej: asignación óptima de horas) se deja para backend o futuras implementaciones con PL/pgSQL
- Se priorizó claridad del modelo y consistencia de datos

## Repositorio

Repositorio público:
https://github.com/Lorcas88/lorcasdev-prototype#

## Conclusión

El proyecto cumple con:

- Diseño ER consistente
- Implementación completa del esquema relacional
- Datos de prueba funcionales
- Consultas de negocio relevantes
- Manejo de transacciones

El modelo está preparado para escalar y ser integrado con un backend que gestione la lógica de negocio más compleja.
