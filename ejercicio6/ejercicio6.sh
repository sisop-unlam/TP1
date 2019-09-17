#!/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio6.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           6
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

get_help() {

    echo "Nombre: "$0" <Path>"
    echo 'Descripción: Este script muestra los 10 subdirectorios más grandes de un directorio, los cuales no contienen otros directorios adentro'
    echo '-------------------------------------------------------------------'
    echo 'Parámetro: <Path> --- es un parámetro con el directorio a analizar'
    echo "Ejemplo: "$0" ~/Desktop"

    exit
}

verificar_parametros() {
    if [ "$#" -ne 1 ]; then
        echo 'La cantidad ingresada de parámetros no es correcta'
        echo 'Utilizar -h/-?/-help para ver la ayuda'
        exit -1
    fi

    if [ $1 = '-h' -o $1 = '-?' -o $1 = '-help' ]; then
        get_help
        exit 1
    fi

    if ! [ -d "$1" -a -r "$1" ]; then
        echo "Ingrese un directorio válido."
        exit 1
    fi
}

verificar_parametros $@

dir="$1"

#Para no mostrar los path relativos
cd "$dir"
ABSPATH="$(pwd)"

#Busco los directorios en los que tengo permiso de lectura
#Es recursivo
directorios=$(find "$ABSPATH" ! -readable -prune -o -type d -print)

#Arreglo el IFS
IFS="
"

#Declaro un array para los registros
registros=()

#Recorro los directorios que halle anteriormente
for f in $directorios; do
    #Si puedo leerlo
    if [ -r "$f" ]; then
        #Cuento la cantidad de directorios que tengo
        cantidadDirectorios=$(ls -l "$f" | grep "^d" | wc -l)

        #Si no tiene subdirectorios, entonces debo hacer el analisis
        if [ $cantidadDirectorios -eq 0 ]; then
            cantidadArchivos=$(ls "$f" | wc -l)

            #Si no tengo archivos, me devolveria 4KB, porque tengo a . y ..
            #Pero la cuenta de archivos sera 0, por lo que no me interesan
            if [ $cantidadArchivos -ne 0 ]; then
                tamanyoActual=$(du -sh "$f" | cut -f1)

                #Reemplazo el /home/ por la virgulilla
                nombreAbreviado=$(echo "$f" | sed "s|^$HOME|~|")

                #Agrego al array mi cadena con informacion
                registros+=($nombreAbreviado" "$tamanyoActual" "$cantidadArchivos" "arch.)
            fi
        fi
    fi
done

#Ordeno el array por la segunda columna, usando las distintas flags
#La flag h, es por human, para que lea correctamente los tamaños
#La flag r, es por reverse
#La flag k, es por la columna que ordena
#Luego, obtiene los primeros 10
arrOrdenado=($(sort -hrk 2,2 <<<"${registros[*]}" | head -10))

#Finalmente, muestra el resultado
for ((i = 0; i < ${#arrOrdenado[@]}; i++)); do
    echo "${arrOrdenado[$i]}"
done
