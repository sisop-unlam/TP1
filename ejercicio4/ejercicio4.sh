#!/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio4.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           4
# Entrega Nro.:             1
# Integrantes:
#
#    Apellido            Nombre                  DNI
#    --------------------------------------------------
#
#    Krasuk              Joaquín               40745090
#    Rodriguez           Christian             37947646
#    Vernet              Federico              38421847
#    Vivas               Pablo                 38703964
#
#***********************************************************************************

getHelp() {
    echo "Nombre: "$0" <DirectorioParámetro> <Extension>"
    echo 'Descripción: Este script cuenta la cantidad de líneas de codigo y de comentarios
            que posean una ruta pasada por parámetro y controlando solos los archivos con
            cierta extension '
    echo '-------------------------------------------------------------------'
    echo 'Parámetros:'
    echo '  <DirectorioParámetro> --- Es el directorio donde voy a buscar los archivos '
    echo '  <Extension> --- Es la extensión de los archivos a analizar'
    echo "Ejemplo: "$0" Escritorio .txt"
    exit

}

validarParametros() {
    if [ -d "$1" ]; then
        directorioParametro=$1
    else
        echo "No es un directorio valido"
    fi
    VARIABLE_DIR="$2"
    primerCaracterExtension="${VARIABLE_DIR:0:1}" #Con esto me quedo con el primer caracter de ExtensionArch

    if [[ $primerCaracterExtension == "," || $primerCaracterExtension == "-" ]]; then
        ExtensionArch=${VARIABLE_DIR/$primerCaracterExtension/.}
        #si se confundio y puso ",txt" o "-txt" reemplazamos "," o "-" por "." en la extension original

    elif [ $primerCaracterExtension=="." ]; then
        ExtensionArch="$2"
    fi

}

if [ $# -eq 2 ]; then
    validarParametros "$@"
elif [[ "$1" == '-h' || "$1" == '-?' || "$1" == '-help' ]]; then
    getHelp
    exit 1
else
    echo 'Ingresó mal los parámetros, vuelva a ingresar'
    echo 'Utilizar la ayuda con -h/-?/-help para mayor informacion'
    exit
fi

#Me acomodo en el dir, para evitar problemas con relativos,etc
ABSPATH_OG=$(pwd)
cd "$directorioParametro"
ABSPATH=$(pwd)
cd "$ABSPATH_OG"

#Si busco archivos sin extension
if [[ $ExtensionArch != "" ]]; then
    #Busca archivos que se puedan leer, en el directorio actual y con una detemrinada extension
    varArchivos=$(find "$ABSPATH" ! -perm -a+r -prune -o -type f -name "*$ExtensionArch" -print) #Me quedo con los archivos de ExtensionArch
else
    varArchivos=$(find "$ABSPATH" ! -perm -a+r -prune -o -type f ! -name "*.*" -print)
fi
#Si mi find devolvio "", entoncs mi cantArchivos es cero
if [[ "$varArchivos" == "" ]]; then
    cantArchivosAnalizados=0
else
    cantArchivosAnalizados=$(echo "$varArchivos" | wc -l) #Cuento los archivos
fi

lineasSlash=0
lineasSlashCodigo=0
lineasTotales=0
lineasSlashCodigoInternasMultilinea=0
lineasComment=0
IFS="
"
for i in $varArchivos; do
    #Cuento los comenarios con //
    aux_lineasSlash=$(awk 'BEGIN { }
    /\/\// { ++SLASH }
    END {printf SLASH}
    ' "$i")
    lineasSlash=$((lineasSlash + aux_lineasSlash))

    #Cuento las lineas de codigo que TIENEN UN COMENTARIO
    aux_lineasSlashCodigo=$(awk 'BEGIN { }
    /^[a-zA-Z0-9]+[ ]*(\/\/|\/\*)/ { ++SLASHCODE}
    END {printf SLASHCODE}
    ' "$i")
    lineasSlashCodigo=$((lineasSlashCodigo + aux_lineasSlashCodigo))

    #Lineas totales
    aux_lineasTotales=$(awk 'BEGIN { }
    NF > 0 { ++TOTAL }
    END {printf TOTAL}' "$i")
    lineasTotales=$((lineasTotales + aux_lineasTotales))

    #Comentarios multilinea, print
    commentMultilinea=$(awk 'BEGIN { }
    /\/\*/,/\*\// {print}
    ' "$i")

    #Aca cuento los comentarios // anidados en un multilinea
    aux_lineasSlashCodigoInternasMultilinea=$(echo "$commentMultilinea" | awk 'BEGIN { }
    /\/\// { ++SLASHINTERNA }
    END {printf SLASHINTERNA}
    ')
    lineasSlashCodigoInternasMultilinea=$((lineasSlashCodigoInternasMultilinea + aux_lineasSlashCodigoInternasMultilinea))

    #Comentarios multilinea, count
    aux_lineasComment=$(awk 'BEGIN { }
    /\/\*/,/\*\// { ++MULTI }
    END {printf MULTI }
    ' "$i")
    lineasComment=$((lineasComment + aux_lineasComment))

done

lineasCodigo=$(($lineasTotales + $lineasSlashCodigo - $lineasComment - $lineasSlash + $lineasSlashCodigoInternasMultilinea))
lineasComentarios=$(($lineasComment + $lineasSlash - $lineasSlashCodigoInternasMultilinea))
echo "CANTIDAD DE ARCHIVOS ANALIZADOS: "$cantArchivosAnalizados
#echo "LINEAS TOTALES: "$lineasTotales
#echo "LINEAS COMENTARIOS: "$lineasComentarios
#echo "    MULTILINEA: "$lineasComment
#echo "    LÍNEA ÚNICA: "$lineasSlash
#echo "LINEAS CÓDIGO: "$lineasCodigo
echo "LÍNEAS CODIGO/LÍNEAS TOTALES: "$(awk -vn=$lineasCodigo -vm=$lineasTotales 'BEGIN{if(m==0)m=1;print(n/m)*100}')"%"
echo "LÍNEAS COMENTARIOS/LÍNEAS TOTALES: "$(awk -vn=$lineasComentarios -vm=$lineasTotales 'BEGIN{if(m==0)m=1;print(n/m)*100}')"%"
