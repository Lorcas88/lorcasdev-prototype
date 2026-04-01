-- =========================================================
-- seed.sql
-- =========================================================

-- Clientes
INSERT INTO customers (name, last_name, email, phone, company_name, address) VALUES
('Juan', 'Pérez', 'juan.perez@mail.com', '+56911111111', 'JP Eventos', 'Santiago Centro'),
('María', 'González', 'maria.gonzalez@mail.com', '+56922222222', 'MG Producciones', 'Providencia'),
('Carlos', 'Rojas', 'carlos.rojas@mail.com', '+56933333333', NULL, 'Ñuñoa'),
('Ana', 'Muñoz', 'ana.munoz@mail.com', '+56944444444', 'AM SpA', 'Las Condes');


-- Servicios
INSERT INTO services (name, description, price, is_active, estimated_base_hours) VALUES
('Desarrollo Web', 'Diseño y desarrollo de sitios web modernos, landing pages y aplicaciones web.', 340000, TRUE, 25),
('Automatización de procesos', 'Automatización de tareas repetitivas mediante scripts e integraciones entre sistemas.', 240000, TRUE, 18),
('Análisis de datos', 'Análisis exploratorio, visualización de datos y generación de insights para la toma de decisiones.', 370000, TRUE, 20),
('Desarrollo de software', 'Desarrollo de aplicaciones a medida, backend, frontend o sistemas completos.', 650000, TRUE, 45),
('Soporte técnico', 'Resolución de problemas técnicos, mantenimiento y asistencia a usuarios o sistemas.', 80000, TRUE, 5),
('Administración de servidores', 'Configuración, mantenimiento y monitoreo de servidores y servicios en la nube.', 220000, TRUE, 15),
('Creación de bots', 'Desarrollo de bots para automatización (WhatsApp, Telegram, Discord, etc.).', 310000, TRUE, 18),
('Asesoría tecnológica', 'Consultoría para definición de arquitectura, herramientas y estrategias tecnológicas.', 90000, TRUE, 6),
('Integración IA', 'Implementación de soluciones con inteligencia artificial (chatbots, análisis, automatización inteligente).', 250000, TRUE, 30);


-- Items
INSERT INTO items (name, description, base_unit_price, base_estimated_hours, is_active) VALUES
('Kickoff meeting', 'Reunión inicial para alinear objetivos, alcance, plazos y forma de trabajo del proyecto.', 20000, 1, TRUE),
('Levantamiento de requerimientos', 'Análisis y recopilación de necesidades funcionales y técnicas del cliente.', 70000, 4.00, TRUE),
('Landing page', 'Página única orientada a presentar un producto, servicio o campaña específica.', 150000, 10.00, TRUE),
('Diseño básico', 'Diseño visual simple basado en estructura estándar, priorizando claridad y rapidez de entrega.', 70000, 4.00, TRUE),
('Desarrollo frontend', 'Implementación de la interfaz de usuario, navegación y componentes visuales del sistema.', 200000, 12.00, TRUE),
('Desarrollo backend', 'Construcción de lógica de negocio, base de datos, autenticación y servicios del sistema.', 250000, 14.00, TRUE),
('SEO básico', 'Configuración inicial de etiquetas, estructura, indexación y buenas prácticas de posicionamiento.', 60000, 3.00, TRUE),
('Soporte por hora', 'Soporte técnico correctivo o evolutivo cobrado por bloque de horas.', 25000, 1.00, TRUE),
('Garantía', 'Cobertura de corrección de errores posteriores a la entrega dentro de un período definido.', 50000, 8.00, TRUE),
('Documentación técnica', 'Documentación de arquitectura, instalación, uso técnico o mantenimiento de la solución.', 70000, 4.00, TRUE),
('Integración con API', 'Conexión con servicios externos mediante API para intercambio de información o automatización.', 120000, 6.00, TRUE),
('Capacitación', 'Sesión de formación para el uso o administración de la solución entregada.', 60000, 2.00, TRUE),
('Despliegue en servidor', 'Publicación y configuración inicial del sistema en hosting, VPS o nube.', 90000, 4.00, TRUE),
('Monitoreo y mantenimiento', 'Configuración básica de monitoreo de disponibilidad, errores o consumo de recursos.', 80000, 4.00, TRUE),
('Chatbot con IA', 'Implementación de asistente conversacional con IA para consultas, apoyo comercial o soporte.', 220000, 12.00, TRUE),
('Dashboard BI', 'Creación de panel de indicadores y visualizaciones para análisis y toma de decisiones.', 180000, 10.00, TRUE),
('Mantenimiento mensual', 'Servicio periódico de mantenimiento preventivo, ajustes menores y revisión técnica.', 120000, 5.00, TRUE),
('Optimización de rendimiento', 'Mejora de tiempos de carga, consultas, recursos y desempeño general del sistema.', 110000, 5.00, TRUE),
('Formulario de contacto', 'Implementación de formulario para captura de consultas o leads con validaciones básicas.', 40000, 2.00, TRUE),
('Autenticación de usuarios', 'Sistema de registro, inicio de sesión y control de acceso para usuarios.', 100000, 5.00, TRUE),
('Panel de administración', 'Módulo interno para gestionar contenido, usuarios, datos u operaciones del sistema.', 180000, 10.00, TRUE),
('Automatización con scripts', 'Desarrollo de scripts para ejecutar tareas repetitivas de forma automática.', 90000, 4.00, TRUE),
('Integración con WhatsApp o Telegram', 'Conexión del sistema con canales de mensajería para automatización o atención.', 140000, 7.00, TRUE),
('Limpieza y preparación de datos', 'Depuración, transformación y estructuración de datos para análisis o automatización.', 100000, 5.00, TRUE),
('Modelo IA preentrenado', 'Integración de un modelo existente para clasificación, generación o asistencia inteligente.', 160000, 8.00, TRUE),
('Clasificación automática de tickets', 'Automatización de categorización o priorización de tickets mediante reglas o IA.', 150000, 7.00, TRUE),
('Backup y recuperación', 'Configuración básica de respaldos y procedimientos de restauración.', 90000, 5.00, TRUE),
('Instalación y configuración', 'Instalación de sistema operativo y configuración inicial de servidores.', 50000, 4.00, TRUE),
('Gestión de servicios', 'Configuración de servicios web, bases de datos, correo, contenedores, etc.', 40000, 4.00, TRUE),
('Cloud y virtualización', 'Diseño e implementación de arquitectura en la nube o entornos virtualizados.', 120000, 6.00, TRUE);


-- Relación service_items
INSERT INTO service_items (service_id, item_id, is_default, complexity_level, price_override, hours_override) VALUES
-- 1. Desarrollo Web
(1, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(1, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(1, 3, TRUE,  'medium', NULL, NULL),   -- Landing page
(1, 4, TRUE,  'medium', NULL, NULL),   -- Diseño básico
(1, 5,  FALSE, 'high',   NULL, NULL),   -- Desarrollo frontend
(1, 7,  FALSE, 'medium', NULL, NULL),   -- SEO básico
(1, 9,  FALSE, 'low',    NULL, 4.00),   -- Garantía
(1, 10, FALSE, 'low',    NULL, NULL),   -- Documentación técnica
(1, 11, FALSE, 'medium', NULL, NULL),   -- Integración con API
(1, 13, TRUE, 'medium', NULL, NULL),   -- Despliegue en servidor
(1, 14,  FALSE, 'low',   NULL, NULL),   -- Monitoreo
(1, 17,  FALSE, 'low',   NULL, NULL),   -- Mantenimiento mensual
(1, 18,  FALSE, 'medium',NULL, NULL),   -- Optimización de rendimiento
(1, 19,  FALSE, 'low',   NULL, NULL),   -- Formulario de contacto
(1, 20,  FALSE, 'medium',NULL, NULL),   -- Autenticación de usuarios
(1, 21,  FALSE, 'medium',NULL, NULL),   -- Panel de administración
(1, 28, FALSE, 'medium', NULL, NULL),   -- Instalación
-- 2. Automatización de procesos
(2, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(2, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(2, 10, FALSE, 'low',    NULL, NULL),   -- Documentación técnica
(2, 11, FALSE, 'high',   NULL, NULL),   -- Integración con API
(2, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(2, 22, TRUE, 'medium', NULL, NULL),   -- Automatización con scripts
(2, 23, FALSE, 'high',   NULL, NULL),   -- Integración con WhatsApp o Telegram
(2, 24, FALSE, 'medium', NULL, NULL),   -- Limpieza y preparación de datos
(2, 26, FALSE, 'high',   NULL, NULL),   -- Clasificación automática de tickets
(2, 29, FALSE, 'medium', NULL, NULL),   -- Servicios backend
-- 3. Análisis de datos
(3, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(3, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(3, 10, FALSE, 'low',    NULL, NULL),   -- Documentación técnica
(3, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(3, 16, TRUE, 'medium', NULL, NULL),   -- Dashboard BI
(3, 24, TRUE, 'medium', NULL, NULL),   -- Limpieza y preparación de datos
(3, 18, FALSE, 'medium', NULL, NULL),   -- Optimización de rendimiento
-- 4. Desarrollo de software
(4, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(4, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(4, 5, TRUE,  'high',   NULL, NULL),   -- Desarrollo frontend
(4, 6, TRUE,  'high',   NULL, NULL),   -- Desarrollo backend
(4, 10, FALSE, 'medium', NULL, NULL),   -- Documentación técnica
(4, 11, FALSE, 'high',   NULL, NULL),   -- Integración con API
(4, 12, FALSE, 'medium', NULL, NULL),   -- Capacitación
(4, 13, FALSE, 'medium', NULL, NULL),   -- Despliegue en servidor
(4, 19, FALSE, 'low',    NULL, NULL),   -- Formulario de contacto
(4, 20, FALSE, 'medium', NULL, NULL),   -- Autenticación de usuarios
(4, 21, FALSE, 'medium', NULL, NULL),   -- Panel de administración
(4, 27, FALSE, 'medium', NULL, NULL),   -- Backup y recuperación
(4, 28, FALSE, 'medium', NULL, NULL),   -- Instalación entorno
(4, 9,  FALSE, 'low',    NULL, 6.00),   -- Garantía
-- 5. Soporte técnico
(5, 1,  FALSE, 'low',    NULL, NULL),   -- Kickoff meeting
(5, 8, TRUE,  'low',    NULL, NULL),   -- Soporte por hora
(5, 10, FALSE, 'low',    NULL, NULL),   -- Documentación técnica
(5, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(5, 17, FALSE, 'low',    NULL, NULL),   -- Mantenimiento mensual
(5, 18, FALSE, 'medium', NULL, NULL),   -- Optimización de rendimiento
-- 6. Administración de servidores
(6, 29, TRUE, 'medium', NULL, NULL),   -- Gestión de servicios
(6, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(6, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(6, 10, FALSE, 'medium', NULL, NULL),   -- Documentación técnica
(6, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(6, 13, FALSE, 'medium', NULL, NULL),   -- Despliegue en servidor
(6, 14, TRUE, 'medium', NULL, NULL),   -- Monitoreo
(6, 17, FALSE, 'medium', NULL, NULL),   -- Mantenimiento mensual
(6, 18, FALSE, 'medium', NULL, NULL),   -- Optimización de rendimiento
(6, 27, TRUE, 'medium', NULL, NULL),   -- Backup y recuperación
(6, 28, TRUE, 'medium', NULL, NULL),   -- Instalación y configuración
(6, 30, FALSE, 'high',   NULL, NULL),   -- Cloud y virtualización
-- 7. Creación de bots
(7, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(7, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(7, 10, FALSE, 'low',    NULL, NULL),   -- Documentación técnica
(7, 11, FALSE, 'high',   NULL, NULL),   -- Integración con API
(7, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(7, 15, TRUE, 'high',   NULL, NULL),   -- Chatbot con IA
(7, 23, FALSE, 'high',   NULL, NULL),   -- Integración con WhatsApp o Telegram
(7, 17, FALSE, 'low',    NULL, NULL),   -- Mantenimiento mensual
-- 8. Asesoría tecnológica
(8, 1, TRUE,  'low',    15000, 1.00),  -- Kickoff meeting
(8, 2, TRUE,  'medium', 50000, 3.00),  -- Levantamiento de requerimientos
(8, 10, FALSE, 'low',    50000, 2.50),  -- Documentación técnica
(8, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(8, 18, FALSE, 'medium', 90000, 4.00),  -- Optimización de rendimiento
(8, 27, FALSE, 'medium', 80000, 3.00),  -- Backup y recuperación
-- 9. Integración IA
(9, 1, TRUE,  'low',    NULL, NULL),   -- Kickoff meeting
(9, 2, TRUE,  'medium', NULL, NULL),   -- Levantamiento de requerimientos
(9, 10, FALSE, 'medium', NULL, NULL),   -- Documentación técnica
(9, 11, FALSE, 'high',   NULL, NULL),   -- Integración con API
(9, 12, FALSE, 'low',    NULL, NULL),   -- Capacitación
(9, 15, FALSE, 'high',   NULL, NULL),   -- Chatbot con IA
(9, 24, FALSE, 'medium', NULL, NULL),   -- Limpieza y preparación de datos
(9, 25, TRUE, 'high',   NULL, NULL),   -- Modelo IA preentrenado
(9, 26, FALSE, 'high',   NULL, NULL),   -- Clasificación automática de tickets
(9, 16, FALSE, 'medium', NULL, NULL),   -- Dashboard BI
(9, 29, FALSE, 'medium', NULL, NULL),   -- Gestión servicios
(9, 30, FALSE, 'high',   NULL, NULL);   -- Cloud IA

-- ---------------------------------------------------------
-- Quotes
-- ---------------------------------------------------------
INSERT INTO quotes (
    customer_id, guest_name, guest_email, guest_phone,
    status, discount_type, discount_value, subtotal, discount_amount, total,
    created_at, valid_until
) VALUES
(1, NULL, NULL, NULL, 'approved', 'percentage', 10, 420000, 42000, 378000, '2026-01-10 10:00:00', '2026-01-20'),
(2, NULL, NULL, NULL, 'approved', 'fixed', 30000, 610000, 30000, 580000, '2026-02-05 11:30:00', '2026-02-20'),
(3, NULL, NULL, NULL, 'sent', 'none', 0, 250000, 0, 250000, '2026-03-01 09:15:00', '2026-03-15'),
(NULL, 'Pedro Soto', 'pedro.soto@mail.com', '+56955555555', 'draft', 'none', 0, 180000, 0, 180000, '2026-03-18 16:40:00', '2026-03-30');

-- ---------------------------------------------------------
-- Quote items
-- service_item_id existentes según tu seed actual
-- ---------------------------------------------------------
INSERT INTO quote_items (
    quote_id, service_item_id, quantity, unit_price, estimated_hours, line_total
) VALUES
-- Quote 1 - Desarrollo Web
(1, 1, 1, 20000, 1.00, 20000),    -- Kickoff meeting
(1, 2, 1, 70000, 4.00, 70000),    -- Levantamiento de requerimientos
(1, 3, 1, 150000, 10.00, 150000), -- Landing page
(1, 10, 1, 90000, 4.00, 90000),   -- Despliegue en servidor
(1, 15, 1, 40000, 2.00, 40000),   -- Formulario de contacto
(1, 16, 1, 50000, 5.00, 50000),   -- Autenticación de usuarios

-- Quote 2 - Desarrollo de software
(2, 34, 1, 20000, 1.00, 20000),   -- Kickoff meeting
(2, 35, 1, 70000, 4.00, 70000),   -- Levantamiento de requerimientos
(2, 36, 1, 200000, 12.00, 200000),-- Desarrollo frontend
(2, 37, 1, 250000, 14.00, 250000),-- Desarrollo backend
(2, 40, 1, 70000, 4.00, 70000),  -- Capacitación

-- Quote 3 - Integración IA
(3, 66, 1, 20000, 1.00, 20000),  -- Kickoff meeting
(3, 67, 1, 70000, 4.00, 70000),  -- Levantamiento de requerimientos
(3, 73, 1, 160000, 8.00, 160000),-- Modelo IA preentrenado

-- Quote 4 - invitado
(4, 47, 1, 180000, 10.00, 180000); -- Dashboard BI

-- ---------------------------------------------------------
-- Orders
-- quote_id único según schema
-- ---------------------------------------------------------
INSERT INTO orders (
    customer_id, quote_id, status, subtotal, discount_amount, total,
    created_at, start_date, estimated_delivery_date
) VALUES
(1, 1, 'completed', 420000, 42000, 378000, '2026-01-12 10:30:00', '2026-01-13', '2026-01-25'),
(2, 2, 'in_progress', 610000, 30000, 580000, '2026-02-07 12:00:00', '2026-02-08', '2026-02-28');

-- ---------------------------------------------------------
-- Order items
-- ---------------------------------------------------------
INSERT INTO order_items (
    order_id, service_item_id, quantity, unit_price, estimated_hours, line_total
) VALUES
-- Order 1
(1, 1, 1, 20000, 1.00, 20000),
(1, 2, 1, 70000, 4.00, 70000),
(1, 3, 1, 150000, 10.00, 150000),
(1, 10, 1, 90000, 4.00, 90000),
(1, 15, 1, 40000, 2.00, 40000),
(1, 16, 1, 50000, 5.00, 50000),

-- Order 2
(2, 34, 1, 20000, 1.00, 20000),
(2, 35, 1, 70000, 4.00, 70000),
(2, 36, 1, 200000, 12.00, 200000),
(2, 37, 1, 250000, 14.00, 250000),
(2, 40, 1, 70000, 4.00, 70000);

-- ---------------------------------------------------------
-- Payments
-- ---------------------------------------------------------
INSERT INTO payments (
    order_id, payment_date, amount, payment_method, status, transaction_reference
) VALUES
(1, '2026-01-12 16:00:00', 200000, 'bank_transfer', 'paid', 'TRX-2026-0001'),
(1, '2026-01-18 11:30:00', 178000, 'credit_card', 'paid', 'TRX-2026-0002'),
(2, '2026-02-10 09:45:00', 300000, 'debit_card', 'paid', 'TRX-2026-0003'),
(2, '2026-02-15 17:20:00', 280000, 'bank_transfer', 'pending', 'TRX-2026-0004');

-- ---------------------------------------------------------
-- Availability slots
-- ---------------------------------------------------------
INSERT INTO availability_slots (
    slot_date, total_hours, reserved_hours, priority_level
) VALUES
('2026-01-13', 8.00, 5.00, 1),
('2026-01-14', 8.00, 7.00, 2),
('2026-01-15', 8.00, 6.00, 2),
('2026-02-08', 8.00, 5.00, 1),
('2026-02-09', 8.00, 8.00, 1),
('2026-02-10', 8.00, 7.00, 3),
('2026-02-11', 8.00, 2.00, 4);

-- ---------------------------------------------------------
-- Order item slots
-- ---------------------------------------------------------
INSERT INTO order_item_slots (
    order_item_id, slot_id, assigned_hours
) VALUES
-- Order 1
(1, 1, 1.00),
(2, 1, 4.00),
(3, 2, 7.00),
(3, 3, 3.00),
(4, 3, 3.00),
(4, 2, 1.00),
(5, 3, 2.00),
(6, 2, 5.00),

-- Order 2
(7, 4, 1.00),
(8, 4, 4.00),
(9, 5, 8.00),
(9, 6, 4.00),
(10, 6, 3.00),
(10, 7, 8.00),
(10, 4, 3.00),
(11, 7, 4.00);