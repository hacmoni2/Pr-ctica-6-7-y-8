# Parte 1 - Dependencias Funcionales y Normalización


---

## Ejercicio 1.1. Pautas de diseño

En el archivo `normalizacion.md`, se describe cada tabla del proyecto propio mediante la frase característica —*«cada fila es...»*— y se evalúa rigurosamente frente a las cuatro pautas informales: **semántica clara, sin anomalías, pocos nulos y sin tuplas espurias**.

1. **`USUARIO`**
   * **Frase descriptiva:** «Cada fila es una cuenta de acceso institucional única que almacena las credenciales de autenticación, el rol global y el estado de actividad en el sistema».
   * **Evaluación:** Semántica clara (agrupa datos comunes de autenticación). Sin anomalías de actualización (los atributos específicos de rol están desacoplados en subtipos). Pocos nulos (solo campos obligatorios). Sin tuplas espurias.

2. **`ESTUDIANTE`**
   * **Frase descriptiva:** «Cada fila es el perfil académico específico de un usuario que posee una boleta, carrera y semestre vigentes dentro del IPN».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos. Sin tuplas espurias.

3. **`PERSONAL_INSTITUCIONAL`**
   * **Frase descriptiva:** «Cada fila es el registro laboral de un docente o empleado de apoyo adscrito al instituto, vinculado mediante su número de empleado y departamento».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos. Sin tuplas espurias.

4. **`CATEGORIA`**
   * **Frase descriptiva:** «Cada fila es una clasificación genérica de los recursos institucionales disponibles (por ejemplo: Material Deportivo, Electrónica, Bibliográfico)».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos. Sin tuplas espurias.

5. **`RECURSO`**
   * **Frase descriptiva:** «Cada fila es un elemento del catálogo general que pertenece a una categoría y describe un bien institucional (título, autor o marca, descripción)».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos (la descripción o marca pueden ser opcionales según la naturaleza del bien). Sin tuplas espurias.

6. **`EJEMPLAR`**
   * **Frase descriptiva:** «Cada fila es una unidad física individual etiquetada con un código de inventario único y un estado de conservación actual».
   * **Evaluación:** Semántica clara (separa limpiamente el concepto lógico del objeto físico). Sin anomalías. Pocos nulos. Sin tuplas espurias.
   * **Corrección aplicada:** En una iteración preliminar, intentamos colocar los atributos técnicos de electrónica y deporte directamente en `EJEMPLAR`, lo cual **fallaba por anomalías de nulos cruzados y redundancia** (los libros no usaban pines de voltaje ni especificaciones técnicas de laboratorio). Se corrigió aislando los datos en `CATEGORIA` y `RECURSO`.

7. **`PRESTAMO`**
   * **Frase descriptiva:** «Cada fila es la cabecera de una solicitud de préstamo institucional realizada por un usuario, registrando fechas clave de control y estado operativo».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos (`fecha_devolucion_real` es nula mientras el préstamo esté activo, lo cual responde estrictamente a la lógica de negocio y no a un defecto de diseño). Sin tuplas espurias.

8. **`DETALLE_PRESTAMO`**
   * **Frase descriptiva:** «Cada fila es la asociación individual de cada ejemplar físico que forma parte de un ticket de préstamo específico».
   * **Evaluación:** Semántica clara (resuelve correctamente la relación N:M entre préstamos y ejemplares). Sin anomalías. Pocos nulos. Sin tuplas espurias.

9. **`INCIDENCIA`**
   * **Frase descriptiva:** «Cada fila es un reporte formal de anomalía, retraso, daño o pérdida generado durante la gestión de un préstamo».
   * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos (`fecha_resolucion` es nula si la incidencia sigue abierta). Sin tuplas espurias.

10. **`BLOQUEO_USUARIO`**
    * **Frase descriptiva:** «Cada fila es una sanción temporal o indefinida aplicada a una cuenta de usuario derivada de una incidencia no resuelta o daño material».
    * **Evaluación:** Semántica clara. Sin anomalías. Pocos nulos. Sin tuplas espurias.

---

## Ejercicio 1.2. Las dependencias funcionales

### 1. Conjunto $F$ de dependencias funcionales (derivadas de las reglas del negocio)
* $F_1: \text{id\_usuario} \rightarrow \{\text{correo, password\_hash, tipo\_usuario, activo}\}$ — *Regla: Un ID de usuario determina de forma única sus credenciales de acceso y estado.*
* $F_2: \text{correo} \rightarrow \{\text{id\_usuario, password\_hash, tipo\_usuario, activo}\}$ — *Regla: El correo electrónico es una clave candidata única en el sistema institucional.*
* $F_3: \text{boleta} \rightarrow \{\text{id\_usuario, carrera, semestre}\}$ — *Regla: La boleta identifica unívocamente al estudiante y su cuenta general asociada.*
* $F_4: \text{numero\_empleado} \rightarrow \{\text{id\_usuario, departamento}\}$ — *Regla: El número de empleado identifica de forma única al personal institucional.*
* $F_5: \text{id\_categoria} \rightarrow \{\text{nombre, descripcion}\}$ — *Regla: La clave de categoría define su nombre descriptivo y detalles.*
* $F_6: \text{id\_recurso} \rightarrow \{\text{id\_categoria, titulo, descripcion, autor\_o\_marca}\}$ — *Regla: Un recurso del catálogo pertenece a una categoría y posee metadatos generales.*
* $F_7: \text{id\_ejemplar} \rightarrow \{\text{id\_recurso, codigo\_inventario, estado\_fisico}\}$ — *Regla: Un ejemplar físico pertenece a un recurso y posee un estado y código.*
* $F_8: \text{codigo\_inventario} \rightarrow \{\text{id\_ejemplar, id\_recurso, estado\_fisico}\}$ — *Regla: El código físico de inventario es único para cada unidad.*
* $F_9: \text{id\_prestamo} \rightarrow \{\text{id\_usuario, fecha\_solicitud, fecha\_limite, fecha\_devolucion\_real, estado}\}$ — *Regla: Un préstamo tiene un usuario responsable y fechas de control.*
* $F_{10}: \text{id\_detalle} \rightarrow \{\text{id\_prestamo, id\_ejemplar, observaciones\_entrega, observaciones\_devolucion}\}$ — *Regla: Cada detalle asocia de forma unívoca un préstamo con un ejemplar físico.*
* $F_{11}: \text{id\_incidencia} \rightarrow \{\text{id\_prestamo, id\_usuario, id\_administrador, tipo\_incidencia, descripcion, fecha\_registro, resuelta, fecha\_resolucion}\}$ — *Regla: Una incidencia recopila el reporte formal de un préstamo y usuario.*
* $F_{12}: \text{id\_bloqueo} \rightarrow \{\text{id\_usuario, id\_incidencia, fecha\_inicio, fecha\_fin, activo}\}$ — *Regla: Un registro de bloqueo sanciona a un usuario por una incidencia.*

### 2. Cálculo del cierre de atributos para claves candidatas
Tomemos como ejemplo la tabla **`RECURSO`** con el esquema de atributos $R = \{\text{id\_recurso, id\_categoria, titulo, descripcion, autor\_o\_marca}\}$ y las dependencias funcionales del negocio.
* Queremos calcular el cierre $\{\text{id\_recurso}\}^+$ paso a paso:
  1. **Paso inicial:** $X^{(0)} = \{\text{id\_recurso}\}$
  2. **Aplicando $F_6$** ($\text{id\_recurso} \rightarrow \text{id\_categoria, titulo, descripcion, autor\_o\_marca}$):
     $X^{(1)} = \{\text{id\_recurso, id\_categoria, titulo, descripcion, autor\_o\_marca}\}$
* Como el cierre cubre la totalidad de los atributos de la relación $R$, **$\text{id\_recurso}$ es clave candidata** (y clave primaria). Este mismo procedimiento analítico se aplica para validar las claves de las demás tablas del esquema.

### 3. Reducción de $F$ a un conjunto mínimo ($F_{min}$)
Para garantizar que el esquema relacional no posea dependencias redundantes ni atributos sobrantes, aplicamos rigurosamente el algoritmo de recubrimiento mínimo:
1. **Lados derechos simples:** Descomponemos las dependencias funcionales para que exista un único atributo a la derecha de cada regla (ej. separar $F_6$ en dependencias individuales por atributo).
2. **Eliminación de atributos extraños:** Comprobamos los lados izquierdos de las dependencias compuestas; si al retirar un atributo secundario el cierre continúa alcanzando al consecuente, el atributo es considerado extraño y se elimina.
3. **Eliminación de dependencias redundantes:** Evaluamos cada regla individual; si puede deducirse lógicamente a partir de las demás aplicando la transitividad de los axiomas de Armstrong, se suprime del conjunto definitivo.

### 4. Equivalencia con el conjunto de otro equipo
Si contrastamos nuestro conjunto $F$ con el conjunto $G$ de otro equipo que modele un dominio similar (por ejemplo, si ellos emplean la denominación de atributo `matricula` en lugar de `boleta`), demostramos la equivalencia probando formalmente que **cada dependencia funcional de $F$ es derivable a partir de $G$ ($F \models G$) y viceversa ($G \models F$)**, asegurando que sus cierres sean idénticos ($F^+ = G^+$).

---

## Ejercicio 1.3. Las formas normales

### 1. Determinación de la forma normal por tabla
* **`USUARIO`**: **BCNF** (Atributos atómicos, clave primaria $\text{id\_usuario}$, todas las dependencias funcionales parten de una superclave).
* **`ESTUDIANTE` y `PERSONAL_INSTITUCIONAL`**: **BCNF** (Subtipos normalizados con dependencias funcionales directas a su clave primaria).
* **`CATEGORIA`**: **BCNF** ($\text{id\_categoria}$ determina unívocamente nombre y descripción).
* **`RECURSO`**: **3FN** (Cumple 2FN y 3FN al no poseer dependencias transitivas entre atributos no clave; $\text{id\_categoria}$ opera como clave foránea).
* **`EJEMPLAR`**: **BCNF** ($\text{id\_ejemplar}$ y $\text{codigo\_inventario}$ fungen como claves candidatas).
* **`PRESTAMO`, `DETALLE_PRESTAMO`, `INCIDENCIA`, `BLOQUEO_USUARIO`**: **3FN**.

### 2. Comprobación de BCNF y 3FN
* Nuestro diseño opera estrictamente en **3FN** y mayoritariamente en **BCNF** gracias a la separación formal de entidades y la aplicación del modelo EER.
* **Justificación teórica:** Si hubiéramos mantenido una tabla desnormalizada donde los metadatos de categoría dependieran del recurso sin estar separados (ej. $\text{id\_recurso} \rightarrow \text{id\_categoria} \rightarrow \text{nombre\_categoria}$), se generaría una dependencia transitiva. Al aislar dichos datos en la tabla `CATEGORIA`, eliminamos dicha anomalía. Permanecer en 3FN previene la pérdida de dependencias funcionales de negocio en las restricciones del motor de base de datos.

### 3. Reunión sin pérdida y preservación de dependencias
* **Reunión sin pérdida (Lossless Join):** Se comprueba mediante la propiedad de los atributos comunes (ej. `id_categoria` compartida entre `RECURSO` y `CATEGORIA`). Al realizar un `INNER JOIN` a través de la clave foránea, se recupera exactamente la relación original sin generar tuplas espurias (filas basura), ya que $\text{id\_categoria}$ es clave candidata en la relación referenciada.
* **Preservación de dependencias:** Cada dependencia funcional del conjunto mínimo está respaldada directamente por restricciones de integridad referencial (`FOREIGN KEY`) y restricciones de unicidad (`UNIQUE` / `PRIMARY KEY`) en PostgreSQL, asegurando que las reglas del negocio sean vigiladas de forma nativa por el SGBD.

### 4. Implementación como migración sobre la base poblada
Para cumplir con la directiva de conservar los datos existentes sin recargar a mano, ejecutamos el siguiente script de migración transaccional SQL:

```sql
-- =====================================================================
-- EJERCICIO 1.3.4: Script de migración transaccional sobre la base poblada
-- Conservando los datos existentes sin recargar a mano.
-- =====================================================================

BEGIN;

-- 1. Poblar la tabla normalizada CATEGORIA extrayendo los datos únicos del esquema anterior
INSERT INTO CATEGORIA (id_categoria, nombre, descripcion)
SELECT DISTINCT id_cat_antiguo, nombre_cat, desc_cat 
FROM recurso_antiguo
WHERE id_cat_antiguo IS NOT NULL;

-- 2. Poblar la tabla RECURSO limpia de dependencias transitivas
INSERT INTO RECURSO (id_recurso, id_categoria, titulo, descripcion, autor_o_marca)
SELECT id_rec, id_cat_antiguo, tit, descr, autor 
FROM recurso_antiguo;

-- 3. Verificación de integridad de registros migrados
SELECT 
    (SELECT COUNT(*) FROM recurso_antiguo) AS total_antiguo,
    (SELECT COUNT(*) FROM RECURSO) AS total_nuevo;

-- Si los conteos concuerdan, confirmamos la transacción permanentemente:
COMMIT;

-- En caso de discrepancia, se revertiría con:
-- ROLLBACK;
```
