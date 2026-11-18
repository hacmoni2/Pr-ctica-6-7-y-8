
-- 1. SELECCIÓN Y PROYECCIÓN: Filtrar cuentas activas
-- Álgebra: \pi_{correo, tipo\_usuario}(\sigma_{activo = true}(USUARIO))
SELECT correo, tipo_usuario 
FROM USUARIO 
WHERE activo = TRUE;


-- 2. UNIÓN: Usuarios estudiantes o personal institucional
-- Álgebra: \pi_{id\_usuario}(ESTUDIANTE) \cup \pi_{id\_usuario}(PERSONAL\_INSTITUCIONAL)
SELECT id_usuario FROM ESTUDIANTE 
UNION 
SELECT id_usuario FROM PERSONAL_INSTITUCIONAL;


-- 3. PRODUCTO CARTESIANO: Combinación de categorías y ejemplares
-- Álgebra: CATEGORIA \times EJEMPLAR
SELECT * 
FROM CATEGORIA 
CROSS JOIN EJEMPLAR;


-- 4. REUNIÓN NATURAL: Recursos con sus respectivas categorías
-- Álgebra: RECURSO \bowtie CATEGORIA
SELECT * 
FROM RECURSO 
NATURAL JOIN CATEGORIA;


-- 5. AGREGACIÓN Y AGRUPACIÓN: Total de ejemplares por su estado físico
-- Álgebra: \gamma_{estado\_fisico, COUNT(id\_ejemplar)\to total}(EJEMPLAR)
SELECT estado_fisico, COUNT(id_ejemplar) AS total 
FROM EJEMPLAR 
GROUP BY estado_fisico;


-- 6. DIVISIÓN RELACIONAL: Usuarios que han solicitado todos los recursos de la categoría 1
-- Implementación mediante NOT EXISTS anidados
SELECT DISTINCT p.id_usuario 
FROM PRESTAMO p 
WHERE NOT EXISTS (
    SELECT r.id_recurso 
    FROM RECURSO r 
    WHERE r.id_categoria = 1 
    AND NOT EXISTS (
        SELECT 1 
        FROM DETALLE_PRESTAMO dp 
        JOIN EJEMPLAR e ON dp.id_ejemplar = e.id_ejemplar
        WHERE dp.id_prestamo = p.id_prestamo 
        AND e.id_recurso = r.id_recurso
    )
);