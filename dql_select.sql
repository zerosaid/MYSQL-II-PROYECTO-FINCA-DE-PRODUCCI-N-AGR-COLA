-- 1. Listar todos los productos con su categoría
SELECT p.id_producto, p.nombre_producto, c.nombre_categoria
FROM productos p
LEFT JOIN categorias_productos c ON p.id_categoria = c.id_categoria;

-- 2. Mostrar todos los clientes
SELECT id_cliente, nombre, direccion, telefono
FROM clientes;

-- 3. Obtener todas las parcelas
SELECT id_parcela, nombre_parcela, ubicacion
FROM parcelas;

-- 4. Ver el inventario actual con nombre del producto
SELECT i.id_inventario, p.nombre_producto, i.cantidad, i.fecha_actualizacion
FROM inventario i
JOIN productos p ON i.id_producto = p.id_producto;

-- 5. Ventas con nombre del cliente
SELECT v.id_venta, c.nombre AS cliente, v.fecha, v.total
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente;

-- 6. Detalle de venta con nombre del producto
SELECT dv.id_detalle, v.id_venta, p.nombre_producto, dv.cantidad, dv.precio_unitario
FROM detalle_venta dv
JOIN ventas v ON dv.id_venta = v.id_venta
JOIN productos p ON dv.id_producto = p.id_producto;

-- 7. Compras con nombre del proveedor
SELECT co.id_compra, pr.nombre AS proveedor, co.fecha
FROM compras co
JOIN proveedores pr ON co.id_proveedor = pr.id_proveedor;

-- 8. Detalle de compra con nombre de producto
SELECT dc.id_detalle, co.id_compra, p.nombre_producto, dc.cantidad
FROM detalle_compra dc
JOIN compras co ON dc.id_compra = co.id_compra
JOIN productos p ON dc.id_producto = p.id_producto;

-- 9. Producción con nombre de parcela y producto
SELECT pr.id_produccion, pr.fecha, pa.nombre_parcela, p.nombre_producto, pr.cantidad
FROM produccion pr
JOIN parcelas pa ON pr.id_parcela = pa.id_parcela
JOIN productos p ON pr.id_producto = p.id_producto;

-- 10. Máquinas con estado
SELECT m.id_maquina, m.nombre_maquina, m.descripcion, e.estado
FROM maquinaria m
JOIN estado_maquinaria e ON m.id_estado = e.id_estado;

-- 11. Mantenimientos con máquina
SELECT mt.id_mantenimiento, m.nombre_maquina, mt.fecha, mt.descripcion
FROM mantenimiento mt
JOIN maquinaria m ON mt.id_maquina = m.id_maquina;

-- 12. Empleados con rol
SELECT e.id_empleado, e.nombre, e.cedula, e.fecha_ingreso, r.nombre_rol
FROM empleados e
JOIN roles_empleados r ON e.id_rol = r.id_rol;

-- 13. Asignaciones de empleados a maquinaria
SELECT a.id_asignacion, e.nombre AS empleado, m.nombre_maquina, a.fecha_asignacion
FROM asignaciones a
JOIN empleados e ON a.id_empleado = e.id_empleado
JOIN maquinaria m ON a.id_maquina = m.id_maquina;

-- 14. Historial de salarios de empleados
SELECT h.id_historial, e.nombre AS empleado, h.salario, h.fecha_inicio, h.fecha_fin
FROM historial_salarios h
JOIN empleados e ON h.id_empleado = e.id_empleado;

-- 15. Usuarios del sistema con su rol
SELECT u.id_usuario, u.nombre_usuario, r.nombre_rol
FROM usuarios u
JOIN roles_sistema r ON u.id_rol = r.id_rol;

-- 16. Permisos por rol
SELECT p.id_permiso, r.nombre_rol, p.descripcion
FROM permisos p
JOIN roles_sistema r ON p.id_rol = r.id_rol;

-- 17. Productos sin categoría asignada
SELECT id_producto, nombre_producto
FROM productos
WHERE id_categoria IS NULL;

-- 18. Clientes sin ventas registradas
SELECT c.id_cliente, c.nombre
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- 19. Productos sin movimientos de inventario
SELECT p.id_producto, p.nombre_producto
FROM productos p
LEFT JOIN inventario i ON p.id_producto = i.id_producto
WHERE i.id_inventario IS NULL;

-- 20. Empleados sin asignaciones de maquinaria
SELECT e.id_empleado, e.nombre
FROM empleados e
LEFT JOIN asignaciones a ON e.id_empleado = a.id_empleado
WHERE a.id_asignacion IS NULL;

-- 21. Ventas realizadas en el último mes
SELECT v.id_venta, c.nombre AS cliente, v.fecha, v.total
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE v.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- 22. Compras realizadas en el último mes
SELECT co.id_compra, pr.nombre AS proveedor, co.fecha
FROM compras co
JOIN proveedores pr ON co.id_proveedor = pr.id_proveedor
WHERE co.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- 23. Producción total por producto
SELECT p.nombre_producto, SUM(pr.cantidad) AS total_producido
FROM produccion pr
JOIN productos p ON pr.id_producto = p.id_producto
GROUP BY p.nombre_producto;

-- 24. Producción total por parcela
SELECT pa.nombre_parcela, SUM(pr.cantidad) AS total_producido
FROM produccion pr
JOIN parcelas pa ON pr.id_parcela = pa.id_parcela
GROUP BY pa.nombre_parcela;

-- 25. Inventario ordenado por cantidad descendente
SELECT p.nombre_producto, i.cantidad
FROM inventario i
JOIN productos p ON i.id_producto = p.id_producto
ORDER BY i.cantidad DESC;

-- 26. Clientes que han comprado más de 1000 en total
SELECT c.id_cliente, c.nombre, SUM(v.total) AS total_comprado
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING SUM(v.total) > 1000;

-- 27. Proveedores con más de 5 compras registradas
SELECT pr.id_proveedor, pr.nombre, COUNT(co.id_compra) AS total_compras
FROM proveedores pr
JOIN compras co ON pr.id_proveedor = co.id_proveedor
GROUP BY pr.id_proveedor, pr.nombre
HAVING COUNT(co.id_compra) > 5;

-- 28. Producto más producido
SELECT p.nombre_producto, SUM(pr.cantidad) AS total_producido
FROM produccion pr
JOIN productos p ON pr.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY total_producido DESC
LIMIT 1;

-- 29. Parcela con mayor producción total
SELECT pa.nombre_parcela, SUM(pr.cantidad) AS total_producido
FROM produccion pr
JOIN parcelas pa ON pr.id_parcela = pa.id_parcela
GROUP BY pa.nombre_parcela
ORDER BY total_producido DESC
LIMIT 1;

-- 30. Empleados con más de 2 asignaciones de maquinaria
SELECT e.id_empleado, e.nombre, COUNT(a.id_asignacion) AS total_asignaciones
FROM empleados e
JOIN asignaciones a ON e.id_empleado = a.id_empleado
GROUP BY e.id_empleado, e.nombre
HAVING COUNT(a.id_asignacion) > 2;

-- 31. Máquinas que no tienen mantenimientos registrados
SELECT m.id_maquina, m.nombre_maquina
FROM maquinaria m
LEFT JOIN mantenimiento mt ON m.id_maquina = mt.id_maquina
WHERE mt.id_mantenimiento IS NULL;

-- 32. Empleados con salario actual (último registro)
SELECT e.id_empleado, e.nombre, hs.salario
FROM empleados e
JOIN historial_salarios hs ON e.id_empleado = hs.id_empleado
WHERE hs.fecha_fin IS NULL;

-- 33. Total de ventas por mes
SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, SUM(total) AS total_ventas
FROM ventas
GROUP BY DATE_FORMAT(fecha, '%Y-%m')
ORDER BY mes DESC;

-- 34. Total de compras por mes
SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, COUNT(*) AS total_compras
FROM compras
GROUP BY DATE_FORMAT(fecha, '%Y-%m')
ORDER BY mes DESC;

-- 35. Productos más vendidos (por cantidad)
SELECT p.nombre_producto, SUM(dv.cantidad) AS total_vendido
FROM detalle_venta dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY total_vendido DESC;

-- 36. Clientes con más compras (número de ventas)
SELECT c.nombre, COUNT(v.id_venta) AS numero_compras
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.nombre
ORDER BY numero_compras DESC;

-- 37. Proveedores que han vendido más productos (sumatoria de cantidades en detalle_compra)
SELECT pr.nombre, SUM(dc.cantidad) AS total_productos
FROM proveedores pr
JOIN compras co ON pr.id_proveedor = co.id_proveedor
JOIN detalle_compra dc ON co.id_compra = dc.id_compra
GROUP BY pr.nombre
ORDER BY total_productos DESC;

-- 38. Ventas con más de 3 productos diferentes
SELECT v.id_venta, c.nombre AS cliente, COUNT(DISTINCT dv.id_producto) AS productos_diferentes
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY v.id_venta, c.nombre
HAVING productos_diferentes > 3;

-- 39. Compras con más de 100 unidades totales
SELECT co.id_compra, pr.nombre AS proveedor, SUM(dc.cantidad) AS total_unidades
FROM compras co
JOIN proveedores pr ON co.id_proveedor = pr.id_proveedor
JOIN detalle_compra dc ON co.id_compra = dc.id_compra
GROUP BY co.id_compra, pr.nombre
HAVING total_unidades > 100;

-- 40. Ventas de un producto específico (ejemplo: id_producto = 1)
SELECT v.id_venta, c.nombre AS cliente, dv.cantidad, dv.precio_unitario
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
WHERE dv.id_producto = 1;

-- 41. Inventario por categoría de producto
SELECT cp.nombre_categoria, SUM(i.cantidad) AS total_en_inventario
FROM inventario i
JOIN productos p ON i.id_producto = p.id_producto
JOIN categorias_productos cp ON p.id_categoria = cp.id_categoria
GROUP BY cp.nombre_categoria;

-- 42. Empleados con rol específico (ejemplo: 'Agricultor')
SELECT e.id_empleado, e.nombre, r.nombre_rol
FROM empleados e
JOIN roles_empleados r ON e.id_rol = r.id_rol
WHERE r.nombre_rol = 'Agricultor';

-- 43. Producción promedio por parcela
SELECT pa.nombre_parcela, AVG(pr.cantidad) AS promedio_produccion
FROM produccion pr
JOIN parcelas pa ON pr.id_parcela = pa.id_parcela
GROUP BY pa.nombre_parcela;

-- 44. Empleados con más de un rol en el sistema (si existiera duplicidad en usuarios)
SELECT e.id_empleado, e.nombre, COUNT(DISTINCT u.id_rol) AS roles_diferentes
FROM empleados e
JOIN usuarios u ON e.nombre = u.nombre_usuario
GROUP BY e.id_empleado, e.nombre
HAVING roles_diferentes > 1;

-- 45. Productos sin producción registrada
SELECT p.id_producto, p.nombre_producto
FROM productos p
LEFT JOIN produccion pr ON p.id_producto = pr.id_producto
WHERE pr.id_produccion IS NULL;

-- 46. Clientes que no han realizado compras
SELECT c.id_cliente, c.nombre
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- 47. Proveedores sin compras registradas
SELECT pr.id_proveedor, pr.nombre
FROM proveedores pr
LEFT JOIN compras co ON pr.id_proveedor = co.id_proveedor
WHERE co.id_compra IS NULL;

-- 48. Máquinas con estado "En reparación"
SELECT m.id_maquina, m.nombre_maquina
FROM maquinaria m
JOIN estado_maquinaria em ON m.id_estado = em.id_estado
WHERE em.estado = 'En reparación';

-- 49. Empleados y su salario más alto registrado
SELECT e.id_empleado, e.nombre, MAX(hs.salario) AS salario_maximo
FROM empleados e
JOIN historial_salarios hs ON e.id_empleado = hs.id_empleado
GROUP BY e.id_empleado, e.nombre;

-- 50. Total de mantenimiento por máquina
SELECT m.nombre_maquina, COUNT(mt.id_mantenimiento) AS total_mantenimientos
FROM maquinaria m
JOIN mantenimiento mt ON m.id_maquina = mt.id_maquina
GROUP BY m.nombre_maquina;

-- 51. Ventas en las que se vendió más de 500 en total
SELECT id_venta, fecha, total
FROM ventas
WHERE total > 500;

-- 52. Compras realizadas a un proveedor específico (id_proveedor = 1)
SELECT co.id_compra, co.fecha
FROM compras co
WHERE co.id_proveedor = 1;

-- 53. Producción total por año
SELECT YEAR(fecha) AS anio, SUM(cantidad) AS total_producido
FROM produccion
GROUP BY YEAR(fecha);

-- 54. Ventas totales por año
SELECT YEAR(fecha) AS anio, SUM(total) AS total_ventas
FROM ventas
GROUP BY YEAR(fecha);

-- 55. Empleados con asignaciones en el último mes
SELECT e.id_empleado, e.nombre, COUNT(a.id_asignacion) AS asignaciones_recientes
FROM empleados e
JOIN asignaciones a ON e.id_empleado = a.id_empleado
WHERE a.fecha_asignacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY e.id_empleado, e.nombre;

-- 56. Máquinas sin asignación a empleados
SELECT m.id_maquina, m.nombre_maquina
FROM maquinaria m
LEFT JOIN asignaciones a ON m.id_maquina = a.id_maquina
WHERE a.id_asignacion IS NULL;

-- 57. Promedio de productos por venta
SELECT AVG(productos_por_venta) AS promedio
FROM (
    SELECT COUNT(dv.id_producto) AS productos_por_venta
    FROM detalle_venta dv
    GROUP BY dv.id_venta
) AS sub;

-- 58. Productos con inventario inferior a 10 unidades
SELECT p.nombre_producto, i.cantidad
FROM inventario i
JOIN productos p ON i.id_producto = p.id_producto
WHERE i.cantidad < 10;

-- 59. Empleados con más de un salario registrado
SELECT e.id_empleado, e.nombre, COUNT(hs.id_historial) AS registros_salario
FROM empleados e
JOIN historial_salarios hs ON e.id_empleado = hs.id_empleado
GROUP BY e.id_empleado, e.nombre
HAVING registros_salario > 1;

-- 60. Roles de sistema y número de usuarios asignados
SELECT rs.nombre_rol, COUNT(u.id_usuario) AS total_usuarios
FROM roles_sistema rs
LEFT JOIN usuarios u ON rs.id_rol = u.id_rol
GROUP BY rs.nombre_rol;

-- 61. Productos cuyo precio (tomado de ventas) sea mayor al promedio de precios de venta
SELECT p.nombre_producto, AVG(dv.precio_unitario) AS precio_promedio
FROM productos p
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre_producto
HAVING AVG(dv.precio_unitario) > (SELECT AVG(precio_unitario) FROM detalle_venta);

-- 62. Clientes que han realizado al menos una venta
SELECT DISTINCT c.nombre
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente;

-- 63. Productos que nunca han sido vendidos
SELECT p.nombre_producto
FROM productos p
LEFT JOIN detalle_venta dv ON p.id_producto = dv.id_producto
WHERE dv.id_detalle IS NULL;

-- 64. Productos que han sido comprados pero no vendidos
SELECT p.nombre_producto
FROM productos p
WHERE p.id_producto IN (SELECT dc.id_producto FROM detalle_compra dc)
  AND p.id_producto NOT IN (SELECT dv.id_producto FROM detalle_venta dv);

-- 65. Empleados que tienen asignaciones (se usa 'asignaciones' porque no existe 'tareas' en el esquema)
SELECT DISTINCT e.nombre
FROM empleados e
JOIN asignaciones a ON e.id_empleado = a.id_empleado;

-- 66. Empleados que no tienen asignaciones
SELECT e.nombre
FROM empleados e
LEFT JOIN asignaciones a ON e.id_empleado = a.id_empleado
WHERE a.id_asignacion IS NULL;

-- 67. Parcelas con producción superior al promedio por parcela
SELECT pa.nombre_parcela
FROM parcelas pa
JOIN (
    SELECT id_parcela, SUM(cantidad) AS total_parcela
    FROM produccion
    GROUP BY id_parcela
) t ON pa.id_parcela = t.id_parcela
WHERE t.total_parcela > (
    SELECT AVG(total_parcela) FROM (
        SELECT SUM(cantidad) AS total_parcela FROM produccion GROUP BY id_parcela
    ) AS sub
);

-- 68. Proveedores con compras (unidades) superiores a 1,000,000
-- Nota: detalle_compra no tiene precio, por eso aquí se usa suma de unidades.
SELECT pr.nombre, SUM(dc.cantidad) AS total_unidades
FROM proveedores pr
JOIN compras c ON pr.id_proveedor = c.id_proveedor
JOIN detalle_compra dc ON c.id_compra = dc.id_compra
GROUP BY pr.id_proveedor, pr.nombre
HAVING SUM(dc.cantidad) > 1000000;

-- 69. Clientes con gasto total (ventas) mayor al promedio entre clientes
SELECT c.nombre
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY c.id_cliente, c.nombre
HAVING SUM(dv.cantidad * dv.precio_unitario) > (
  SELECT AVG(total_gastado) FROM (
    SELECT v2.id_cliente, SUM(dv2.cantidad * dv2.precio_unitario) AS total_gastado
    FROM ventas v2
    JOIN detalle_venta dv2 ON v2.id_venta = dv2.id_venta
    GROUP BY v2.id_cliente
  ) AS sub
);

-- 70. Productos cuyo precio promedio de venta es mayor al promedio de su categoría
SELECT p.nombre_producto, AVG(dv.precio_unitario) AS precio_promedio
FROM productos p
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre_producto, p.id_categoria
HAVING AVG(dv.precio_unitario) > (
    SELECT AVG(dv2.precio_unitario)
    FROM productos p2
    JOIN detalle_venta dv2 ON p2.id_producto = dv2.id_producto
    WHERE p2.id_categoria = p.id_categoria
);

-- 71. Empleados que manejan maquinaria en estado 'Operativo'
SELECT DISTINCT e.nombre
FROM empleados e
JOIN asignaciones a ON e.id_empleado = a.id_empleado
JOIN maquinaria m ON a.id_maquina = m.id_maquina
JOIN estado_maquinaria em ON m.id_estado = em.id_estado
WHERE em.estado = 'Operativo';

-- 72. Productos con producción en más de una parcela
SELECT p.nombre_producto
FROM productos p
JOIN (
    SELECT id_producto
    FROM produccion
    GROUP BY id_producto
    HAVING COUNT(DISTINCT id_parcela) > 1
) t ON p.id_producto = t.id_producto;

-- 73. Clientes que han comprado todos los productos de la categoría 'Fruta'
SELECT c.nombre
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM productos p
    WHERE p.id_categoria = (SELECT id_categoria FROM categorias_productos WHERE nombre_categoria = 'Fruta')
      AND p.id_producto NOT IN (
          SELECT dv.id_producto
          FROM ventas v
          JOIN detalle_venta dv ON v.id_venta = dv.id_venta
          WHERE v.id_cliente = c.id_cliente
      )
);

-- 74. Empleados cuyo salario actual (historial_salarios.fecha_fin IS NULL) sea mayor que el salario promedio actual
-- Nota: la tabla empleados no tiene 'ciudad', por eso se compara contra el promedio global de salarios actuales.
SELECT e.nombre, hs.salario
FROM empleados e
JOIN historial_salarios hs ON e.id_empleado = hs.id_empleado
WHERE hs.fecha_fin IS NULL
  AND hs.salario > (
      SELECT AVG(hs2.salario) FROM historial_salarios hs2 WHERE hs2.fecha_fin IS NULL
  );

-- 75. Clientes que han comprado el producto con mayor precio_unitario registrado en ventas
SELECT DISTINCT c.nombre
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
WHERE dv.id_producto = (
    SELECT id_producto FROM detalle_venta ORDER BY precio_unitario DESC LIMIT 1
);

-- 76. Parcelas que producen el producto más vendido (por cantidad)
SELECT DISTINCT pa.nombre_parcela
FROM parcelas pa
JOIN produccion pr ON pa.id_parcela = pr.id_parcela
WHERE pr.id_producto = (
    SELECT id_producto FROM detalle_venta GROUP BY id_producto ORDER BY SUM(cantidad) DESC LIMIT 1
);

-- 77. Proveedores que suministran el producto más comprado (por unidades)
SELECT DISTINCT prov.nombre
FROM proveedores prov
JOIN compras c ON prov.id_proveedor = c.id_proveedor
JOIN detalle_compra dc ON c.id_compra = dc.id_compra
WHERE dc.id_producto = (
    SELECT id_producto FROM detalle_compra GROUP BY id_producto ORDER BY SUM(cantidad) DESC LIMIT 1
);

-- 78. Productos cuya producción total es mayor que la venta total
SELECT p.nombre_producto
FROM productos p
JOIN (
    SELECT id_producto, SUM(cantidad) AS total_producido
    FROM produccion
    GROUP BY id_producto
) prd ON p.id_producto = prd.id_producto
LEFT JOIN (
    SELECT id_producto, SUM(cantidad) AS total_vendido
    FROM detalle_venta
    GROUP BY id_producto
) ven ON p.id_producto = ven.id_producto
WHERE prd.total_producido > IFNULL(ven.total_vendido, 0);

-- 79. Clientes que solo han comprado un producto distinto (en total)
SELECT c.nombre
FROM clientes c
JOIN ventas v ON c.id_cliente = v.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(DISTINCT dv.id_producto) = 1;

-- 80. Productos que no han sido comprados en el último año
SELECT p.nombre_producto
FROM productos p
WHERE p.id_producto NOT IN (
    SELECT dc.id_producto
    FROM detalle_compra dc
    JOIN compras c ON dc.id_compra = c.id_compra
    WHERE c.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
);

-- 81: Ventas de productos con fecha de cosecha y lote asociado usando subconsultas
SELECT 
    p.nombre_producto,
    dv.cantidad AS cantidad_vendida,
    (SELECT pr.fecha
     FROM produccion pr
     WHERE pr.id_producto = p.id_producto
     ORDER BY pr.fecha DESC
     LIMIT 1) AS fecha_cosecha,
    (SELECT pa.nombre_parcela
     FROM produccion pr
     JOIN parcelas pa ON pa.id_parcela = pr.id_parcela
     WHERE pr.id_producto = p.id_producto
     ORDER BY pr.fecha DESC
     LIMIT 1) AS lote,
    v.fecha AS fecha_venta
FROM detalle_venta dv
JOIN productos p ON p.id_producto = dv.id_producto
JOIN ventas v ON v.id_venta = dv.id_venta;

-- 82: Estado de maquinaria con fecha y descripción del último mantenimiento
SELECT 
    m.nombre_maquina AS Maquinaria,
    em.estado AS Estado,
    COALESCE(ma.fecha, 'No ha sido mantenida') AS Ultimo_Mantenimiento,
    COALESCE(ma.descripcion, 'Sin descripción') AS Descripción_Mantenimiento
FROM maquinaria m
JOIN estado_maquinaria em ON m.id_estado = em.id_estado
LEFT JOIN mantenimiento ma ON m.id_maquina = ma.id_maquina
ORDER BY m.nombre_maquina;

-- 83: Igual que la 81, para verificar consistencia en datos históricos de ventas
SELECT 
    p.nombre_producto,
    dv.cantidad AS cantidad_vendida,
    (SELECT pr.fecha
     FROM produccion pr
     WHERE pr.id_producto = p.id_producto
     ORDER BY pr.fecha DESC
     LIMIT 1) AS fecha_cosecha,
    (SELECT pa.nombre_parcela
     FROM produccion pr
     JOIN parcelas pa ON pa.id_parcela = pr.id_parcela
     WHERE pr.id_producto = p.id_producto
     ORDER BY pr.fecha DESC
     LIMIT 1) AS lote,
    v.fecha AS fecha_venta
FROM detalle_venta dv
JOIN productos p ON p.id_producto = dv.id_producto
JOIN ventas v ON v.id_venta = dv.id_venta;

-- 84: Reporte de empleados, su cargo, maquinaria y producción asignada
SELECT 
    e.id_empleado,
    e.nombre AS nombre_empleado,
    re.nombre_rol AS cargo,
    m.nombre_maquina,
    p.nombre_producto,
    pr.nombre_parcela,
    pd.fecha,
    pd.cantidad
FROM empleados e
INNER JOIN roles_empleados re ON e.id_rol = re.id_rol
LEFT JOIN asignaciones a ON e.id_empleado = a.id_empleado
LEFT JOIN maquinaria m ON a.id_maquina = m.id_maquina
LEFT JOIN produccion pd ON e.id_empleado = pd.id_parcela
LEFT JOIN productos p ON pd.id_producto = p.id_producto
LEFT JOIN parcelas pr ON pd.id_parcela = pr.id_parcela
ORDER BY e.id_empleado;

-- 85: Ranking de clientes por total de ventas y cantidad de productos adquiridos
SELECT 
    c.nombre AS Cliente,
    COUNT(dv.id_detalle) AS Cantidad_Productos_Vendidos,
    SUM(v.total) AS Total_Ventas
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY c.id_cliente
ORDER BY Total_Ventas DESC;

-- 86: Comparación entre inventario actual y última producción
SELECT 
    p.nombre_producto AS Producto,
    i.cantidad AS Inventario_Actual,
    COALESCE(prd.cantidad, 0) AS Produccion_Reciente,
    i.cantidad - COALESCE(prd.cantidad, 0) AS Diferencia
FROM productos p
LEFT JOIN inventario i ON p.id_producto = i.id_producto
LEFT JOIN (
    SELECT id_producto, cantidad
    FROM produccion
    WHERE fecha = (SELECT MAX(fecha) FROM produccion)
) prd ON p.id_producto = prd.id_producto
ORDER BY p.nombre_producto;

-- 87: Estado actual de maquinaria con mantenimiento más reciente
SELECT 
    m.nombre_maquina AS Maquinaria,
    em.estado AS Estado,
    COALESCE(ma.fecha, 'No ha sido mantenida') AS Ultimo_Mantenimiento,
    COALESCE(ma.descripcion, 'Sin descripción') AS Descripción_Mantenimiento
FROM maquinaria m
JOIN estado_maquinaria em ON m.id_estado = em.id_estado
LEFT JOIN mantenimiento ma ON m.id_maquina = ma.id_maquina
ORDER BY m.nombre_maquina;

-- 88: Relación empleados-maquinaria con fecha de asignación y rol
SELECT 
    e.nombre AS Empleado,
    m.nombre_maquina AS Maquinaria,
    a.fecha_asignacion AS Fecha_Asignacion,
    re.nombre_rol as rol
FROM asignaciones a
JOIN empleados e ON a.id_empleado = e.id_empleado
JOIN maquinaria m ON a.id_maquina = m.id_maquina
JOIN roles_empleados re ON e.id_rol = re.id_rol
ORDER BY e.nombre, a.fecha_asignacion;

-- 89: Productos más vendidos en el mes actual
SELECT 
    p.nombre_producto AS Producto,
    SUM(dv.cantidad) AS Cantidad_Vendida
FROM detalle_venta dv
JOIN productos p ON dv.id_producto = p.id_producto
JOIN ventas v ON dv.id_venta = v.id_venta
WHERE MONTH(v.fecha) = MONTH(CURDATE()) AND YEAR(v.fecha) = YEAR(CURDATE())
GROUP BY p.id_producto
ORDER BY Cantidad_Vendida DESC;

-- 90: Consumo total de cada cliente por producto
SELECT 
    c.nombre AS Cliente,
    p.nombre_producto AS Producto,
    SUM(dv.cantidad) AS Cantidad_Comprada,
    SUM(dv.cantidad * dv.precio_unitario) AS Total_Gastado
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY c.id_cliente, p.id_producto
ORDER BY Total_Gastado DESC;

-- 91: Salarios y maquinaria asignada a cada empleado al cierre de 2024
SELECT 
    e.nombre AS empleado,
    re.nombre_rol AS cargo,
    hs.salario,
    m.nombre_maquina AS maquinaria_asignada
FROM empleados e
JOIN roles_empleados re ON e.id_rol = re.id_rol
LEFT JOIN (
    SELECT id_empleado, salario
    FROM historial_salarios
    WHERE fecha_fin = '2024-12-31'
) hs ON e.id_empleado = hs.id_empleado
LEFT JOIN asignaciones a ON e.id_empleado = a.id_empleado
LEFT JOIN maquinaria m ON a.id_maquina = m.id_maquina
ORDER BY e.nombre;

-- 92: Precio promedio y total vendido por producto
SELECT 
    p.nombre_producto,
    ROUND(AVG(dv.precio_unitario), 2) AS precio_promedio,
    SUM(dv.cantidad) AS total_vendido
FROM detalle_venta dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.id_producto
ORDER BY precio_promedio DESC;

-- 93: Conteo de mantenimientos por máquina
SELECT 
    m.nombre_maquina,
    COUNT(ma.id_maquina) AS total_mantenimientos
FROM maquinaria m
LEFT JOIN mantenimiento ma ON m.id_maquina = ma.id_maquina
GROUP BY m.id_maquina
ORDER BY total_mantenimientos DESC;

-- 94: Comparación de compra y venta de un producto específico
SELECT 
    p.nombre_producto,
    (SELECT SUM(cantidad) FROM detalle_compra WHERE id_producto = p.id_producto) AS total_comprado,
    (SELECT SUM(cantidad) FROM detalle_venta WHERE id_producto = p.id_producto) AS total_vendido
FROM productos p
WHERE p.id_producto = 8;

-- 95: Clientes con cantidad de productos distintos comprados
SELECT 
    c.nombre AS cliente,
    COUNT(DISTINCT dv.id_producto) AS productos_distintos
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
GROUP BY c.id_cliente
HAVING productos_distintos >= 1
ORDER BY productos_distintos DESC;

-- 96: Costo mensual de producción por parcela
SELECT 
    p.id_parcela,
    p.nombre_parcela,
    MONTH(pr.fecha) AS mes,
    YEAR(pr.fecha) AS ano,
    SUM(pr.cantidad) AS costo_mensual
FROM produccion pr
JOIN parcelas p ON pr.id_parcela = p.id_parcela
GROUP BY p.id_parcela, mes, ano
ORDER BY ano DESC, mes DESC;

-- 97: Rentabilidad promedio por producto y categoría
SELECT 
    cp.nombre_categoria,
    p.nombre_producto,
    ROUND(AVG(dv.precio_unitario) - AVG(dc.precio_unitario), 2) AS rentabilidad_promedio
FROM productos p
JOIN categorias_productos cp 
    ON p.id_categoria = cp.id_categoria
JOIN detalle_venta dv 
    ON dv.id_producto = p.id_producto
JOIN detalle_compra dc 
    ON dc.id_producto = p.id_producto
GROUP BY cp.nombre_categoria, p.nombre_producto
ORDER BY rentabilidad_promedio DESC;

-- 98: Producción mensual total por parcela
SELECT 
    pa.nombre_parcela,
    MONTH(p.fecha) AS mes,
    YEAR(p.fecha) AS ano,
    SUM(p.cantidad) AS total_producido
FROM produccion p
JOIN parcelas pa ON p.id_parcela = pa.id_parcela
GROUP BY pa.nombre_parcela, mes, ano
ORDER BY ano DESC, mes DESC;

-- 99: Costo promedio de proveedores
SELECT 
    pr.nombre AS nombre_proveedor,
    ROUND(AVG(dc.precio_unitario), 2) AS costo_promedio
FROM proveedores pr
JOIN compras c 
    ON pr.id_proveedor = c.id_proveedor
JOIN detalle_compra dc 
    ON c.id_compra = dc.id_compra
GROUP BY pr.nombre
ORDER BY costo_promedio ASC;

-- 100: Comparación de ventas y cosechas por producto con lote asociado
SELECT 
    p.nombre_producto,
    (SELECT SUM(dv.cantidad) 
     FROM detalle_venta dv 
     WHERE dv.id_producto = p.id_producto) AS total_vendido,
    (SELECT SUM(pr.cantidad) 
     FROM produccion pr 
     WHERE pr.id_producto = p.id_producto) AS total_cosechado,
    (SELECT l.nombre_parcela
     FROM produccion pr 
     JOIN parcelas l ON pr.id_parcela = l.id_parcela
     WHERE pr.id_producto = p.id_producto 
     LIMIT 1) AS lote_asociado
FROM productos p;