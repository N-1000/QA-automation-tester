#!/bin/bash

# Encabezado con información de identidad
echo "***********************************"
echo "  Penetration Testing Automation"
echo "  Tester: Nx1000"
echo "  Fecha: $(date)"
echo "  Entorno: Test"
echo "***********************************"
echo ""

# Verificación de permisos de usuario
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Por favor, ejecuta el script como root."
    exit
fi

# Configuración de variables (dominio o IP de destino)
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "USO: $0 <dominio o IP de destino>"
    exit 1
fi

# Directorio para guardar resultados
RESULTADOS_DIR="resultados/$TARGET"
mkdir -p $RESULTADOS_DIR
cd $RESULTADOS_DIR

# Ejecución de pruebas de penetración
echo "Iniciando pruebas de penetración en el objetivo: $TARGET"
echo ""

# 1. Escaneo de puertos con Nmap (sigiloso)
echo "Ejecutando Nmap para escaneo de puertos (sigiloso)..."
echo -n "[                    ] 0% Completo"
nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $TARGET -oG allPorts &> /dev/null
echo -ne "\r[####################] 100% Completo\n"
echo "Escaneo de puertos completado. Resultados guardados en allPorts"
echo ""

# Extraer puertos abiertos
OPEN_PORTS=$(grep '/tcp open' allPorts | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

if [ -z "$OPEN_PORTS" ]; then
    echo "No se detectaron puertos abiertos."
    exit 1
fi

echo "Puertos abiertos detectados: $OPEN_PORTS"
echo ""

# 2. Escaneo detallado de servicios
echo "Ejecutando Nmap para escaneo detallado de servicios en puertos abiertos..."
echo -n "[                    ] 0% Completo"
nmap -p$OPEN_PORTS -sCV $TARGET -oN targeted &> /dev/null
echo -ne "\r[####################] 100% Completo\n"
echo "Escaneo detallado completado. Resultados guardados en targeted"
echo ""

if grep -q "22/tcp" targeted; then
    echo "Puerto 22 (SSH) detectado. Realizando verificación..."
    echo -n "[                    ] 0% Completo"
    hydra -s 22 -t 4 -l root -P /ruta/a/wordlist.txt ssh://$TARGET > ssh_hydra_results.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Verificación SSH completada. Resultados guardados en ssh_hydra_results.txt"
    echo ""
fi

if grep -q "80/tcp" targeted; then
    echo "Puerto 80 (HTTP) detectado. Realizando escaneo..."
    echo -n "[                    ] 0% Completo"
    gobuster dir -u http://$TARGET -w /ruta/a/wordlist.txt -t 5 > gobuster_results.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Escaneo de directorios completado. Resultados guardados en gobuster_results.txt"
    echo ""

    echo "Verificando vulnerabilidades web con Nikto..."
    echo -n "[                    ] 0% Completo"
    nikto -h http://$TARGET -C all -T 2 > nikto_scan.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Escaneo de vulnerabilidades web completado. Resultados guardados en nikto_scan.txt"
    echo ""

    if grep -q "WordPress" nikto_scan.txt; then
        echo "WordPress detectado. Escaneando vulnerabilidades con WPScan..."
        echo -n "[                    ] 0% Completo"
        wpscan --url http://$TARGET --enumerate vp --random-agent > wpscan_results.txt &> /dev/null
        echo -ne "\r[####################] 100% Completo\n"
        echo "Escaneo de vulnerabilidades de WordPress completado. Resultados guardados en wpscan_results.txt"
        echo ""
    else
        echo "No se detectó WordPress en el puerto 80."
    fi
fi

echo "***********************************"
echo "  Las pruebas de penetración han finalizado."
echo "  Resultados guardados en la carpeta resultados/$TARGET"
echo "***********************************"
