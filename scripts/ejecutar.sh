#!/usr/bin/env bash
# Se ejecuta DENTRO del contenedor "hadoop".
# Uso: bash ejecutar.sh [ancho] [alto] [profundidad]
# Por defecto corre el juego estándar de 12 piezas en un tablero de 6x10.
# El tablero debe tener 60 casillas (12 piezas x 5), p. ej. 6x10, 5x12, 4x15 o 3x20.
set -e

ANCHO="${1:-6}"
ALTO="${2:-10}"
PROF="${3:-5}"
SALIDA="salida_pent"

export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop-3.3.6}"
export PATH="$PATH:$HADOOP_HOME/bin"
JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"

# Si ya existe una salida anterior, el job falla: se borra antes.
rm -rf "$SALIDA"

hadoop jar "$JAR" pentomino \
  -Dmapreduce.pentomino.class=org.apache.hadoop.examples.dancing.Pentomino \
  "$SALIDA" -width "$ANCHO" -height "$ALTO" -depth "$PROF"

echo "Primeras líneas del resultado:"
head -n 25 "$SALIDA/part-r-00000"
