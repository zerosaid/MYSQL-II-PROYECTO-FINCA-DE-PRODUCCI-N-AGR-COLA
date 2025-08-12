-- 1. Insertar categoría de producto
DELIMITER $$
CREATE PROCEDURE sp_insert_categoria_producto(
    IN p_nombre_categoria VARCHAR(50)
)
BEGIN
    INSERT INTO categorias_productos(nombre_categoria) VALUES (p_nombre_categoria);
END $$
DELIMITER ;

CALL sp_insert_categoria_producto('frutas cítricas');
SELECT * FROM categorias_productos WHERE nombre_categoria = 'frutas cítricas';

-- 2. Insertar producto con categoría válida
DELIMITER $$
CREATE PROCEDURE sp_insert_producto(
    IN p_nombre_producto VARCHAR(100),
    IN p_id_categoria INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM categorias_productos WHERE id_categoria = p_id_categoria) THEN
        INSERT INTO productos(nombre_producto, id_categoria) VALUES (p_nombre_producto, p_id_categoria);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoría no existe';
    END IF;
END $$
DELIMITER ;

CALL sp_insert_producto('Manzana', 1);
SELECT * FROM productos WHERE nombre_producto = 'Manzana';

-- 3. Insertar parcela
DELIMITER $$
CREATE PROCEDURE sp_insert_parcela(
    IN p_nombre_parcela VARCHAR(50),
    IN p_ubicacion VARCHAR(100)
)
BEGIN
    INSERT INTO parcelas(nombre_parcela, ubicacion) VALUES (p_nombre_parcela, p_ubicacion);
END $$
DELIMITER ;

CALL sp_insert_parcela('Parcela Negra', 'Zona sureste');
SELECT * FROM parcelas WHERE nombre_parcela = 'Parcela Negra';

-- 4. Insertar producción y actualizar inventario
DELIMITER $$
CREATE PROCEDURE sp_insert_produccion(
    IN p_fecha DATE,
    IN p_id_parcela INT,
    IN p_id_producto INT,
    IN p_cantidad DECIMAL(10,2)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM parcelas WHERE id_parcela = p_id_parcela) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Parcela no existe';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
    END IF;

    INSERT INTO produccion(fecha, id_parcela, id_producto, cantidad) VALUES (p_fecha, p_id_parcela, p_id_producto, p_cantidad);

    IF EXISTS (SELECT 1 FROM inventario WHERE id_producto = p_id_producto) THEN
        UPDATE inventario SET cantidad = cantidad + p_cantidad, fecha_actualizacion = p_fecha WHERE id_producto = p_id_producto;
    ELSE
        INSERT INTO inventario(id_producto, cantidad, fecha_actualizacion) VALUES (p_id_producto, p_cantidad, p_fecha);
    END IF;
END $$
DELIMITER ;

CALL sp_insert_produccion('2025-08-10', 1, 1, 100.5);
SELECT * FROM produccion WHERE id_parcela = 1 AND id_producto = 1;
SELECT * FROM inventario WHERE id_producto = 1;

-- 5. Insertar cliente
drop procedure sp_insert_cliente;

DELIMITER $$
CREATE PROCEDURE sp_insert_cliente(
    IN p_nombre VARCHAR(100),
    IN p_direccion VARCHAR(200),
    IN p_telefono VARCHAR(20)
)
BEGIN
    INSERT INTO clientes(nombre, direccion, telefono) VALUES (p_nombre, p_direccion, p_telefono);
END $$
DELIMITER ;

CALL sp_insert_cliente('Juan Pérez', 'Calle Verdadera 123', '555-1234');
SELECT * FROM clientes WHERE nombre = 'Juan Pérez';

-- 6. Registrar venta y detalle con actualización de total
DELIMITER $$
CREATE PROCEDURE sp_insert_venta_detalle(
    IN p_id_cliente INT,
    IN p_fecha DATE,
    IN p_productos JSON -- [{"id_producto":1,"cantidad":2,"precio_unitario":50.00}, {...}]
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE i INT DEFAULT 0;
    DECLARE n INT;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE p_id_producto INT;
    DECLARE p_cantidad INT;
    DECLARE p_precio DECIMAL(10,2);

    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe';
    END IF;

    INSERT INTO ventas(id_cliente, fecha, total) VALUES (p_id_cliente, p_fecha, 0);
    SET v_id_venta = LAST_INSERT_ID();
    SET n = JSON_LENGTH(p_productos);

    WHILE i < n DO
        SET p_id_producto = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].id_producto')));
        SET p_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].cantidad')));
        SET p_precio = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].precio_unitario')));
        
        IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe en detalle venta';
        END IF;

        INSERT INTO detalle_venta(id_venta, id_producto, cantidad, precio_unitario) VALUES (v_id_venta, p_id_producto, p_cantidad, p_precio);
        SET v_total = v_total + (p_cantidad * p_precio);

        -- Actualizar inventario
        UPDATE inventario SET cantidad = cantidad - p_cantidad WHERE id_producto = p_id_producto;

        SET i = i + 1;
    END WHILE;

    UPDATE ventas SET total = v_total WHERE id_venta = v_id_venta;
END $$
DELIMITER ;

CALL sp_insert_venta_detalle(
    1,
    '2025-08-10',
    '[{"id_producto":1,"cantidad":2,"precio_unitario":50.00},{"id_producto":2,"cantidad":3,"precio_unitario":30.00}]'
);
SELECT * FROM ventas WHERE id_cliente = 1 ORDER BY id_venta DESC LIMIT 1;
SELECT * FROM detalle_venta WHERE id_venta = (SELECT MAX(id_venta) FROM ventas);
SELECT * FROM inventario WHERE id_producto IN (1,2);

-- 7. Insertar proveedor
drop procedure sp_insert_proveedor;

DELIMITER $$
CREATE PROCEDURE sp_insert_proveedor(
    IN p_nombre VARCHAR(100),
    IN p_contacto VARCHAR(100),
    IN p_telefono VARCHAR(20)
)
BEGIN
    INSERT INTO proveedores(nombre, contacto, telefono) VALUES (p_nombre, p_contacto, p_telefono);
END $$
DELIMITER ;

CALL sp_insert_proveedor('Proveedor X', 'María López', '555-9876');
SELECT * FROM proveedores WHERE nombre = 'Proveedor X';

-- 8. Registrar compra y detalles
DELIMITER $$
CREATE PROCEDURE sp_insert_compra_detalle(
    IN p_id_proveedor INT,
    IN p_fecha DATE,
    IN p_productos JSON -- [{"id_producto":1,"cantidad":5,"precio_unitario":30.00}, {...}]
)
BEGIN
    DECLARE v_id_compra INT;
    DECLARE i INT DEFAULT 0;
    DECLARE n INT;
    DECLARE p_id_producto INT;
    DECLARE p_cantidad INT;
    DECLARE p_precio DECIMAL(10,2);

    IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id_proveedor = p_id_proveedor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor no existe';
    END IF;

    INSERT INTO compras(id_proveedor, fecha) VALUES (p_id_proveedor, p_fecha);
    SET v_id_compra = LAST_INSERT_ID();
    SET n = JSON_LENGTH(p_productos);

    WHILE i < n DO
        SET p_id_producto = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].id_producto')));
        SET p_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].cantidad')));
        SET p_precio = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', i, '].precio_unitario')));

        IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe en detalle compra';
        END IF;

        INSERT INTO detalle_compra(id_compra, id_producto, cantidad, precio_unitario) VALUES (v_id_compra, p_id_producto, p_cantidad, p_precio);

        -- Actualizar inventario sumando cantidad comprada
        IF EXISTS (SELECT 1 FROM inventario WHERE id_producto = p_id_producto) THEN
            UPDATE inventario SET cantidad = cantidad + p_cantidad, fecha_actualizacion = p_fecha WHERE id_producto = p_id_producto;
        ELSE
            INSERT INTO inventario(id_producto, cantidad, fecha_actualizacion) VALUES (p_id_producto, p_cantidad, p_fecha);
        END IF;

        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

CALL sp_insert_compra_detalle(
    1,
    '2025-08-10',
    '[{"id_producto":1,"cantidad":5,"precio_unitario":25.00},{"id_producto":3,"cantidad":10,"precio_unitario":15.00}]'
);
SELECT * FROM compras WHERE id_proveedor = 1 ORDER BY id_compra DESC LIMIT 1;
SELECT * FROM detalle_compra WHERE id_compra = (SELECT MAX(id_compra) FROM compras);
SELECT * FROM inventario WHERE id_producto IN (1,3);

-- 9. Insertar estado maquinaria  --
DROP PROCEDURE IF EXISTS sp_insertar_y_asignar_estado_maquinaria;
DELIMITER $$
CREATE PROCEDURE sp_insertar_y_asignar_estado_maquinaria(
    IN p_id_maquina INT,
    IN p_estado VARCHAR(50)
)
BEGIN
    DECLARE nuevo_estado INT;

    -- Insertar nuevo estado en estado_maquinaria
    INSERT INTO estado_maquinaria(estado) VALUES (p_estado);
    SET nuevo_estado = LAST_INSERT_ID();

    -- Actualizar la máquina con el nuevo estado
    UPDATE maquinaria 
    SET id_estado = nuevo_estado
    WHERE id_maquina = p_id_maquina;

    -- Mostrar la máquina con su nuevo estado
    SELECT m.id_maquina, m.nombre_maquina, em.estado
    FROM maquinaria m
    JOIN estado_maquinaria em ON m.id_estado = em.id_estado
    WHERE m.id_maquina = p_id_maquina;
END $$
DELIMITER ;

-- Llamada al procedimiento:
CALL sp_insertar_y_asignar_estado_maquinaria(5, 'Operativa');

-- Consulta independiente para verificar:
SELECT m.id_maquina, m.nombre_maquina, e.estado
FROM maquinaria m
JOIN estado_maquinaria e ON m.id_estado = e.id_estado
WHERE m.id_maquina = 5;


DESCRIBE maquinaria;
DESCRIBE estado_maquinaria;

-- 10. Insertar maquinaria
DELIMITER $$
CREATE PROCEDURE sp_insert_maquinaria(
    IN p_id_maquina INT,
    IN p_nombre_maquina VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_id_estado INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM estado_maquinaria WHERE id_estado = p_id_estado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado maquinaria no existe';
    END IF;

    INSERT INTO maquinaria(id_maquina, nombre_maquina, descripcion, id_estado) VALUES (p_id_maquina, p_nombre_maquina, p_descripcion, p_id_estado);
END $$
DELIMITER ;

CALL sp_insert_maquinaria(21, 'Tractor Modelo X', 'Tractor para labranza', 1);
SELECT * FROM maquinaria WHERE id_maquina = 21;

-- 11. Insertar mantenimiento maquinaria y actualizar estado
drop procedure sp_insert_mantenimiento;
DELIMITER $$
CREATE PROCEDURE sp_insert_mantenimiento(
    IN p_id_maquina INT,
    IN p_fecha DATE,
    IN p_descripcion TEXT
)
BEGIN
    DECLARE estado_mantenimiento_id INT;

    -- Validar que la maquinaria exista
    IF NOT EXISTS (SELECT 1 FROM maquinaria WHERE id_maquina = p_id_maquina) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no existe';
    END IF;

    -- Insertar nuevo mantenimiento
    INSERT INTO mantenimiento(id_maquina, fecha, descripcion) 
    VALUES (p_id_maquina, p_fecha, p_descripcion);

    -- Buscar id_estado para 'En mantenimiento'
    SELECT id_estado INTO estado_mantenimiento_id 
    FROM estado_maquinaria 
    WHERE estado = 'En mantenimiento' 
    LIMIT 1;

    -- Si no existe el estado 'En mantenimiento', crearlo
    IF estado_mantenimiento_id IS NULL THEN
        INSERT INTO estado_maquinaria(estado) VALUES ('En mantenimiento');
        SET estado_mantenimiento_id = LAST_INSERT_ID();
    END IF;

    -- Actualizar estado de la maquinaria
    UPDATE maquinaria 
    SET id_estado = estado_mantenimiento_id
    WHERE id_maquina = p_id_maquina;
END $$
DELIMITER ;

CALL sp_insert_mantenimiento(2, '2025-08-10', 'Cambio de aceite y filtros');
SELECT * FROM mantenimiento WHERE id_maquina = 2 ORDER BY fecha DESC LIMIT 1;
SELECT * FROM maquinaria WHERE id_maquina = 2;

-- 12. Insertar rol empleado
DELIMITER $$
CREATE PROCEDURE sp_insert_rol_empleado(
    IN p_nombre_rol VARCHAR(50)
)
BEGIN
    INSERT INTO roles_empleados(nombre_rol) VALUES (p_nombre_rol);
END $$
DELIMITER ;

CALL sp_insert_rol_empleado('Administrador');
SELECT * FROM roles_empleados WHERE nombre_rol = 'Administrador';

-- 13. Insertar empleado y asignación
DELIMITER $$
CREATE PROCEDURE sp_insert_empleado(
    IN p_nombre VARCHAR(100),
    IN p_cedula VARCHAR(20),
    IN p_fecha_ingreso DATE,
    IN p_id_rol INT,
    IN p_id_maquina INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM roles_empleados WHERE id_rol = p_id_rol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rol empleado no existe';
    END IF;

    IF p_id_maquina IS NOT NULL AND NOT EXISTS (SELECT 1 FROM maquinaria WHERE id_maquina = p_id_maquina) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquina no existe';
    END IF;

    INSERT INTO empleados(nombre, cedula, fecha_ingreso, id_rol, id_maquina) VALUES (p_nombre, p_cedula, p_fecha_ingreso, p_id_rol, p_id_maquina);

    INSERT INTO asignaciones(id_empleado, id_maquina) VALUES (LAST_INSERT_ID(), p_id_maquina);
END $$
DELIMITER ;

CALL sp_insert_empleado('Carlos Gómez', '12345678', '2025-01-15', 1, 1);
SELECT * FROM empleados WHERE cedula = '12345678';
SELECT * FROM asignaciones WHERE id_empleado = (SELECT id_empleado FROM empleados WHERE cedula = '12345678');

-- 14. Actualizar estado de maquinaria
DELIMITER $$
CREATE PROCEDURE sp_update_estado_maquinaria(
    IN p_id_maquina INT,
    IN p_id_estado INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM maquinaria WHERE id_maquina = p_id_maquina) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estado_maquinaria WHERE id_estado = p_id_estado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado maquinaria no existe';
    END IF;

    UPDATE maquinaria SET id_estado = p_id_estado WHERE id_maquina = p_id_maquina;
END $$
DELIMITER ;

CALL sp_update_estado_maquinaria(1, 2);
SELECT m.id_maquina, m.nombre_maquina, em.estado
FROM maquinaria m
JOIN estado_maquinaria em ON m.id_estado = em.id_estado
WHERE m.id_maquina = 1;

-- 15. Actualizar cantidad de producción
DELIMITER $$
CREATE PROCEDURE sp_update_produccion_cantidad(
    IN p_id_produccion INT,
    IN p_nueva_cantidad DECIMAL(10,2)
)
BEGIN
    UPDATE produccion SET cantidad = p_nueva_cantidad WHERE id_produccion = p_id_produccion;
END $$
DELIMITER ;

CALL sp_update_produccion_cantidad(101, 150.75);
SELECT * FROM produccion WHERE id_produccion = 101;

-- 16. Actualizar información cliente
DELIMITER $$
CREATE PROCEDURE sp_update_cliente(
    IN p_id_cliente INT,
    IN p_nombre VARCHAR(100),
    IN p_direccion VARCHAR(200),
    IN p_telefono VARCHAR(20)
)
BEGIN
    UPDATE clientes SET nombre = p_nombre, direccion = p_direccion, telefono = p_telefono WHERE id_cliente = p_id_cliente;
END $$
DELIMITER ;

CALL sp_update_cliente(3, 'Juan Pérez', 'Calle Falsa 123', '555-1234567');
SELECT * FROM clientes WHERE id_cliente = 3;

-- 17. Eliminar empleado y su asignación
drop procedure sp_delete_empleado; 
DELIMITER $$
CREATE PROCEDURE sp_delete_empleado(
    IN p_id_empleado INT
)
BEGIN
    -- Validar que el empleado exista
    IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empleado no existe';
    END IF;

    -- Eliminar registros en tablas relacionadas
    DELETE FROM historial_salarios WHERE id_empleado = p_id_empleado;
    DELETE FROM asignaciones WHERE id_empleado = p_id_empleado;

    -- Eliminar empleado
    DELETE FROM empleados WHERE id_empleado = p_id_empleado;
END $$
DELIMITER ;


SELECT * FROM empleados WHERE id_empleado = 10;
CALL sp_delete_empleado(10);

-- 18. Eliminar maquinaria
drop procedure sp_delete_maquinaria;
DELIMITER $$
CREATE PROCEDURE sp_delete_maquinaria(
    IN p_id_maquina INT
)
BEGIN
    DECLARE maquina_existe INT DEFAULT 0;

    SELECT id_maquina INTO maquina_existe FROM maquinaria WHERE p_id_maquina = id_maquina;

    IF maquina_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no existe';
    ELSE
    DELETE FROM mantenimiento WHERE p_id_maquina = id_maquina;
    DELETE FROM maquinaria WHERE p_id_maquina =id_maquina;
   END IF;
END $$
DELIMITER ;

SELECT * FROM maquinaria WHERE id_maquina = 7;
CALL sp_delete_maquinaria(7);

DESCRIBE mantenimiento;
DESCRIBE asignaciones;
DESCRIBE maquinaria;


-- 19. Validar existencia de producto
DELIMITER $$
CREATE PROCEDURE sp_validar_producto(
    IN p_id_producto INT,
    OUT p_existe BOOLEAN
)
BEGIN
    SELECT EXISTS(SELECT 1 FROM productos WHERE id_producto = p_id_producto) INTO p_existe;
END $$
DELIMITER ;

SET @existe = FALSE;
CALL sp_validar_producto(1, @existe);
SELECT @existe;
CALL sp_validar_producto(100, @existe);

-- 20. Validar existencia de cliente
DELIMITER $$
CREATE PROCEDURE sp_validar_cliente(
    IN p_id_cliente INT,
    OUT p_existe BOOLEAN
)
BEGIN
    SELECT EXISTS(SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) INTO p_existe;
END $$
DELIMITER ;

SET @existe = FALSE;
CALL sp_validar_cliente(1, @existe);
CALL sp_validar_cliente(80, @existe);
SELECT @existe;