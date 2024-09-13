-- Crear la base de datos.
CREATE DATABASE supermercado;
USE supermercado;

-- Crear las tablas
-- Crear tabla de usuario
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100) UNIQUE,
    contrasena VARCHAR(255),  -- Corregido el nombre de la columna
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    descripcion VARCHAR(500),
    precio DECIMAL(10,2),
    stock INT,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de ventas
CREATE TABLE Ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- Crear tabla de detalle de ventas
CREATE TABLE Detalle_Ventas (  -- Corregido el nombre de la tabla
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_venta INT,
    id_producto INT,
    cantidad INT,
    subtotal DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

-- Crear tabla de logs de recuperación
CREATE TABLE Logs (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(100),
    accion VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

DELIMITER //

-- Crear disparador para insertar log al agregar un producto
CREATE TRIGGER log_insertar_producto
AFTER INSERT ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO Logs (tabla_afectada, accion, id_usuario)
    VALUES ("Productos", "insert", NEW.id_producto);
END //

-- Crear disparador para insertar log al actualizar un producto
CREATE TRIGGER log_actualizar_producto
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO Logs (tabla_afectada, accion, id_usuario)
    VALUES ("Productos", "update", NEW.id_producto);
END //

-- Crear disparador para insertar log al eliminar un producto
CREATE TRIGGER log_eliminar_producto
AFTER DELETE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO Logs (tabla_afectada, accion, id_usuario)
    VALUES ("Productos", "delete", OLD.id_producto);
END //

DELIMITER ;

-- Crear las vistas
-- Crear vista para ver todos los productos disponibles
CREATE VIEW Vista_Productos AS
SELECT id_producto, nombre, descripcion, precio, stock
FROM Productos
WHERE stock > 0;  -- Corregido el nombre de la columna

-- Crear vista para ver el historial de ventas por usuario
CREATE VIEW Historial_Ventas_Usuario AS
SELECT V.id_venta, V.fecha_venta, V.total, U.nombre
FROM Ventas V
INNER JOIN Usuario U ON V.id_usuario = U.id_usuario;  -- Corregido el nombre de la tabla

-- Insertar un usuario de ejemplo
INSERT INTO Usuario (nombre, correo, contrasena)  -- Corregido el nombre de la tabla
VALUES ("Juan Perez", "juan@gmail.com", "juan123@");

-- Insertar un producto de ejemplo
INSERT INTO Productos (nombre, descripcion, precio, stock)
VALUES ("Manzana", "Manzana roja fresca", 1.20, 100);

-- Insertar una venta de ejemplo
INSERT INTO Ventas (id_usuario, total)
VALUES (1, 24.50);

-- Insertar detalles de la venta de ejemplo
INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad, subtotal)
VALUES (1, 1, 5, 6.00);

-- Consulta para ver los datos de cada tabla
SELECT * FROM Usuario;
SELECT * FROM Productos;
SELECT * FROM Ventas;
SELECT * FROM Detalle_Ventas;
SELECT * FROM Logs;