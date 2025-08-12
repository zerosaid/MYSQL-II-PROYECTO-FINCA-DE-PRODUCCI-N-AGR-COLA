# MYSQL-II-PROYECTO-FINCA-DE-PRODUCCION-AGRICOLA


# Gestión de una Finca de Producción Agrícola

## Descripción del Proyecto

Este proyecto consiste en el desarrollo de una base de datos para la gestión integral de una finca agrícola. Su propósito es facilitar el control y seguimiento de la producción, inventarios, ventas, compras, maquinaria, empleados y aspectos financieros de la finca.

La base de datos permite almacenar y consultar información sobre parcelas, cultivos, proveedores, clientes, empleados, maquinaria, y gestionar las operaciones diarias de la finca. Además, incluye funcionalidades avanzadas como procedimientos almacenados, funciones, eventos programados y triggers para automatizar tareas y mantener la integridad de los datos.

---

## Requisitos del Sistema

- MySQL Server versión 5.7 o superior (compatible con eventos y triggers).  
- Cliente MySQL Workbench o cualquier otro cliente SQL para ejecutar scripts.  
- Permisos adecuados para crear bases de datos, tablas, procedimientos, funciones, eventos y triggers.  
- Sistema operativo: Compatible con Windows, Linux o macOS donde se pueda instalar MySQL.

---

## Instalación y Configuración

1. **Crear la base de datos y estructura:**

   Ejecuta el archivo `ddl.sql` para crear la base de datos y todas las tablas necesarias. Puedes hacerlo desde MySQL Workbench o consola:

   ```bash
   mysql -u usuario -p < ddl.sql
Cargar datos iniciales:

2. **Ejecuta el archivo dml.sql para insertar los datos iniciales en las tablas:**

bash
Copiar código
mysql -u usuario -p nombre_base_datos < dml.sql
Ejecutar consultas, procedimientos, funciones, eventos y triggers:

Ejecuta los scripts SQL correspondientes para crear y habilitar los procedimientos almacenados y funciones.

3. **Asegúrate de habilitar el Event Scheduler en MySQL para que los eventos automáticos funcionen:**

sql
Copiar código
SET GLOBAL event_scheduler = ON;
Ejecuta los scripts para crear los eventos programados y triggers que mantendrán la base de datos actualizada y consistente.

4. **Validar la configuración:**

Verifica que todas las tablas estén creadas y con datos iniciales.

Revisa que los eventos estén activos:

sql
Copiar código
SHOW EVENTS;
Confirma que los triggers funcionan insertando o modificando datos relevantes.

## Estructura de la Base de Datos
La base de datos está compuesta por las siguientes tablas principales:

empleados: Información de los trabajadores de la finca, incluyendo roles y estado laboral.

productos: Detalles de los productos agrícolas y otros bienes manejados en la finca.

parcelas: Información de las parcelas agrícolas, su ubicación y estado actual.

producciones: Registros de la producción obtenida en cada parcela y fecha.

ventas: Detalle de las ventas realizadas a clientes.

compras: Registro de adquisiciones a proveedores.

maquinaria: Información sobre la maquinaria disponible, su estado y uso.

proveedores: Datos de los proveedores de insumos y servicios.

clientes: Información sobre los compradores y clientes de la finca.

inventarios: Control de stock de productos e insumos.

reportes_ventas, reportes_produccion: Tablas que almacenan reportes generados automáticamente por eventos.

alertas: Registros de alertas generadas para stock bajo, pagos vencidos, entre otros.

Estas tablas están relacionadas mediante claves foráneas para garantizar la integridad referencial y permitir consultas complejas.

## Ejemplos de Consultas
1. Consulta básica: Total de producción por parcela en el último mes

sql
Copiar código
SELECT pa.nombre_parcela, SUM(pr.cantidad) AS total_producido
FROM producciones pr
JOIN parcelas pa ON pr.id_parcela = pa.id_parcela
WHERE pr.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY pa.nombre_parcela;

2. Consulta avanzada: Ventas mensuales por producto con promedio de precio

sql
Copiar código
SELECT p.nombre_producto, MONTH(v.fecha) AS mes, YEAR(v.fecha) AS ano,
       SUM(vd.cantidad) AS total_vendido,
       AVG(vd.precio_unitario) AS precio_promedio
FROM ventas v
JOIN detalle_venta vd ON v.id_venta = vd.id_venta
JOIN productos p ON vd.id_producto = p.id_producto
WHERE v.fecha >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY p.nombre_producto, mes, ano
ORDER BY ano DESC, mes DESC;


## Ejecutar procedimiento almacenado para actualizar salarios

sql
Copiar código
CALL ajuste_salario_anual();
Obtener alertas activas de stock bajo

sql
Copiar código
SELECT * FROM alertas WHERE tipo = 'Stock bajo' AND fecha >= DATE_SUB(CURDATE(), INTERVAL 1 DAY);