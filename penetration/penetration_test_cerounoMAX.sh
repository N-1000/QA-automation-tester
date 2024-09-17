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
if [ "$EUID" -ne 0 ]
  then echo "ERROR: Por favor, ejecuta el script como root."
  exit
fi

# Configuración de variables (dominio o IP de destino)
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "USO: $0 <dominio o IP de destino>"
    exit 1
fi

RESULTADOS_DIR="resultados/$TARGET"
mkdir -p $RESULTADOS_DIR
cd $RESULTADOS_DIR

echo "Iniciando pruebas de penetración en el objetivo: $TARGET"
echo ""

echo "Ejecutando Nmap para escaneo de puertos..."
echo -n "[                    ] 0% Completo"
nmap -sS -T2 -p 22,80,443,3306,445 $TARGET -oN nmap_scan.txt &> /dev/null
echo -ne "\r[####################] 100% Completo\n"
echo "Escaneo de puertos completado. Resultados guardados en nmap_scan.txt"
echo ""

if grep -q "22/tcp open" nmap_scan.txt; then
    echo "Puerto 22 (SSH) detectado. Realizando verificación..."
    echo -n "[                    ] 0% Completo"
    hydra -s 22 -t 4 -l root -P /ruta/a/wordlist.txt ssh://$TARGET > ssh_hydra_results.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Verificación SSH completada. Resultados guardados en ssh_hydra_results.txt"
    echo ""
fi

if grep -q "80/tcp open" nmap_scan.txt; then
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

if grep -q "443/tcp open" nmap_scan.txt; then
    echo "Puerto 443 (HTTPS) detectado. Realizando escaneo SSL..."
    echo -n "[                    ] 0% Completo"
    nmap --script ssl-enum-ciphers -p 443 --min-rate 100 $TARGET > ssl_scan.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Escaneo de cifrados SSL completado. Resultados guardados en ssl_scan.txt"
    echo ""
fi

if grep -q "3306/tcp open" nmap_scan.txt; then
    echo "Puerto 3306 (MySQL) detectado. Realizando verificación..."
    echo -n "[                    ] 0% Completo"
    hydra -s 3306 -t 4 -l root -P /ruta/a/wordlist.txt mysql://$TARGET > mysql_hydra_results.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Verificación MySQL completada. Resultados guardados en mysql_hydra_results.txt"
    echo ""
fi

if grep -q "445/tcp open" nmap_scan.txt; then
    echo "Puerto 445 (SMB) detectado. Realizando escaneo..."
    echo -n "[                    ] 0% Completo"
    smbclient -L //$TARGET -N > smb_enum_results.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Enumeración SMB completada. Resultados guardados en smb_enum_results.txt"
    echo ""

    echo "Verificando vulnerabilidades SMB con Nmap..."
    echo -n "[                    ] 0% Completo"
    nmap --script vuln -p 445 --min-rate 100 $TARGET > smb_vuln_scan.txt &> /dev/null
    echo -ne "\r[####################] 100% Completo\n"
    echo "Escaneo de vulnerabilidades SMB completado. Resultados guardados en smb_vuln_scan.txt"
    echo ""
fi


echo "***********************************"
echo "  Las pruebas de penetración han finalizado."
echo "  Resultados guardados en la carpeta resultados/$TARGET"
echo "***********************************"
