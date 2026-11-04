# bda-equipo-8-puzzles

Equipo 8 · Manejo Masivo de Datos · Ejemplo de MapReduce: **pentomino** (comparado con **sudoku**).

> Antes de empezar necesitas el contenedor `hadoop` con Hadoop 3.3.6 de la práctica *Hadoop Standalone en contenedor Debian*.

Leyenda de los bloques de código:

- 💻 se escribe en la terminal **de tu computadora**
- 🐳 se escribe **dentro del contenedor** (el prompt dice `hadoop@hadoop` o `root@hadoop`)

## 1. ¿Qué hace pentomino?

Llena un tablero con piezas de 5 cuadros (pentominós), sin huecos ni traslapes, y busca **todas** las soluciones. Es un problema de cobertura exacta, que se resuelve con el algoritmo *dancing links* de Knuth.

- Versión de un solo lado: 18 piezas × 5 casillas = 90 casillas, es decir un tablero de 9×10 (valor por defecto).
- Juego estándar: 12 piezas × 5 casillas = 60 casillas, por ejemplo un tablero de 6×10 (se elige con la opción `-D`, ver 3.2).
- Caso real parecido: cortar piezas de una lámina o armar horarios sin choques.

## 2. ¿Cómo funciona con Map y Reduce?

1. Antes del job se genera una lista de **prefijos** (movimientos iniciales de la búsqueda). El largo lo controla `-depth` (por defecto 5). Es un archivo con un prefijo por línea y es la entrada del job.
2. **Map**: cada map recibe un prefijo y busca todas las soluciones que empiezan con él. Emite *(prefijo, tablero resuelto)*.
3. **Reduce**: hay un solo reduce, el reducer base, que no cambia nada y junta todo en `part-r-00000`.

Por defecto el job se reparte hasta en 2000 maps.

```
prefijos (1 por línea) ──► MAP ×N ──► REDUCE ×1 ──► part-r-00000
                          (busca)     (identidad)    (prefijo + tablero)
```

## 3. Cómo reproducirlo

### 3.1 Entrar al contenedor

💻
```bash
docker start hadoop
docker exec -it hadoop bash
```

Si dentro del contenedor `hadoop` dice `command not found` o `JAVA_HOME is not set`, carga las variables:

🐳
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=/opt/hadoop-3.3.6
export PATH=$PATH:$HADOOP_HOME/bin
hadoop version
```

Para no repetirlo cada vez, agrega esas tres líneas `export` al final de `~/.bashrc`.

### 3.2 Ejecutar pentomino

🐳
```bash
cd ~
rm -rf salida_pent
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar \
  pentomino -Dmapreduce.pentomino.class=org.apache.hadoop.examples.dancing.Pentomino \
  salida_pent -width 6 -height 10 -depth 5
```

Esta es la versión de la demo: el juego **estándar de 12 piezas** en un tablero de 6×10 (12 × 5 = 60 casillas). Tiempo que tardó en el equipo: **[Completar: tiempo]**.

> ⚠️ Sin la opción `-D...` el comando usa el juego de **un solo lado** (18 piezas), que necesita un tablero de 90 casillas (por defecto 9×10, que según la documentación tarda horas incluso en un clúster). En un tablero de 60 casillas no hay solución y la salida queda vacía (`Map output records=0`).

Uso: `pentomino <salida> [-depth #] [-height #] [-width #]`. Si la carpeta `salida_pent` ya existe, bórrala o cambia el nombre.

### 3.3 Ver el resultado

🐳
```bash
head -n 25 salida_pent/part-r-00000
```

Cada solución aparece como una línea con el prefijo (por ejemplo `1,0,0,1,9`) y debajo el tablero de 6 columnas × 10 filas, con una letra por pieza. Una muestra real de la salida está en [`resultados/muestra-salida.txt`](resultados/muestra-salida.txt).

### 3.4 Copiar el resultado a tu computadora

💻
```bash
docker cp hadoop:/root/salida_pent/part-r-00000 resultados/part-r-00000
```

Si ejecutaste el comando desde `~` como `root`, la ruta es `/root/salida_pent`; si no, usa la carpeta que te muestre `pwd`.

## 4. Comparación con sudoku

| | Pentomino | Sudoku |
|---|---|---|
| Algoritmo | Dancing links | Dancing links |
| En Hadoop | Distribuido: un map por prefijo | Un solo proceso, sin MapReduce |
| Entrada | Se genera sola a partir de `-depth` | Archivo de texto, `?` en las casillas vacías |
| Tiempo | Horas en el tablero de 9×10 | Cerca de un segundo por puzzle |

Para sudoku usa el mismo archivo de puzzle de la práctica.

## 5. Mini ejercicio

Ver [`ejercicio/ejercicio.md`](ejercicio/ejercicio.md). La solución está en [`ejercicio/solucion.md`](ejercicio/solucion.md).

## 6. Estructura del repositorio

```
bda-equipo-8-puzzles/
├── README.md
├── datos/
├── scripts/ejecutar.sh
├── resultados/
├── ejercicio/ejercicio.md
├── ejercicio/solucion.md
└── presentacion.pdf
```

## Fuentes

- Documentación de Apache Hadoop, paquete `org.apache.hadoop.examples.dancing`.
- Código fuente de `DistributedPentomino`.
