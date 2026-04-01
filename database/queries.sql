-- =========================================================
-- Queries
-- =========================================================

-- 1) Búsqueda de items por nombre
SELECT
    i.id,
    i.name,
    i.description,
    i.base_unit_price,
    i.base_estimated_hours,
    i.is_active
FROM items i
WHERE LOWER(i.name) LIKE LOWER('%seo%')
ORDER BY i.name;


-- 2) Búsqueda de items por "categoría" comercial (service)
-- En este ER no hay categories, así que se usa services como agrupación funcional
SELECT
    s.name AS service_name,
    i.id AS item_id,
    i.name AS item_name,
    COALESCE(si.price_override, i.base_unit_price) AS effective_price_clp,
    COALESCE(si.hours_override, i.base_estimated_hours) AS effective_hours,
    si.is_default,
    si.complexity_level
FROM service_items si
JOIN services s ON s.id = si.service_id
JOIN items i ON i.id = si.item_id
WHERE s.name = 'Desarrollo Web'
ORDER BY i.name;


-- 3) Top N productos/ítems por ventas (cantidad)
SELECT
    i.id,
    i.name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN service_items si ON si.id = oi.service_item_id
JOIN items i ON i.id = si.item_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY i.id, i.name
ORDER BY total_quantity_sold DESC, i.name
LIMIT 5;


-- 4) Top N productos/ítems por ventas (monto)
SELECT
    i.id,
    i.name,
    SUM(oi.line_total) AS total_sales_clp
FROM order_items oi
JOIN service_items si ON si.id = oi.service_item_id
JOIN items i ON i.id = si.item_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY i.id, i.name
ORDER BY total_sales_clp DESC, i.name
LIMIT 5;


-- 5) Ventas por mes
SELECT
    DATE_TRUNC('month', o.created_at)::date AS month,
    COUNT(DISTINCT o.id) AS orders_count,
    SUM(o.total) AS total_sales_clp
FROM orders o
WHERE o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY month;


-- 6) Ventas por mes y por servicio/categoría
SELECT
    DATE_TRUNC('month', o.created_at)::date AS month,
    s.id AS service_id,
    s.name AS service_name,
    COUNT(DISTINCT o.id) AS orders_count,
    SUM(oi.line_total) AS service_sales_clp
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN service_items si ON si.id = oi.service_item_id
JOIN services s ON s.id = si.service_id
WHERE o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY DATE_TRUNC('month', o.created_at), s.id, s.name
ORDER BY month, s.name;


-- 7) Ticket promedio en rango de fechas
SELECT
    COUNT(*) AS total_orders,
    AVG(total)::NUMERIC(12,2) AS avg_ticket_clp
FROM orders
WHERE created_at::date BETWEEN '2026-01-01' AND '2026-03-31'
  AND status IN ('confirmed', 'in_progress', 'completed');


-- 8) "Stock bajo" adaptado al modelo:
-- aquí no hay inventario físico; lo más cercano es capacidad/disponibilidad baja
-- umbral configurable: horas restantes <= 2
SELECT
    id,
    slot_date,
    total_hours,
    reserved_hours,
    (total_hours - reserved_hours) AS remaining_hours,
    priority_level
FROM availability_slots
WHERE (total_hours - reserved_hours) <= 2
ORDER BY slot_date;


-- 9) Productos/ítems sin ventas
SELECT
    i.id,
    i.name,
    i.base_unit_price
FROM items i
LEFT JOIN service_items si ON si.item_id = i.id
LEFT JOIN order_items oi ON oi.service_item_id = si.id
LEFT JOIN orders o ON o.id = oi.order_id
    AND o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY i.id, i.name, i.base_unit_price
HAVING COUNT(o.id) = 0
ORDER BY i.name;


-- 10) Clientes frecuentes (>= X órdenes)
-- Ejemplo: X = 2
SELECT
    c.id,
    c.name,
    c.last_name,
    COUNT(o.id) AS total_orders,
    SUM(o.total) AS total_billed_clp
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.status IN ('confirmed', 'in_progress', 'completed')
GROUP BY c.id, c.name, c.last_name
HAVING COUNT(o.id) >= 2
ORDER BY total_orders DESC, total_billed_clp DESC;


-- 11) Saldo pendiente por orden
SELECT
    o.id AS order_id,
    c.name || ' ' || c.last_name AS customer,
    o.total AS order_total_clp,
    COALESCE(SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END), 0) AS paid_clp,
    o.total - COALESCE(SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END), 0) AS pending_clp
FROM orders o
JOIN customers c ON c.id = o.customer_id
LEFT JOIN payments p ON p.order_id = o.id
GROUP BY o.id, c.name, c.last_name, o.total
ORDER BY o.id;


-- 12) Carga planificada por fecha
SELECT
    a.slot_date,
    a.total_hours,
    a.reserved_hours,
    COALESCE(SUM(ois.assigned_hours), 0) AS assigned_hours_registered,
    (a.total_hours - a.reserved_hours) AS remaining_hours
FROM availability_slots a
LEFT JOIN order_item_slots ois ON ois.slot_id = a.id
GROUP BY a.id, a.slot_date, a.total_hours, a.reserved_hours
ORDER BY a.slot_date;


-- =========================================================
-- Transacción 1:
-- Crear una orden, insertar ítems, asignar horas y recalcular total
-- Si algo falla: ROLLBACK
-- =========================================================
BEGIN;
-- 1) Crear cotizacion de cliente previamente creado
INSERT INTO quotes (
    customer_id, guest_name, guest_email, guest_phone, status, 
	discount_type, discount_value, subtotal, discount_amount, total,
    valid_until
) VALUES
(
	4, NULL, NULL, NULL, 'sent', 
	'none', 0, 0, 0, 0, 
	(NOW() + INTERVAL '1 months')::DATE
);

-- 2) Insertar items de la cotizacion
INSERT INTO quote_items (
	quote_id, service_item_id, quantity, 
	unit_price, estimated_hours, line_total
)
SELECT
	currval(pg_get_serial_sequence('quotes', 'id')), si.id, 1, 
	COALESCE(si.price_override, i.base_unit_price), 
	COALESCE(si.hours_override, i.base_estimated_hours),
	COALESCE(si.price_override, i.base_unit_price) * 1
FROM service_items si
JOIN items i ON i.id = si.item_id
WHERE si.service_id = 4 AND si.id IN (35, 36, 47, 38);

-- 3) Recalcular cotización y aprobarla
UPDATE quotes q
SET 
	status = 'approved', 
	discount_type = 'percentage', 
	discount_value = 10, 
	subtotal = x.subtotal, 
	discount_amount = ROUND(x.subtotal * 0.10, 0),
    total = x.subtotal - ROUND(x.subtotal * 0.10, 0)
FROM (
	SELECT 
		quote_id, 
		SUM(line_total) AS subtotal
	FROM quote_items 
	WHERE quote_id = currval(pg_get_serial_sequence('quotes', 'id'))
	GROUP BY quote_id
) x
WHERE q.id = x.quote_id;

-- 4) Crear orden desde cotización aprobada
INSERT INTO orders (
    customer_id,
    quote_id,
    status,
    subtotal,
    discount_amount,
    total,
    start_date,
    estimated_delivery_date
)
SELECT 
	customer_id,
	id,
	'pending',
	subtotal,
	discount_amount,
	total,
	(NOW() + INTERVAL '1 day')::DATE,
	(NOW() + INTERVAL '1 month')::DATE
FROM quotes
WHERE id = currval(pg_get_serial_sequence('quotes', 'id'));

-- 5) Insertar ítems de la orden
INSERT INTO order_items (order_id, service_item_id, quantity, unit_price, estimated_hours, line_total)
SELECT currval(pg_get_serial_sequence('orders', 'id')), service_item_id, quantity, unit_price, 
	   estimated_hours, line_total
FROM quote_items
WHERE quote_id = currval(pg_get_serial_sequence('quotes', 'id'));

-- 6) Recalcular totales de la orden directamente
UPDATE orders o
SET
    subtotal = x.subtotal,
    discount_amount = q.discount_amount,
    total = x.subtotal - q.discount_amount
FROM (
    SELECT
        order_id,
        SUM(line_total) AS subtotal
    FROM order_items
    WHERE order_id = (SELECT MAX(id) FROM orders)
    GROUP BY order_id
) x,
quotes q
WHERE o.id = x.order_id
  AND q.id = o.quote_id
  AND o.id = (SELECT MAX(id) FROM orders);

-- 7) Insertar slots para esta orden
INSERT INTO availability_slots (slot_date, total_hours, reserved_hours) VALUES
((NOW() + INTERVAL '1 days')::DATE, 8, 0),
((NOW() + INTERVAL '2 days')::DATE, 8, 0),
((NOW() + INTERVAL '3 days')::DATE, 8, 0),
((NOW() + INTERVAL '4 days')::DATE, 8, 0);

-- 8) Asignar horas a slots
-- Asignación de order_items a slots
-- Se hace de manera manual, pero esto será automatizado ya sea 
-- pro el backend o con PL/SQL
-- Item 1 -> 1 hora
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
    s.id,
	CASE
        WHEN oi.estimated_hours <= 8 THEN oi.estimated_hours
        ELSE 8
    END
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '1 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
LIMIT 1;
-- Item 2 -> 4 horas
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
    s.id,
	CASE
        WHEN oi.estimated_hours <= 8 THEN oi.estimated_hours
        ELSE 8
    END
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '1 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
OFFSET 1
LIMIT 1;
-- Item 3 -> 3 horas de 14
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
	s.id,
	3
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '1 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
OFFSET 2
LIMIT 1;
-- Item 3 -> 11 horas de 14
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
	s.id,
	CASE
        WHEN oi.estimated_hours <= 8 THEN oi.estimated_hours
        ELSE 8
    END
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '2 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
OFFSET 2
LIMIT 1;
-- Item 3 -> 14 horas de 14
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
	s.id,
	3
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '3 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
OFFSET 2
LIMIT 1;
-- Item 4 -> 4 horas
INSERT INTO order_item_slots (order_item_id, slot_id, assigned_hours)
SELECT
    oi.id,
	s.id,
	CASE
        WHEN oi.estimated_hours <= 8 THEN oi.estimated_hours
        ELSE 8
    END
FROM order_items oi
JOIN availability_slots s
    ON s.slot_date = (NOW() + INTERVAL '3 day')::DATE
WHERE oi.order_id = (SELECT MAX(id) FROM orders)
ORDER BY oi.id
OFFSET 3
LIMIT 1;

-- 9) Actualizar horas reservadas de los slots
UPDATE availability_slots a
SET reserved_hours = reserved_hours + x.assigned
FROM (
    SELECT
        ois.slot_id,
        SUM(ois.assigned_hours) AS assigned
    FROM order_item_slots ois
    JOIN order_items oi ON oi.id = ois.order_item_id
    WHERE oi.order_id = currval(pg_get_serial_sequence('orders', 'id'))
    GROUP BY ois.slot_id
) x
WHERE a.id = x.slot_id;

-- 10) Validar que no se sobrepase la capacidad
-- Si esta consulta devuelve filas, se debe hacer ROLLBACK
SELECT 1 / 0
WHERE EXISTS (
    SELECT 1
    FROM availability_slots
    WHERE reserved_hours > total_hours
);

COMMIT;

-- Si en alguno de los pasos se detecta error:
-- ROLLBACK;


-- =========================================================
-- Transacción 2:
-- Registrar pago y actualizar estado si la orden queda pagada
-- =========================================================

BEGIN;

-- Registrar pago
INSERT INTO payments (
    order_id,
    payment_date,
    amount,
    payment_method,
    status,
    transaction_reference
)
VALUES (
    1,
    CURRENT_TIMESTAMP,
    180000,
    'bank_transfer',
    'paid',
    'TRX-0001'
);

-- Si el total pagado alcanza o supera el total de la orden,
-- marcar la orden como completed
UPDATE orders o
SET status = CASE
    WHEN p.total_paid >= o.total THEN 'completed'
    ELSE o.status
END
FROM (
    SELECT
        order_id,
        SUM(amount) AS total_paid
    FROM payments
    WHERE status = 'paid'
      AND order_id = 1
    GROUP BY order_id
) p
WHERE o.id = p.order_id;


-- Registrar resto pago
INSERT INTO payments (
    order_id,
    payment_date,
    amount,
    payment_method,
    status,
    transaction_reference
)
VALUES (
    1,
    CURRENT_TIMESTAMP,
    171000,
    'debit_card',
    'paid',
    'TRX-0002'
);

-- Si el total pagado alcanza o supera el total de la orden,
-- marcar la orden como completed
UPDATE orders o
SET status = CASE
    WHEN p.total_paid >= o.total THEN 'completed'
    ELSE o.status
END
FROM (
    SELECT
        order_id,
        SUM(amount) AS total_paid
    FROM payments
    WHERE status = 'paid'
      AND order_id = 1
    GROUP BY order_id
) p
WHERE o.id = p.order_id;

COMMIT;

-- Si algo falla:
-- ROLLBACK;


select * from availability_slots;