
BEGIN;

-- 1. Tabla de Usuarios (Supertipo)
CREATE TABLE USUARIO (
    id_usuario INT PRIMARY KEY,
    correo VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) NOT NULL, -- 'ESTUDIANTE', 'PERSONAL', 'ADMIN'
    activo BOOLEAN DEFAULT TRUE
);

-- 2. Subtipo Estudiante (Relación 1:1 con USUARIO)
CREATE TABLE ESTUDIANTE (
    boleta VARCHAR(10) PRIMARY KEY,
    id_usuario INT UNIQUE NOT NULL,
    carrera VARCHAR(100),
    semestre INT,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE
);

-- 3. Subtipo Personal Institucional (Relación 1:1 con USUARIO)
CREATE TABLE PERSONAL_INSTITUCIONAL (
    numero_empleado VARCHAR(10) PRIMARY KEY,
    id_usuario INT UNIQUE NOT NULL,
    departamento VARCHAR(100),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE
);

-- 4. Tabla Categoría de Materiales (Aislada para evitar dependencias transitivas)
CREATE TABLE CATEGORIA (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL, -- Ej: Deportivo, Electrónica, Bibliográfico
    descripcion TEXT
);

-- 5. Tabla Recurso (Catálogo general)
CREATE TABLE RECURSO (
    id_recurso INT PRIMARY KEY,
    id_categoria INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    autor_o_marca VARCHAR(100),
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
);

-- 6. Tabla Ejemplar (Unidades físicas individuales)
CREATE TABLE EJEMPLAR (
    id_ejemplar INT PRIMARY KEY,
    id_recurso INT NOT NULL,
    codigo_inventario VARCHAR(50) UNIQUE NOT NULL,
    estado_fisico VARCHAR(20) NOT NULL, -- 'Disponible', 'Prestado', 'Dañado', 'Extraviado'
    FOREIGN KEY (id_recurso) REFERENCES RECURSO(id_recurso)
);

-- 7. Tabla Préstamo (Cabecera)
CREATE TABLE PRESTAMO (
    id_prestamo INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha_solicitud TIMESTAMP NOT NULL,
    fecha_limite TIMESTAMP NOT NULL,
    fecha_devolucion_real TIMESTAMP,
    estado VARCHAR(20) NOT NULL, -- 'Solicitado', 'Activo', 'Finalizado', 'Con_Incidencia'
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
);

-- 8. Tabla Detalle de Préstamo (Rompe la relación N:M entre Préstamo y Ejemplar)
CREATE TABLE DETALLE_PRESTAMO (
    id_detalle INT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    id_ejemplar INT NOT NULL,
    observaciones_entrega TEXT,
    observaciones_devolucion TEXT,
    FOREIGN KEY (id_prestamo) REFERENCES PRESTAMO(id_prestamo),
    FOREIGN KEY (id_ejemplar) REFERENCES EJEMPLAR(id_ejemplar)
);

-- 9. Tabla Incidencia
CREATE TABLE INCIDENCIA (
    id_incidencia INT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    id_usuario INT NOT NULL,
    id_administrador INT NOT NULL,
    tipo_incidencia VARCHAR(30) NOT NULL, -- 'Retraso', 'Daño', 'Pérdida'
    descripcion TEXT,
    fecha_registro TIMESTAMP NOT NULL,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP,
    FOREIGN KEY (id_prestamo) REFERENCES PRESTAMO(id_prestamo),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    FOREIGN KEY (id_administrador) REFERENCES USUARIO(id_usuario)
);

-- 10. Tabla Bloqueo de Usuario (Sanciones)
CREATE TABLE BLOQUEO_USUARIO (
    id_bloqueo INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_incidencia INT NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    FOREIGN KEY (id_incidencia) REFERENCES INCIDENCIA(id_incidencia)
);

COMMIT;