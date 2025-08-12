-- ****************************Triggers**************************
-- 1. Al insertar un detalle de venta, reducir stock en inventario
DELIMITER //
CREATE TRIGGER trg_actualizar_stock_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  UPDATE inventario SET
    cantidad = cantidad - NEW.cantidad
  WHERE id_producto = NEW.id_producto;
END;
//
DELIMITER ;

-- 2. Al eliminar un detalle de venta, aumentar stock en inventario
DELIMITER //
CREATE TRIGGER trg_revertir_stock_venta
AFTER DELETE ON detalle_venta
FOR EACH ROW
BEGIN
  UPDATE inventario SET
    cantidad = cantidad + OLD.cantidad
  WHERE id_producto = OLD.id_producto;
END;
//
DELIMITER ;

-- 3. Al insertar un detalle de compra, aumentar stock en inventario
DELIMITER //
CREATE TRIGGER trg_actualizar_stock_compra
AFTER INSERT ON detalle_compra
FOR EACH ROW
BEGIN
  UPDATE inventario SET
    cantidad = cantidad + NEW.cantidad
  WHERE id_producto = NEW.id_producto;
END;
//
DELIMITER ;

-- 4. Antes de insertar salario, validar fechas
DELIMITER //
CREATE TRIGGER trg_validar_fechas_salario
BEFORE INSERT ON historial_salarios
FOR EACH ROW
BEGIN
  IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fecha_fin no puede ser menor que fecha_inicio';
  END IF;
END;
//
DELIMITER ;

-- 5. Al actualizar salario de empleado, insertar registro en historial_salarios
DELIMITER //
CREATE TRIGGER trg_registrar_cambio_salario
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
  IF OLD.salario != NEW.salario THEN
    INSERT INTO historial_salarios (id_empleado, salario, fecha_inicio)
    VALUES (NEW.id_empleado, NEW.salario, CURDATE());
  END IF;
END;
//
DELIMITER ;

-- 6. Antes de asignar maquinaria a tarea, verificar estado = 1 (disponible)
DELIMITER //
CREATE TRIGGER trg_verificar_maquinaria_disponible
BEFORE INSERT ON tareas
FOR EACH ROW
BEGIN
  DECLARE estado_maquina INT;
  SELECT id_estado INTO estado_maquina FROM maquinaria WHERE id_maquina = NEW.id_maquina;
  IF estado_maquina != 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maquinaria no disponible para asignar';
  END IF;
END;
//
DELIMITER ;

-- 7. Al insertar mantenimiento, actualizar estado maquinaria a 2 (en mantenimiento)
DELIMITER //
CREATE TRIGGER trg_cambiar_estado_mantenimiento
AFTER INSERT ON mantenimiento
FOR EACH ROW
BEGIN
  UPDATE maquinaria SET id_estado = 2 WHERE id_maquina = NEW.id_maquina;
END;
//
DELIMITER ;

-- 8. Al actualizar mantenimiento con fecha_fin, cambiar estado maquinaria a 1 (disponible)
DELIMITER //
CREATE TRIGGER trg_finalizar_mantenimiento
AFTER UPDATE ON mantenimiento
FOR EACH ROW
BEGIN
  IF OLD.fecha IS NOT NULL AND NEW.fecha IS NOT NULL AND OLD.fecha <> NEW.fecha THEN
    -- No hacemos nada con fecha, pero revisamos fecha_fin si existiera
    -- Tu tabla no tiene fecha_fin, si agregas ajustamos
  END IF;
  -- Como no hay fecha_fin, este trigger podría omitirse o ajustarse según diseño
END;
//
DELIMITER ;

-- 9. Al insertar producción, actualiza total produccion en parcela (se asume columna existe)
DELIMITER //
CREATE TRIGGER trg_actualizar_produccion_parcela
AFTER INSERT ON produccion
FOR EACH ROW
BEGIN
  UPDATE parcelas SET total_produccion = IFNULL(total_produccion, 0) + NEW.cantidad WHERE id_parcela = NEW.id_parcela;
END;
//
DELIMITER ;

-- 10. Al eliminar producción, reduce total produccion en parcela
DELIMITER //
CREATE TRIGGER trg_reducir_produccion_parcela
AFTER DELETE ON produccion
FOR EACH ROW
BEGIN
  UPDATE parcelas SET total_produccion = IFNULL(total_produccion, 0) - OLD.cantidad WHERE id_parcela = OLD.id_parcela;
END;
//
DELIMITER ;

-- 11. Al actualizar producción, ajusta total produccion en parcela
DELIMITER //
CREATE TRIGGER trg_ajustar_produccion_parcela
AFTER UPDATE ON produccion
FOR EACH ROW
BEGIN
  UPDATE parcelas SET total_produccion = IFNULL(total_produccion, 0) - OLD.cantidad + NEW.cantidad WHERE id_parcela = NEW.id_parcela;
END;
//
DELIMITER ;

-- 12. Antes de insertar cliente, validar teléfono 10 dígitos
DELIMITER //
CREATE TRIGGER trg_validar_telefono_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
  IF LENGTH(NEW.telefono) != 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefono debe tener 10 digitos';
  END IF;
END;
//
DELIMITER ;

-- 13. Antes de insertar venta, validar que cliente exista
DELIMITER //
CREATE TRIGGER trg_validar_cliente_venta
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN
  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = NEW.id_cliente) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe';
  END IF;
END;
//
DELIMITER ;

-- 14. Al insertar producto, inicializar stock en inventario si no existe
DELIMITER //
CREATE TRIGGER trg_inicializar_stock_producto
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
  INSERT INTO inventario (id_producto, cantidad, fecha_actualizacion)
  VALUES (NEW.id_producto, 0, CURDATE());
END;
//
DELIMITER ;

-- 15. Antes de insertar proveedor, validar teléfono 10 dígitos
DELIMITER //
CREATE TRIGGER trg_validar_telefono_proveedor
BEFORE INSERT ON proveedores
FOR EACH ROW
BEGIN
  IF LENGTH(NEW.telefono) != 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefono de proveedor debe tener 10 digitos';
  END IF;
END;
//
DELIMITER ;

-- 16. Al insertar un nuevo empleado, asignar automáticamente un rol predeterminado si no se especifica uno
sql
Copiar código
DELIMITER //
CREATE TRIGGER trg_asignar_rol_por_defecto_empleado
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
  IF NEW.id_rol IS NULL THEN
    SET NEW.id_rol = 1;
  END IF;
END;
//
DELIMITER ;

-- 17. Al eliminar tarea, liberar maquinaria (id_estado=1)
DELIMITER //
CREATE TRIGGER trg_liberar_maquinaria_tarea
AFTER DELETE ON tareas
FOR EACH ROW
BEGIN
  UPDATE maquinaria SET id_estado = 1 WHERE id_maquina = OLD.id_maquina;
END;
//
DELIMITER ;

-- 18. Antes de actualizar maquinaria a estado retirada (3), verificar no asignada a tareas activas
DELIMITER //
CREATE TRIGGER trg_validar_maquinaria_retirada
BEFORE UPDATE ON maquinaria
FOR EACH ROW
BEGIN
  IF NEW.id_estado = 3 THEN
    IF EXISTS (SELECT 1 FROM tareas WHERE id_maquina = NEW.id_maquina AND estado = 'activa') THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puede retirar maquinaria asignada a tarea activa';
    END IF;
  END IF;
END;
//
DELIMITER ;

-- 19. Antes de insertar detalle_venta, validar que cantidad no exceda stock en inventario
DELIMITER //
CREATE TRIGGER trg_validar_cantidad_pedido
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
  DECLARE stock_actual DECIMAL(10,2);
  SELECT cantidad INTO stock_actual FROM inventario WHERE id_producto = NEW.id_producto;
  IF NEW.cantidad > stock_actual THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad solicitada excede stock disponible';
  END IF;
END;
//
DELIMITER ;

-- 20. Antes de insertar consumo_insumos, validar cantidad positiva (si tienes tabla consumo_insumos)
DELIMITER //
CREATE TRIGGER trg_validar_consumo_insumos
BEFORE INSERT ON consumo_insumos
FOR EACH ROW
BEGIN
  IF NEW.cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad de insumos debe ser positiva';
  END IF;
END;
//
DELIMITER ;

-- 1. Insertar detalle_venta para activar trigger de actualización stock venta
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (1, 10, 5, 15000);

-- 2. Eliminar detalle_venta para activar trigger de revertir stock venta
DELETE FROM detalle_venta WHERE id_detalle = 5;

-- 3. Insertar detalle_compra para activar trigger de actualización stock compra
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario) VALUES (1, 10, 20, 13000);

-- 4. Insertar historial_salarios para validar fechas
INSERT INTO historial_salarios (id_empleado, salario, fecha_inicio, fecha_fin) VALUES (7, 2000000, '2025-01-01', '2025-12-31');

-- 5. Actualizar salario de empleado para insertar registro en historial_salarios
UPDATE empleados SET salario = 2500000 WHERE id_empleado = 7;

-- 6. Insertar tarea para verificar disponibilidad maquinaria
INSERT INTO tareas (descripcion, id_maquina, estado) VALUES ('Laboreo parcela 3', 4, 'pendiente');

-- 7. Insertar mantenimiento para cambiar estado de maquinaria
INSERT INTO mantenimiento (id_maquina, fecha, descripcion) VALUES (4, '2025-08-10', 'Mantenimiento preventivo');

-- 8. Actualizar mantenimiento para indicar fecha_fin y liberar maquinaria
UPDATE mantenimiento SET fecha = '2025-08-15' WHERE id_mantenimiento = 3;

-- 9. Insertar producción para actualizar total producida en parcela
INSERT INTO produccion (fecha, id_parcela, id_producto, cantidad) VALUES ('2025-07-01', 3, 10, 100);

-- 10. Eliminar producción para reducir total producida en parcela
DELETE FROM produccion WHERE id_produccion = 12;

-- 11. Actualizar producción para ajustar total producida en parcela
UPDATE produccion SET cantidad = 120 WHERE id_produccion = 13;

-- 12. Insertar cliente con teléfono válido (o inválido para probar error)
INSERT INTO clientes (nombre, telefono) VALUES ('Juan Pérez', '3011234567');

-- 13. Insertar venta con cliente válido (o inválido para probar error)
INSERT INTO ventas (id_cliente, fecha, total) VALUES (15, '2025-08-10', 450000);

-- 14. Insertar producto (inicializa stock en 0)
INSERT INTO productos (nombre_producto, id_categoria) VALUES ('Tomate', 1);

-- 15. Insertar proveedor con teléfono válido (o inválido)
INSERT INTO proveedores (nombre, telefono) VALUES ('Proveedor Uno', '3127654321');

-- 16. (Opcional) --- omitido por falta de tabla de asistencia ---

-- 17. Eliminar tarea para liberar maquinaria
DELETE FROM tareas WHERE id_asignacion = 7;

-- 18. Actualizar estado maquinaria a retirada para validar que no esté asignada
UPDATE maquinaria SET id_estado = 3 WHERE id_maquina = 4;

-- 19. Insertar detalle_venta con cantidad mayor al stock para validar error
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (2, 10, 1000, 15000);

-- 20. Insertar consumo_insumos con cantidad válida (o inválida para error)
INSERT INTO consumo_insumos (id_producto, id_insumo, cantidad, costo_unitario) VALUES (10, 3, 5, 1200);
