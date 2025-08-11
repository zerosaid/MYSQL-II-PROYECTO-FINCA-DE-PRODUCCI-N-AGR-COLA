-- ************************FUNCIONES********************

-- FUNCIONES CORREGIDAS PARA GESTIÓN DE FINCA

delimiter //

-- 1️⃣ rendimiento promedio por hectárea de un cultivo
create function rendimiento_promedio_hectarea(idprod int, areahect decimal(10,2))
returns decimal(10,2)
deterministic
begin
    declare totalproduccion decimal(10,2);
    declare rendimiento decimal(10,2);

    select sum(cantidad) into totalproduccion
    from produccion
    where id_producto = idprod;

    set rendimiento = if(areahect > 0, totalproduccion / areahect, 0);
    return rendimiento;
end //

-- 2️⃣ costo total de compras para un producto en un rango de fechas
create function costo_total_producto(idprod int, fechainicio date, fechafin date)
returns decimal(10,2)
deterministic
begin
    declare totalcosto decimal(10,2);

    select sum(dc.cantidad * dc.precio_unitario)
    into totalcosto
    from detalle_compra dc
    join compras c on dc.id_compra = c.id_compra
    where dc.id_producto = idprod
    and c.fecha between fechainicio and fechafin;

    return ifnull(totalcosto, 0);
end //

-- 3️⃣ total de ventas para un cliente específico
create function total_ventas_cliente(idcli int)
returns decimal(10,2)
deterministic
begin
    declare totalventas decimal(10,2);

    select sum(total) into totalventas
    from ventas
    where id_cliente = idcli;

    return ifnull(totalventas, 0);
end //

-- 4️⃣ salario actual de un empleado
create function salario_actual(idemp int)
returns decimal(10,2)
deterministic
begin
    declare salario decimal(10,2);

    select salario into salario
    from historial_salarios
    where id_empleado = idemp
    and (fecha_fin is null or fecha_fin >= curdate())
    order by fecha_inicio desc
    limit 1;

    return ifnull(salario, 0);
end //

-- 5️⃣ promedio de ventas diarias en un rango de fechas
create function promedio_ventas_diarias(fechainicio date, fechafin date)
returns decimal(10,2)
deterministic
begin
    declare totalventas decimal(10,2);
    declare dias int;

    select sum(total) into totalventas
    from ventas
    where fecha between fechainicio and fechafin;

    set dias = datediff(fechafin, fechainicio) + 1;

    return if(dias > 0, totalventas / dias, 0);
end //

-- 6️⃣ costo total de mantenimiento de una máquina en un rango de fechas
create function costo_mantenimiento_maquina(idmaq int, fechainicio date, fechafin date)
returns decimal(10,2)
deterministic
begin
    declare costototal decimal(10,2);

    select sum(costo) into costototal
    from mantenimientos
    where id_maquina = idmaq
    and fecha between fechainicio and fechafin;

    return ifnull(costototal, 0);
end //

-- 7️⃣ costo operativo total de la finca en un rango de fechas
create function costo_operativo_total(fechainicio date, fechafin date)
returns decimal(10,2)
deterministic
begin
    declare costocompras decimal(10,2);
    declare costomantenimiento decimal(10,2);
    declare costonomina decimal(10,2);

    select sum(dc.cantidad * dc.precio_unitario) into costocompras
    from detalle_compra dc
    join compras c on dc.id_compra = c.id_compra
    where c.fecha between fechainicio and fechafin;

    select sum(costo) into costomantenimiento
    from mantenimientos
    where fecha between fechainicio and fechafin;

    select sum(salario) into costonomina
    from historial_salarios
    where fecha_inicio <= fechafin
    and (fecha_fin is null or fecha_fin >= fechainicio);

    return ifnull(costocompras,0) + ifnull(costomantenimiento,0) + ifnull(costonomina,0);
end //

-- 8️⃣ stock disponible de un producto
create function stock_disponible(idprod int)
returns int
deterministic
begin
    declare entradas int;
    declare salidas int;

    select ifnull(sum(cantidad),0) into entradas
    from detalle_compra
    where id_producto = idprod;

    select ifnull(sum(cantidad),0) into salidas
    from detalle_venta
    where id_producto = idprod;

    return entradas - salidas;
end //

-- 9️⃣ valor monetario del inventario actual
create function valor_inventario()
returns decimal(15,2)
deterministic
begin
    declare valor decimal(15,2);

    select ifnull(sum(stock * precio_referencia), 0) into valor
    from (
        select p.id_producto,
               (ifnull((select sum(cantidad) from detalle_compra dc where dc.id_producto = p.id_producto),0)
               - ifnull((select sum(cantidad) from detalle_venta dv where dv.id_producto = p.id_producto),0)) as stock,
               p.precio_referencia
        from productos p
    ) as inventario;

    return valor;
end //

-- 🔟 costo total de insumos usados en la producción de un producto
create function costo_insumos_produccion(idprod int)
returns decimal(10,2)
deterministic
begin
    declare costototal decimal(10,2);

    select sum(ci.cantidad * ci.costo_unitario) into costototal
    from consumo_insumos ci
    where ci.id_producto = idprod;

    return ifnull(costototal, 0);
end //

-- 1️⃣1️⃣ ventas totales de un producto en un rango de fechas
create function ventas_totales_producto(idprod int, fechainicio date, fechafin date)
returns decimal(15,2)
deterministic
begin
    declare totalventas decimal(15,2);

    select sum(cantidad * precio_unitario) into totalventas
    from detalle_venta dv
    join ventas v on dv.id_venta = v.id_venta
    where dv.id_producto = idprod
    and v.fecha between fechainicio and fechafin;

    return ifnull(totalventas, 0);
end //

-- 1️⃣2️⃣ rentabilidad bruta de un producto
create function rentabilidad_producto(idprod int)
returns decimal(15,2)
deterministic
begin
    declare ingresos decimal(15,2);
    declare costos decimal(15,2);

    select sum(cantidad * precio_unitario) into ingresos
    from detalle_venta
    where id_producto = idprod;

    select sum(cantidad * costo_unitario) into costos
    from consumo_insumos
    where id_producto = idprod;

    return ifnull(ingresos,0) - ifnull(costos,0);
end //

-- 1️⃣3️⃣ promedio de ventas por cliente
create function promedio_ventas_cliente(idcli int)
returns decimal(15,2)
deterministic
begin
    declare totalventas decimal(15,2);
    declare cantidadventas int;

    select sum(total) into totalventas
    from ventas
    where id_cliente = idcli;

    select count(*) into cantidadventas
    from ventas
    where id_cliente = idcli;

    if cantidadventas = 0 then
        return 0;
    end if;

    return totalventas / cantidadventas;
end //

-- 1️⃣4️⃣ cantidad total de horas trabajadas por un empleado en un rango de fechas
create function horas_trabajadas_empleado(idemp int, fechainicio date, fechafin date)
returns decimal(10,2)
deterministic
begin
    declare totalhoras decimal(10,2);

    select sum(horas_trabajadas) into totalhoras
    from registro_asistencia
    where id_empleado = idemp
    and fecha between fechainicio and fechafin;

    return ifnull(totalhoras, 0);
end //

-- 1️⃣5️⃣ costo total en salarios de un empleado en un rango de fechas
create function costo_salarial_empleado(idemp int, fechainicio date, fechafin date)
returns decimal(15,2)
deterministic
begin
    declare costosalarial decimal(15,2);

    select sum(salario) into costosalarial
    from historial_salarios
    where id_empleado = idemp
    and fecha_inicio <= fechafin
    and (fecha_fin is null or fecha_fin >= fechainicio);

    return ifnull(costosalarial, 0);
end //

-- 1️⃣6️⃣ número de compras realizadas por un cliente en un rango de fechas
create function compras_cliente_periodo(idcli int, fechainicio date, fechafin date)
returns int
deterministic
begin
    declare totalcompras int;

    select count(*) into totalcompras
    from ventas
    where id_cliente = idcli
    and fecha between fechainicio and fechafin;

    return ifnull(totalcompras, 0);
end //

-- 1️⃣7️⃣ valor total de pedidos que superen un monto específico
create function valor_pedidos_mayores(monto_minimo decimal(15,2))
returns decimal(15,2)
deterministic
begin
    declare totalvalor decimal(15,2);

    select sum(total) into totalvalor
    from ventas
    where total > monto_minimo;

    return ifnull(totalvalor, 0);
end //

-- 1️⃣8️⃣ promedio de producción por día para un producto
create function promedio_produccion_diaria(idprod int)
returns decimal(15,2)
deterministic
begin
    declare totalproduccion decimal(15,2);
    declare diastotal int;
    declare fecha_min date;
    declare fecha_max date;

    select sum(cantidad), min(fecha), max(fecha) into totalproduccion, fecha_min, fecha_max
    from produccion
    where id_producto = idprod;

    set diastotal = datediff(fecha_max, fecha_min) + 1;

    if diastotal <= 0 then
        return 0;
    end if;

    return totalproduccion / diastotal;
end //

-- 1️⃣9️⃣ porcentaje de ventas de un producto respecto al total de ventas
create function porcentaje_ventas_producto(idprod int)
returns decimal(5,2)
deterministic
begin
    declare ventasprod decimal(15,2);
    declare ventastotal decimal(15,2);

    select sum(cantidad * precio_unitario) into ventasprod
    from detalle_venta
    where id_producto = idprod;

    select sum(cantidad * precio_unitario) into ventastotal
    from detalle_venta;

    if ventastotal = 0 then
        return 0;
    end if;

    return (ventasprod / ventastotal) * 100;
end //

-- 2️⃣0️⃣ costo promedio de producción por unidad de un producto
create function costo_promedio_produccion(idprod int)
returns decimal(15,2)
deterministic
begin
    declare costototal decimal(15,2);
    declare cantidadtotal decimal(15,2);

    select sum(costo_total) into costototal
    from produccion
    where id_producto = idprod;

    select sum(cantidad) into cantidadtotal
    from produccion
    where id_producto = idprod;

    if cantidadtotal = 0 then
        return 0;
    end if;

    return costototal / cantidadtotal;
end //

delimiter ;

-- 1️ rendimiento promedio por hectárea de un cultivo (id_producto=10, area=5.5 hectáreas)
SELECT rendimiento_promedio_hectarea(10, 5.5) AS rendimiento_promedio;

-- 2️ costo total de compras para un producto en un rango de fechas (id_producto=10, 2025-01-01 a 2025-06-30)
SELECT costo_total_producto(10, '2025-01-01', '2025-06-30') AS costo_total_compras;

-- 3️ total de ventas para un cliente específico (id_cliente=15)
SELECT total_ventas_cliente(15) AS total_ventas;

-- 4️ salario actual de un empleado (id_empleado=7)
SELECT salario_actual(7) AS salario_actual;

-- 5️ promedio de ventas diarias en un rango de fechas (2025-01-01 a 2025-06-30)
SELECT promedio_ventas_diarias('2025-01-01', '2025-06-30') AS promedio_ventas_diarias;

-- 6️ costo total de mantenimiento de una máquina en rango de fechas (id_maquina=3, 2025-01-01 a 2025-06-30)
SELECT costo_mantenimiento_maquina(3, '2025-01-01', '2025-06-30') AS costo_mantenimiento;

-- 7️ costo operativo total de la finca en un rango de fechas (2025-01-01 a 2025-06-30)
SELECT costo_operativo_total('2025-01-01', '2025-06-30') AS costo_operativo_total;

-- 8️ stock disponible de un producto (id_producto=10)
SELECT stock_disponible(10) AS stock_actual;

-- 9️ valor monetario del inventario actual
SELECT valor_inventario() AS valor_inventario_actual;

-- 10 costo total de insumos usados en la producción de un producto (id_producto=10)
SELECT costo_insumos_produccion(10) AS costo_insumos;

-- 1️1️ ventas totales de un producto en un rango de fechas (id_producto=10, 2025-01-01 a 2025-06-30)
SELECT ventas_totales_producto(10, '2025-01-01', '2025-06-30') AS ventas_totales;

-- 1️2️ rentabilidad bruta de un producto (id_producto=10)
SELECT rentabilidad_producto(10) AS rentabilidad_bruta;

-- 1️3️ promedio de ventas por cliente (id_cliente=15)
SELECT promedio_ventas_cliente(15) AS promedio_ventas;

-- 1️4️ cantidad total de horas trabajadas por un empleado en un rango de fechas (id_empleado=7, 2025-01-01 a 2025-06-30)
SELECT horas_trabajadas_empleado(7, '2025-01-01', '2025-06-30') AS horas_trabajadas;

-- 1️5️ costo total en salarios de un empleado en un rango de fechas (id_empleado=7, 2025-01-01 a 2025-06-30)
SELECT costo_salarial_empleado(7, '2025-01-01', '2025-06-30') AS costo_salarial;

-- 1️6️ número de compras realizadas por un cliente en un rango de fechas (id_cliente=15, 2025-01-01 a 2025-06-30)
SELECT compras_cliente_periodo(15, '2025-01-01', '2025-06-30') AS total_compras;

-- 1️7️ valor total de pedidos que superen un monto específico (monto = 1000000)
SELECT valor_pedidos_mayores(1000000) AS valor_pedidos_altos;

-- 1️8️ promedio de producción por día para un producto (id_producto=10)
SELECT promedio_produccion_diaria(10) AS promedio_diario_produccion;

-- 1️9️ porcentaje de ventas de un producto respecto al total de ventas (id_producto=10)
SELECT porcentaje_ventas_producto(10) AS porcentaje_ventas;

-- 20 costo promedio de producción por unidad de un producto (id_producto=10)
SELECT costo_promedio_produccion(10) AS costo_promedio_unidad;