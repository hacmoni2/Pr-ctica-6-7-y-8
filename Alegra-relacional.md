## Parte 2 - Álgebra Relacional

---

## Ejercicio 2.1. Exportación de datos para RelaX
El script automatizado de exportación genera una muestra limpia de 10 a 30 registros por tabla desde nuestra base de datos en PostgreSQL, manteniendo intacta la integridad referencial y formateándola para ser cargada directamente en la pestaña *Editor de Grupo* de la herramienta RelaX. El archivo resultante se encuentra versionado en `relax/grupo.txt`.

---

## Ejercicio 2.2. Consultas en Álgebra Relacional

### 1. Selección y Proyección
* **Pregunta:** Obtener el correo y el tipo de usuario de todas las cuentas institucionales que se encuentren actualmente activas.
* **Expresión en álgebra:** 
  $$\pi_{\text{correo, tipo\_usuario}}(\sigma_{\text{activo} = \text{true}}(\text{USUARIO}))$$
* **Equivalente SQL:**
  ```sql
  SELECT correo, tipo_usuario FROM USUARIO WHERE activo = TRUE;
  ```

### 2. Unión, Diferencia e Intersección
* **Pregunta:** Listar los identificadores únicos de usuarios que son estudiantes o que pertenecen al personal institucional (demostrando compatibilidad de unión).
* **Expresión en álgebra:** 
  $$\pi_{\text{id\_usuario}}(\text{ESTUDIANTE}) \cup \pi_{\text{id\_usuario}}(\text{PERSONAL\_INSTITUCIONAL})$$
* **Equivalente SQL:**
  ```sql
  SELECT id_usuario FROM ESTUDIANTE UNION SELECT id_usuario FROM PERSONAL_INSTITUCIONAL;
  ```

### 3. Producto Cartesiano
* **Pregunta:** Generar el producto cartesiano entre las categorías de recursos y los estados físicos posibles de los ejemplares para análisis combinatorio básico.
* **Expresión en álgebra:** 
  $$\text{CATEGORIA} \times \text{EJEMPLAR}$$
* **Equivalente SQL:**
  ```sql
  SELECT * FROM CATEGORIA CROSS JOIN EJEMPLAR;
  ```

### 4. Reunión (Natural, Theta y Externa)
* **Pregunta:** Consultar la reunión natural entre los recursos del catálogo y sus categorías correspondientes para conocer a qué área pertenecen.
* **Expresión en álgebra:** 
  $$\text{RECURSO} \bowtie_{\text{RECURSO.id\_categoria} = \text{CATEGORIA.id\_categoria}} \text{CATEGORIA}$$
* **Equivalente SQL:**
  ```sql
  SELECT * FROM RECURSO NATURAL JOIN CATEGORIA;
  ```

### 5. Agregación y Agrupación
* **Pregunta:** Obtener el total de ejemplares físicos agrupados por su estado de conservación actual.
* **Expresión en álgebra:** 
  $$\gamma_{\text{estado\_fisico}, \text{COUNT}(\text{id\_ejemplar})\to\text{total}}(\text{EJEMPLAR})$$
* **Equivalente SQL:**
  ```sql
  SELECT estado_fisico, COUNT(id_ejemplar) AS total FROM EJEMPLAR GROUP BY estado_fisico;
  ```

### 6. División Relacional
* **Pregunta:** Encontrar a los usuarios que han realizado préstamos de todos los recursos disponibles en una categoría específica.
* **Expresión en álgebra:** 
  $$\pi_{\text{id\_usuario, id\_recurso}}(\text{PRESTAMO} \bowtie \text{DETALLE\_PRESTAMO} \bowtie \text{EJEMPLAR}) \div \pi_{\text{id\_recurso}}(\sigma_{\text{id\_categoria}=1}(\text{RECURSO}))$$
* **Equivalente SQL:**
  ```sql
  -- Consulta equivalente mediante división relacional implementada con NOT EXISTS anidados
  SELECT DISTINCT p.id_usuario FROM PRESTAMO p WHERE NOT EXISTS (
      SELECT r.id_recurso FROM RECURSO r WHERE r.id_categoria = 1 AND NOT EXISTS (
          SELECT 1 FROM DETALLE_PRESTAMO dp JOIN EJEMPLAR e ON dp.id_ejemplar = e.id_ejemplar
          WHERE dp.id_prestamo = p.id_prestamo AND e.id_recurso = r.id_recurso
      )
  );
  ```

---

## Ejercicio 2.3. Álgebra del proyecto asignado
* Análisis aplicado sobre tres consultas críticas del backend orientadas a la trazabilidad de sanciones e historial de préstamos en el almacén de ESCOM, destacando el uso de operadores de reunión y agregación pesada en los árboles relacionales correspondientes.
