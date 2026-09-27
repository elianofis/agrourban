-- ============================================================================
-- Archivo: agrourban.sql
-- Base de datos: AgroUrbanDB (script para MySQL Workbench)
-- Creado: 2025-11-06
-- Notas:
--  - NVARCHAR se usa para campos alfanuméricos (soporta multi-idioma)
--  - VARCHAR usado en campos cortos (email, codigo)
--  - TEXT para descripciones largas
--  - Todas las FKs tienen ON DELETE RESTRICT 
-- ============================================================================

DROP DATABASE IF EXISTS agrourban;
CREATE DATABASE agrourban CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE agrourban;

-- ========================
-- Catalogo: roles, permisos, usuarios y relaciones
-- ========================
CREATE TABLE rol (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre_rol NVARCHAR(100) NOT NULL,
  descripcion TEXT,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE permiso (
  id_permiso INT AUTO_INCREMENT PRIMARY KEY,
  nombre_permiso NVARCHAR(150) NOT NULL,
  descripcion TEXT,
  codigo VARCHAR(100) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE rol_permiso (
  id_rol_permiso INT AUTO_INCREMENT PRIMARY KEY,
  id_rol INT NOT NULL,
  id_permiso INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rp_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rp_permiso FOREIGN KEY (id_permiso) REFERENCES permiso(id_permiso) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre_apellido NVARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  username NVARCHAR(100) NOT NULL UNIQUE,
  password_hash NVARCHAR(255) NOT NULL,
  telefono VARCHAR(50),
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE usuario_rol (
  id_usuario_rol INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_rol INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_usuario_rol (id_usuario, id_rol)
) ENGINE=InnoDB;

-- ========================
-- Agricultores, fincas y producción
-- ========================
CREATE TABLE agricultor (
  id_agricultor INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NULL, -- vinculado a la cuenta de usuario (opcional)
  nombre NVARCHAR(150) NOT NULL,
  experiencia_anios INT DEFAULT 0,
  certificaciones TEXT,
  tipo_cultivo NVARCHAR(150),
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_agri_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE finca (
  id_finca INT AUTO_INCREMENT PRIMARY KEY,
  id_agricultor INT NOT NULL,
  nombre_finca NVARCHAR(150),
  ubicacion NVARCHAR(255),
  hectareas DECIMAL(10,2) DEFAULT 0,
  tipo_de_suelo NVARCHAR(100),
  coordenadas NVARCHAR(100),
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_finca_agri FOREIGN KEY (id_agricultor) REFERENCES agricultor(id_agricultor) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE producto_agricola (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  id_agricultor INT NOT NULL,
  nombre_producto NVARCHAR(150) NOT NULL,
  unidad_medida NVARCHAR(50) DEFAULT 'kg',
  precio_base DECIMAL(12,2) DEFAULT 0.00,
  stock INT DEFAULT 0,
  descripcion TEXT,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  activo TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_prod_agri FOREIGN KEY (id_agricultor) REFERENCES agricultor(id_agricultor) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE producto_finca ( -- asociación producto - finca (opcional)
  id_producto_finca INT AUTO_INCREMENT PRIMARY KEY,
  id_producto INT NOT NULL,
  id_finca INT NOT NULL,
  cantidad_disponible DECIMAL(10,2) DEFAULT 0,
  fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pf_producto FOREIGN KEY (id_producto) REFERENCES producto_agricola(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pf_finca FOREIGN KEY (id_finca) REFERENCES finca(id_finca) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_producto_finca (id_producto, id_finca)
) ENGINE=InnoDB;

CREATE TABLE inventario_finca ( -- inventario general por finca
  id_inventario INT AUTO_INCREMENT PRIMARY KEY,
  id_finca INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad_disponible DECIMAL(12,2) DEFAULT 0,
  fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_inv_finca FOREIGN KEY (id_finca) REFERENCES finca(id_finca) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES producto_agricola(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_inv_finca_producto (id_finca, id_producto)
) ENGINE=InnoDB;

CREATE TABLE certificacion_agricola (
  id_certificacion INT AUTO_INCREMENT PRIMARY KEY,
  id_agricultor INT NOT NULL,
  tipo_certificacion NVARCHAR(150),
  entidad_emisora NVARCHAR(150),
  fecha_emision DATE,
  fecha_vencimiento DATE,
  documento_url VARCHAR(255),
  observaciones TEXT,
  CONSTRAINT fk_cert_agri FOREIGN KEY (id_agricultor) REFERENCES agricultor(id_agricultor) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Clientes, direcciones y perfiles
-- ========================
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NULL,
  tipo_cliente ENUM('individual','empresa') DEFAULT 'individual',
  nombre_contacto NVARCHAR(150),
  documento_identidad VARCHAR(50),
  puntos_acumulados INT DEFAULT 0,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE direccion_entrega (
  id_direccion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  ciudad NVARCHAR(100),
  barrio NVARCHAR(100),
  direccion NVARCHAR(255),
  referencia TEXT,
  latitud DECIMAL(10,7),
  longitud DECIMAL(10,7),
  telefono VARCHAR(50),
  CONSTRAINT fk_dir_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Carrito, pedidos y detalle
-- ========================
CREATE TABLE carrito_compra (
  id_carrito INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado NVARCHAR(50) DEFAULT 'activo',
  total DECIMAL(12,2) DEFAULT 0.00,
  CONSTRAINT fk_carrito_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detalle_carrito (
  id_detalle_carrito INT AUTO_INCREMENT PRIMARY KEY,
  id_carrito INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad DECIMAL(10,2) DEFAULT 1,
  precio_unitario DECIMAL(12,2) DEFAULT 0.00,
  fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dc_carrito FOREIGN KEY (id_carrito) REFERENCES carrito_compra(id_carrito) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_dc_producto FOREIGN KEY (id_producto) REFERENCES producto_agricola(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pedido (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_direccion INT NULL,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  total DECIMAL(12,2) DEFAULT 0.00,
  estado ENUM('pendiente','pagado','en_preparacion','en_transito','entregado','cancelado') DEFAULT 'pendiente',
  fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_direccion FOREIGN KEY (id_direccion) REFERENCES direccion_entrega(id_direccion) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
  id_detalle_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad DECIMAL(10,2) DEFAULT 1,
  precio_unitario DECIMAL(12,2) DEFAULT 0.00,
  subtotal DECIMAL(14,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  CONSTRAINT fk_dp_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_dp_producto FOREIGN KEY (id_producto) REFERENCES producto_agricola(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Pagos y formas de pago
-- ========================
CREATE TABLE forma_pago (
  id_forma_pago INT AUTO_INCREMENT PRIMARY KEY,
  nombre_pago NVARCHAR(100) NOT NULL,
  descripcion TEXT,
  activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_forma_pago INT NOT NULL,
  monto DECIMAL(14,2) NOT NULL,
  fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  referencia_pago VARCHAR(255),
  CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pago_forma FOREIGN KEY (id_forma_pago) REFERENCES forma_pago(id_forma_pago) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detalle_pago (
  id_detalle_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_pago INT NOT NULL,
  descripcion TEXT,
  monto DECIMAL(14,2) NOT NULL,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_det_pago FOREIGN KEY (id_pago) REFERENCES pago(id_pago) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Transporte, envíos, rutas y seguimiento
-- ========================
CREATE TABLE transportador (
  id_transportador INT AUTO_INCREMENT PRIMARY KEY,
  nombre NVARCHAR(150) NOT NULL,
  documento VARCHAR(50),
  telefono VARCHAR(50),
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE transporte (
  id_transporte INT AUTO_INCREMENT PRIMARY KEY,
  tipo NVARCHAR(100), -- camion, furgon, moto, etc.
  placa VARCHAR(50),
  capacidad_kg DECIMAL(10,2),
  estado NVARCHAR(50),
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE ruta (
  id_ruta INT AUTO_INCREMENT PRIMARY KEY,
  origen NVARCHAR(255),
  destino NVARCHAR(255),
  distancia_km DECIMAL(10,2),
  tiempo_estimado_min INT
) ENGINE=InnoDB;

CREATE TABLE envio (
  id_envio INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_transporte INT NULL,
  id_transportador INT NULL,
  id_ruta INT NULL,
  fecha_envio DATETIME,
  fecha_entrega_estimada DATETIME NULL,
  fecha_entrega DATETIME NULL,
  estado ENUM('preparado','en_transito','entregado','devuelto') DEFAULT 'preparado',
  observaciones TEXT,
  CONSTRAINT fk_envio_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_envio_transporte FOREIGN KEY (id_transporte) REFERENCES transporte(id_transporte) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_envio_transportador FOREIGN KEY (id_transportador) REFERENCES transportador(id_transportador) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_envio_ruta FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE seguimiento_envio (
  id_seguimiento INT AUTO_INCREMENT PRIMARY KEY,
  id_envio INT NOT NULL,
  fecha_estado DATETIME DEFAULT CURRENT_TIMESTAMP,
  ubicacion_actual NVARCHAR(255),
  estado_envio NVARCHAR(100),
  observacion TEXT,
  CONSTRAINT fk_seg_envio FOREIGN KEY (id_envio) REFERENCES envio(id_envio) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Reservas, fidelización, puntos, campañas, descuentos
-- ========================
CREATE TABLE reserva (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad DECIMAL(12,2) DEFAULT 0,
  fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('activa','confirmada','cancelada') DEFAULT 'activa',
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reserva_producto FOREIGN KEY (id_producto) REFERENCES producto_agricola(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE programa_fidelizacion (
  id_programa INT AUTO_INCREMENT PRIMARY KEY,
  nombre NVARCHAR(150),
  descripcion TEXT,
  beneficios TEXT,
  fecha_inicio DATE,
  fecha_fin DATE
) ENGINE=InnoDB;

CREATE TABLE puntos_cliente (
  id_puntos INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  puntos INT DEFAULT 0,
  fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_puntos_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE campana_publicitaria (
  id_campana INT AUTO_INCREMENT PRIMARY KEY,
  nombre NVARCHAR(150),
  fecha_inicio DATE,
  fecha_fin DATE,
  canal NVARCHAR(100),
  descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE descuento (
  id_descuento INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(100) UNIQUE,
  porcentaje DECIMAL(5,2),
  fecha_inicio DATE,
  fecha_fin DATE,
  descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE cliente_descuento (
  id_cliente_descuento INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_descuento INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  usos INT DEFAULT 0,
  CONSTRAINT fk_cd_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cd_desc FOREIGN KEY (id_descuento) REFERENCES descuento(id_descuento) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_cliente_desc (id_cliente, id_descuento)
) ENGINE=InnoDB;

-- ========================
-- Reseñas y feedback
-- ========================
CREATE TABLE resena (
  id_resena INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NULL,
  id_cliente INT NULL,
  calificacion TINYINT UNSIGNED,
  comentario TEXT,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_resena_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_resena_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_resena_calificacion CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- ========================
-- Logs, auditoría y otros catálogos
-- ========================
CREATE TABLE seguimiento_usuario (
  id_seguimiento_usuario INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  accion NVARCHAR(150),
  descripcion TEXT,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_seg_user FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE estado_pedido (
  id_estado_pedido INT AUTO_INCREMENT PRIMARY KEY,
  nombre_estado NVARCHAR(50),
  descripcion TEXT
) ENGINE=InnoDB;

-- ========================
-- Tablas adicionales vistas en el diagrama (ejemplos)
-- ========================
CREATE TABLE formato_pago (
  id_formato_pago INT AUTO_INCREMENT PRIMARY KEY,
  nombre NVARCHAR(100),
  descripcion TEXT,
  activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE puntos_redimidos (
  id_redencion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  puntos_usados INT NOT NULL,
  fecha_redencion DATETIME DEFAULT CURRENT_TIMESTAMP,
  descripcion TEXT,
  CONSTRAINT fk_red_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE campana_cliente (
  id_campana_cliente INT AUTO_INCREMENT PRIMARY KEY,
  id_campana INT NOT NULL,
  id_cliente INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cc_campana FOREIGN KEY (id_campana) REFERENCES campana_publicitaria(id_campana) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cc_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ========================
-- Índices recomendados
-- ========================
CREATE INDEX idx_producto_nombre ON producto_agricola(nombre_producto);
CREATE INDEX idx_pedido_estado ON pedido(estado);
CREATE INDEX idx_cliente_documento ON cliente(documento_identidad);

-- ========================
-- Datos de ejemplo mínimos (opcional)
-- ========================
INSERT INTO usuario (nombre_apellido, email, username, password_hash, telefono)
VALUES 
(N'Camilo Andrés Garzón Caseres','camilo@example.com','camilo.g','$2y$...','3001234567'),
(N'Alveiro Correa','alveiro@example.com','alveiro.c','$2y$...','3007654321'),
(N'Admin AgroUrban','admin@agrourban.com','admin','$2y$...','3000000000');

INSERT INTO agricultor (id_usuario, nombre, experiencia_anios, tipo_cultivo)
VALUES (2, N'Alveiro Correa', 20, N'Hortalizas');

INSERT INTO cliente (id_usuario, tipo_cliente, nombre_contacto, documento_identidad)
VALUES (1, 'individual', N'Camilo Andrés Garzón Caseres', 'CC12345678');

INSERT INTO finca (id_agricultor, nombre_finca, ubicacion, hectareas)
VALUES (1, N'Finca El Paraíso', N'La Unión, Antioquia', 3.50);

INSERT INTO producto_agricola (id_agricultor, nombre_producto, unidad_medida, precio_base, stock, descripcion)
VALUES (1, N'Tomate Chonto', N'kg', 2500.00, 100, 'Tomate fresco cultivado en La Unión');

-- FIN del script
