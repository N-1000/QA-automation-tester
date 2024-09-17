#!/bin/bash

# Encabezado con información de identidad
echo "***********************************"
echo "  Penetration Testing Automation"
echo "  Tester: Nx1000"
echo "  Fecha: $(date)"
echo "  Entorno: ??"
echo "***********************************"
echo ""

# Verificación de permisos de usuario
if [ "$EUID" -ne 0 ]
  then echo "Por favor, ejecuta el script como root."
  exit
fi

# Configuración de variables (dominio o IP de destino y directorio de salida)
TARGET=$1
OUTPUT_DIR="/ruta/a/tu/carpeta/"

if [ -z "$TARGET" ]; then
    echo "Uso: $0 <dominio o IP de destino>"
    exit 1
fi

mkdir -p $OUTPUT_DIR

echo "Iniciando pruebas de penetración en el objetivo: $TARGET"
echo ""

echo "Ejecución de Nmap para escaneo de puertos..."
nmap -sS -A -T4 $TARGET > "${OUTPUT_DIR}nmap_scan.txt"
echo "Escaneo de puertos completado. Resultados guardados en ${OUTPUT_DIR}nmap_scan.txt"
echo ""

echo "Ejecución de Nikto para detectar vulnerabilidades web..."
nikto -h $TARGET > "${OUTPUT_DIR}nikto_scan.txt"
echo "Escaneo de vulnerabilidades completado. Resultados guardados en ${OUTPUT_DIR}nikto_scan.txt"
echo ""

echo "Ejecución de WPScan para detectar vulnerabilidades en WordPress..."
wpscan --url $TARGET --enumerate vp > "${OUTPUT_DIR}wpscan_results.txt"
echo "Escaneo de vulnerabilidades en WordPress completado. Resultados guardados en ${OUTPUT_DIR}wpscan_results.txt"
echo ""

echo "***********************************"
echo "  Las pruebas de penetración han finalizado."
echo "  Resultados guardados en:"
echo "    - ${OUTPUT_DIR}nmap_scan.txt"
echo "    - ${OUTPUT_DIR}nikto_scan.txt"
echo "    - ${OUTPUT_DIR}wpscan_results.txt"
echo "***********************************"

