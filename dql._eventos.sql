-- 1. Generar reporte mensual de ventas
CREATE EVENT reporte_mensual_ventas
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO reportes_ventas (mes, ano, total_ventas)
  SELECT MONTH(fecha), YEAR(fecha), SUM(monto) FROM ventas
  WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
END;

-- 2. Generar reporte mensual de producción
CREATE EVENT reporte_mensual_produccion
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO reportes_produccion (mes, ano, total_produccion)
  SELECT MONTH(fecha), YEAR(fecha), SUM(cantidad) FROM producciones
  WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
END;

-- 3. Actualizar inventario al finalizar jornada
CREATE EVENT actualizar_inventario_diario
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  -- ejemplo: descontar productos vendidos del inventario
  UPDATE inventarios i
  JOIN (
    SELECT id_producto, SUM(cantidad) AS vendida
    FROM ventas_detalle
    WHERE fecha_venta = CURDATE()
    GROUP BY id_producto
  ) v ON i.id_producto = v.id_producto
  SET i.cantidad = i.cantidad - v.vendida;
END;

-- 4. Actualizar salarios de empleados anualmente con incremento
CREATE EVENT ajuste_salario_anual
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE empleados
  SET salario = salario * 1.05; -- Incremento 5%
END;

-- 5. Limpiar registros antiguos de logs cada 6 meses
CREATE EVENT limpiar_logs
ON SCHEDULE EVERY 6 MINUTE STARTS NOW()
DO
BEGIN
  DELETE FROM logs WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
END;

-- 6. Actualizar estado de maquinaria inactiva (más de 1 año sin uso)
CREATE EVENT actualizar_estado_maquinaria
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE maquinaria
  SET id_estado = 4 -- Estado: Inactiva
  WHERE DATEDIFF(CURDATE(), ultima_actividad) > 365;
END;

-- 7. Generar alertas de stock bajo en inventario
CREATE EVENT alerta_stock_bajo
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO alertas (tipo, mensaje, fecha)
  SELECT 'Stock bajo', CONCAT('Producto ', nombre_producto, ' con inventario bajo'), NOW()
  FROM inventarios
  JOIN productos ON inventarios.id_producto = productos.id_producto
  WHERE cantidad < minimo_requerido;
END;

-- 8. Actualizar costos operativos mensuales
CREATE EVENT calcular_costos_operativos
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO costos_operativos (mes, ano, total)
  SELECT MONTH(fecha), YEAR(fecha), SUM(monto) FROM gastos
  WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
END;

-- 9. Archivar ventas antiguas mayores a 2 años
CREATE EVENT archivar_ventas_antiguas
ON SCHEDULE EVERY 3 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO ventas_archivo SELECT * FROM ventas WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
  DELETE FROM ventas WHERE fecha < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
END;

-- 10. Actualizar estado de parcelas según cosecha
CREATE EVENT actualizar_estado_parcelas
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE parcelas p
  JOIN producciones pr ON p.id_parcela = pr.id_parcela
  SET p.estado = 'Cosechada'
  WHERE pr.fecha BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE();
END;

-- 11. Reiniciar contador de tareas diarias para empleados
CREATE EVENT reset_contador_tareas
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE empleados SET tareas_completadas = 0;
END;

-- 12. Actualizar indicadores agrícolas mensuales
CREATE EVENT actualizar_indicadores_agricolas
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  -- Ejemplo cálculo simple
  UPDATE indicadores SET valor = (SELECT AVG(rendimiento) FROM producciones WHERE MONTH(fecha) = MONTH(CURDATE()) AND YEAR(fecha) = YEAR(CURDATE()))
  WHERE nombre_indicador = 'Rendimiento Promedio';
END;

-- 13. Enviar recordatorios a empleados (simulado con inserción)
CREATE EVENT recordatorio_empleados
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO mensajes_empleados (id_empleado, mensaje, fecha)
  SELECT id_empleado, 'Recuerda completar tu reporte semanal', NOW()
  FROM empleados;
END;

-- 14. Actualizar inventario de insumos desde proveedores cada semana
CREATE EVENT actualizar_inventario_insumos
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE inventarios i
  JOIN compras c ON i.id_insumo = c.id_insumo
  SET i.cantidad = i.cantidad + c.cantidad
  WHERE c.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK);
END;

-- 15. Respaldo automático de tabla crítica (simplificado)
CREATE EVENT respaldo_automatico
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  CREATE TABLE IF NOT EXISTS ventas_backup LIKE ventas;
  INSERT INTO ventas_backup SELECT * FROM ventas WHERE fecha = CURDATE();
END;

-- 16. Eliminar productos descontinuados sin stock
CREATE EVENT eliminar_productos_descontinuados
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  DELETE FROM productos WHERE estado = 'Descontinuado' AND id_producto NOT IN (SELECT id_producto FROM inventarios WHERE cantidad > 0);
END;

-- 17. Actualizar estado de empleados (ejemplo: cambiar a inactivo si sin labores 3 meses)
CREATE EVENT actualizar_estado_empleados
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE empleados
  SET estado = 'Inactivo'
  WHERE DATEDIFF(CURDATE(), ultima_actividad) > 90;
END;

-- 18. Calcular rendimiento promedio anual de cultivos
CREATE EVENT rendimiento_promedio_anual
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO indicadores (nombre_indicador, valor, fecha)
  SELECT 'Rendimiento Anual', AVG(cantidad), NOW() FROM producciones WHERE YEAR(fecha) = YEAR(CURDATE());
END;

-- 19. Actualizar datos de proveedores
CREATE EVENT actualizar_proveedores
ON SCHEDULE EVERY 3 MINUTE STARTS NOW()
DO
BEGIN
  UPDATE proveedores SET estado = 'Verificado' WHERE fecha_verificacion < DATE_SUB(CURDATE(), INTERVAL 3 MONTH);
END;

-- 20. Notificar pagos vencidos (simulado con inserción)
CREATE EVENT notificar_pagos_vencidos
ON SCHEDULE EVERY 1 MINUTE STARTS NOW()
DO
BEGIN
  INSERT INTO alertas (tipo, mensaje, fecha)
  SELECT 'Pago vencido', CONCAT('Pago pendiente de cliente ', nombre_cliente), NOW()
  FROM clientes c
  JOIN pagos p ON c.id_cliente = p.id_cliente
  WHERE p.fecha_vencimiento < CURDATE() AND p.estado = 'Pendiente';
END;