Create database if not exists `Finca_Oasis`;
USE `Finca_Oasis`;


-- ÁREA DE PRODUCTOS Y PRODUCCIÓN
CREATE TABLE categorias_productos (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias_productos(id_categoria)
);

CREATE TABLE parcelas (
    id_parcela INT PRIMARY KEY AUTO_INCREMENT,
    nombre_parcela VARCHAR(50),
    ubicacion VARCHAR(100)
);

CREATE TABLE produccion (
    id_produccion INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_parcela INT,
    id_producto INT,
    cantidad DECIMAL(10,2),
    FOREIGN KEY (id_parcela) REFERENCES parcelas(id_parcela),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE inventario (
    id_inventario INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT,
    cantidad DECIMAL(10,2),
    fecha_actualizacion DATE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ÁREA DE VENTAS Y CLIENTES
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    direccion VARCHAR(200),
    telefono VARCHAR(20)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    fecha DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_venta (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_venta INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ÁREA DE COMPRAS Y PROVEEDORES
CREATE TABLE proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    contacto VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE compras (
    id_compra INT PRIMARY KEY AUTO_INCREMENT,
    id_proveedor INT,
    fecha DATE,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE detalle_compra (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_compra INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_compra) REFERENCES compras(id_compra),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ÁREA DE MAQUINARIA Y MANTENIMIENTO
CREATE TABLE estado_maquinaria (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(50)
);

CREATE TABLE maquinaria (
    id_maquina INT PRIMARY KEY AUTO_INCREMENT,
    nombre_maquina VARCHAR(100),
    descripcion TEXT,
    id_estado INT,
    FOREIGN KEY (id_estado) REFERENCES estado_maquinaria(id_estado)
);

CREATE TABLE mantenimiento (
    id_mantenimiento INT PRIMARY KEY AUTO_INCREMENT,
    id_maquina INT,
    fecha DATE,
    descripcion TEXT,
    FOREIGN KEY (id_maquina) REFERENCES maquinaria(id_maquina)
);

-- ÁREA DE EMPLEADOS Y RRHH
CREATE TABLE roles_empleados (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(50)
);

CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    cedula VARCHAR(20) UNIQUE,
    fecha_ingreso DATE,
    id_rol INT,
    id_maquina INT,
    FOREIGN KEY (id_rol) REFERENCES roles_empleados(id_rol),
    foreign key (id_maquina) references maquinaria(id_maquina)
);

CREATE TABLE asignaciones (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT,
    id_rol INT,
    fecha_asignacion DATE,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_rol) REFERENCES roles_sistema(id_rol)
);

CREATE TABLE historial_salarios (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT,
    salario DECIMAL(10,2),
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

-- SEGURIDAD Y ACCESOS
CREATE TABLE roles_sistema (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(50)
);

CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(50),
    contraseña VARCHAR(100),
    id_rol INT,
    FOREIGN KEY (id_rol) REFERENCES roles_sistema(id_rol)
);

CREATE TABLE permisos (
    id_permiso INT PRIMARY KEY AUTO_INCREMENT,
    id_rol INT,
    descripcion VARCHAR(100),
    FOREIGN KEY (id_rol) REFERENCES roles_sistema(id_rol)
);