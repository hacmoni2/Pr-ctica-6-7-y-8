#  Almacén Asignado y Formas Normales


---

## Ejercicio 1.4. El almacén asignado, frente a las formas normales

En el análisis de los almacenes dimensionales (Data Warehouses), la estructura difiere sustancialmente de las bases de datos transaccionales operativas (OLTP):

* **Forma normal de las dimensiones:** Las tablas dimensionales de un almacén se encuentran intencionalmente desnormalizadas, ubicándose típicamente en **2FN o una 3FN rebajada (esquema en estrella o copo de nieve controlado)**. Por ejemplo, en una dimensión de recursos o de usuarios, se suelen replicar atributos descriptivos (como el nombre de la categoría, el departamento o el rol) directamente dentro de la misma tabla dimensional.
* **Dependencia transitiva que conserva:** Conserva de forma deliberada dependencias transitivas del tipo $\text{id\_recurso} \rightarrow \text{id\_categoria} \rightarrow \text{nombre\_categoria}$ dentro de una misma tabla dimensional.
* **Qué gana el almacén al conservarla:** **Rendimiento analítico masivo (OLAP)**. Al evitar operaciones complejas de cruce (`JOIN`) entre 4 o 5 tablas maestras normalizadas en cada consulta de Business Intelligence o generación de reportes históricos, las consultas de agregación sobre millones de registros de préstamos y sanciones se ejecutan de forma instantánea.

**Cuándo conviene desnormalizar y qué vigilar:**
* Conviene desnormalizar exclusivamente en entornos orientados a lectura analítica masiva (Data Warehouses), donde las operaciones de escritura son por lotes (ETL) y la prioridad absoluta es la velocidad de consulta. 
* Si se aplicara esta misma técnica en un proyecto transaccional operativo propio (OLTP) como nuestro sistema de gestión en ESCOM, el aspecto crítico a vigilar sería la **anomalía de actualización**: si el nombre de una categoría cambia en el sistema, requeriría actualizar miles de registros históricos de manera simultánea en lugar de modificar una única tupla en una tabla normalizada, comprometiendo gravemente la consistencia de los datos en tiempo real.
