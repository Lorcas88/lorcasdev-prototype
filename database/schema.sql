CREATE TYPE discount_type_enum AS ENUM ('none', 'percentage', 'fixed');
CREATE TYPE quote_status_enum AS ENUM ('draft', 'sent', 'approved', 'rejected', 'expired');
CREATE TYPE order_status_enum AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE payment_method_enum AS ENUM ('cash', 'bank_transfer', 'debit_card', 'credit_card', 'other');
CREATE TYPE complexity_level_enum AS ENUM ('low', 'medium', 'high');

-- =========================================================
-- Tabla: customers
-- =========================================================
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(30),
    company_name VARCHAR(150),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customers_email UNIQUE (email),
    CONSTRAINT uq_customers_phone UNIQUE (phone)
);

-- =========================================================
-- Tabla: services
-- Servicio/categoría comercial principal
-- =========================================================
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    price NUMERIC(12,0) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    estimated_base_hours NUMERIC(10,2) NOT NULL,

    CONSTRAINT uq_services_name UNIQUE (name),
    CONSTRAINT chk_services_price_positive CHECK (price > 0),
    CONSTRAINT chk_services_hours_positive CHECK (estimated_base_hours > 0)
);

-- =========================================================
-- Tabla: items
-- Ítems/base del catálogo
-- =========================================================
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    base_unit_price NUMERIC(12,0) NOT NULL,
    base_estimated_hours NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_items_name UNIQUE (name),
    CONSTRAINT chk_items_price_positive CHECK (base_unit_price > 0),
    CONSTRAINT chk_items_hours_positive CHECK (base_estimated_hours >= 0)
);

-- =========================================================
-- Tabla: service_items
-- =========================================================
CREATE TABLE service_items (
    id SERIAL PRIMARY KEY,
    service_id INT NOT NULL,
    item_id INT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    complexity_level complexity_level_enum NOT NULL DEFAULT 'medium',
    price_override NUMERIC(12,0),
    hours_override NUMERIC(10,2),

    CONSTRAINT fk_service_items_service
        FOREIGN KEY (service_id) REFERENCES services(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_service_items_item
        FOREIGN KEY (item_id) REFERENCES items(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT uq_service_items_service_item UNIQUE (service_id, item_id),
    CONSTRAINT chk_service_items_price_override CHECK (price_override IS NULL OR price_override > 0),
    CONSTRAINT chk_service_items_hours_override CHECK (hours_override IS NULL OR hours_override >= 0)
);

-- =========================================================
-- Tabla: quotes
-- customer_id es NULLABLE por guest_name/email/phone
-- Cuando una cotizacion de invitado se aprueba, se debe crear comprador y luego la orden
-- =========================================================
CREATE TABLE quotes (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    guest_name VARCHAR(150),
    guest_email VARCHAR(150),
    guest_phone VARCHAR(30),
    status quote_status_enum NOT NULL DEFAULT 'draft',
    discount_type discount_type_enum NOT NULL DEFAULT 'none',
    discount_value NUMERIC(12,0) NOT NULL DEFAULT 0,
    subtotal NUMERIC(12,0) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,0) NOT NULL DEFAULT 0,
    total NUMERIC(12,0) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until DATE NOT NULL,

    CONSTRAINT fk_quotes_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT chk_quotes_discount_value CHECK (discount_value >= 0),
    CONSTRAINT chk_quotes_subtotal_nonnegative CHECK (subtotal >= 0),
    CONSTRAINT chk_quotes_discount_amount_nonnegative CHECK (discount_amount >= 0),
    CONSTRAINT chk_quotes_total_nonnegative CHECK (total >= 0),

    CONSTRAINT chk_quotes_customer_or_guest CHECK (
        customer_id IS NOT NULL
        OR guest_name IS NOT NULL
        OR guest_email IS NOT NULL
        OR guest_phone IS NOT NULL
    )
);

-- =========================================================
-- Tabla: quote_items
-- Una quote tiene muchos ítems cotizados
-- Cada quote_item refiere a un service_item
-- =========================================================
CREATE TABLE quote_items (
    id SERIAL PRIMARY KEY,
    quote_id INT NOT NULL,
    service_item_id INT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,0) NOT NULL,
    estimated_hours NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(12,0) NOT NULL,

    CONSTRAINT fk_quote_items_quote
        FOREIGN KEY (quote_id) REFERENCES quotes(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_quote_items_service_item
        FOREIGN KEY (service_item_id) REFERENCES service_items(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT uq_quote_items_quote_service_item UNIQUE (quote_id, service_item_id),
    CONSTRAINT chk_quote_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_quote_items_unit_price_positive CHECK (unit_price > 0),
    CONSTRAINT chk_quote_items_estimated_hours_nonnegative CHECK (estimated_hours >= 0),
    CONSTRAINT chk_quote_items_line_total_nonnegative CHECK (line_total >= 0)
);

-- =========================================================
-- Tabla: orders
-- Un customer puede tener muchas órdenes
-- =========================================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    quote_id INT NOT NULL,
    status order_status_enum NOT NULL DEFAULT 'pending',
    subtotal NUMERIC(12,0) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,0) NOT NULL DEFAULT 0,
    total NUMERIC(12,0) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE,
    estimated_delivery_date DATE,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orders_quote
        FOREIGN KEY (quote_id) REFERENCES quotes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

	CONSTRAINT uq_orders_quote UNIQUE (quote_id),
    CONSTRAINT chk_orders_subtotal_nonnegative CHECK (subtotal >= 0),
    CONSTRAINT chk_orders_discount_amount_nonnegative CHECK (discount_amount >= 0),
    CONSTRAINT chk_orders_total_nonnegative CHECK (total >= 0),
    CONSTRAINT chk_orders_delivery_date CHECK (
        estimated_delivery_date IS NULL
        OR start_date IS NULL
        OR estimated_delivery_date >= start_date
    )
);

-- =========================================================
-- Tabla: order_items
-- Una order tiene muchos ítems, cada uno referido a service_item
-- =========================================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    service_item_id INT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,0) NOT NULL,
    estimated_hours NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(12,0) NOT NULL,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_order_items_service_item
        FOREIGN KEY (service_item_id) REFERENCES service_items(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT uq_order_items_order_service_item UNIQUE (order_id, service_item_id),
    CONSTRAINT chk_order_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price_positive CHECK (unit_price > 0),
    CONSTRAINT chk_order_items_estimated_hours_nonnegative CHECK (estimated_hours >= 0),
    CONSTRAINT chk_order_items_line_total_nonnegative CHECK (line_total >= 0)
);

-- =========================================================
-- Tabla: payments
-- Una order puede tener muchos pagos
-- =========================================================

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(12,0) NOT NULL,
    payment_method payment_method_enum NOT NULL,
    status payment_status_enum NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(120),

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT uq_payments_transaction_reference UNIQUE (transaction_reference),
    CONSTRAINT chk_payments_amount_positive CHECK (amount > 0)
);

-- =========================================================
-- Tabla: availability_slots
-- Disponibilidad por fecha
-- =========================================================

CREATE TABLE availability_slots (
    id SERIAL PRIMARY KEY,
    slot_date DATE NOT NULL,
    total_hours NUMERIC(10,2) NOT NULL,
    reserved_hours NUMERIC(10,2) NOT NULL DEFAULT 0,
    priority_level INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT uq_availability_slots_date UNIQUE (slot_date),
    CONSTRAINT chk_availability_slots_available CHECK (total_hours >= 0),
    CONSTRAINT chk_availability_slots_reserved CHECK (reserved_hours >= 0),
    CONSTRAINT chk_availability_slots_reserved_vs_total CHECK (reserved_hours <= total_hours),
    CONSTRAINT chk_availability_slots_priority CHECK (priority_level >= 1 AND priority_level <= 5)
);

-- =========================================================
-- Tabla: order_item_slots
-- Relación N:M entre order_items y availability_slots
-- =========================================================

CREATE TABLE order_item_slots (
    id SERIAL PRIMARY KEY,
    order_item_id INT NOT NULL,
    slot_id INT NOT NULL,
    assigned_hours NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_order_item_slots_order_item
        FOREIGN KEY (order_item_id) REFERENCES order_items(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_order_item_slots_slot
        FOREIGN KEY (slot_id) REFERENCES availability_slots(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT uq_order_item_slots_order_item_slot UNIQUE (order_item_id, slot_id),
    CONSTRAINT chk_order_item_slots_assigned_positive CHECK (assigned_hours > 0)
);

-- =========================================================
-- Índices útiles
-- =========================================================
CREATE INDEX idx_customers_company_name ON customers(company_name);

CREATE INDEX idx_services_name ON services(name);
CREATE INDEX idx_items_name ON items(name);

CREATE INDEX idx_service_items_service_id ON service_items(service_id);
CREATE INDEX idx_service_items_item_id ON service_items(item_id);
CREATE INDEX idx_service_items_complexity ON service_items(complexity_level);

CREATE INDEX idx_quotes_customer_id ON quotes(customer_id);
CREATE INDEX idx_quotes_status ON quotes(status);
CREATE INDEX idx_quotes_created_at ON quotes(created_at);
CREATE INDEX idx_quotes_valid_until ON quotes(valid_until);

CREATE INDEX idx_quote_items_quote_id ON quote_items(quote_id);
CREATE INDEX idx_quote_items_service_item_id ON quote_items(service_item_id);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_quote_id ON orders(quote_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_start_date ON orders(start_date);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_service_item_id ON order_items(service_item_id);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

CREATE INDEX idx_availability_slots_slot_date ON availability_slots(slot_date);
CREATE INDEX idx_order_item_slots_order_item_id ON order_item_slots(order_item_id);
CREATE INDEX idx_order_item_slots_slot_id ON order_item_slots(slot_id);