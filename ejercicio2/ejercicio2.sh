#!/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio2.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           2
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
	echo "Nombre: $0 <directorioParametro> [-r]"
	echo 'Descripción: Este script, dado un directorio, busca los archivos que tengan uno o mas espacios 
	en sus nombres y los remplaza por un guion bajo ( _ ) y devuelve la cantidad de archivos a los que se les modificó su nombre '
	echo '--------------------------------------------------------------------------------'
	echo 'Parámetros: '
	echo '	<directorioParametro> --- Es el directorio donde voy a buscar los archivos con espacios'
	echo '	[-r] --- Parámetro opcional que permite la busqueda recursiva en subdirectorios'
	echo "Ejemplo A: "$0" Escritorio"
	echo "Ejemplo B: "$0" Escritorio -r"

	exit

}

validarCantidadParametros() {
	if [[ $# -lt 1 || $# -gt 2 ]]; then
		echo 'La cantidad de parámetros no es correcta'
		echo 'Utilizar la ayuda con -h/-?/-help para mayor informacion'
		exit
	fi

	if [[ $# -eq 2 && "$2" != '-r' ]]; then
		echo 'Parámetro incorrecto'
		echo 'Utilizar la ayuda con -h/-?/-help para mayor informacion'
		exit
	fi

	if [[ "$1" == "-h" || "$1" == "-?" || "$1" == "-help" ]]; then
		getHelp
		exit
	fi

	if ! [ -d "$1" ]; then
		echo "Ingrese un directorio válido."
		exit
	fi
}

buscarDadoDirectorioArchivosTxt() {

	if [ $# -eq 0 ]; then
		directorioParametro="$(pwd)"
	else
		directorioParametro="$1"
	fi

	#Parámetro -r
	if [[ $# -eq 2 && $2 == '-r' ]]; then
		varArcEsp=$(find "$directorioParametro" -type f -perm -a+r -name "* *")
	else
		varArcEsp=$(find "$directorioParametro" -maxdepth 1 -type f -perm -a+r -name "* *")
	fi

	IFS="
	"
	for i in $varArcEsp; do
		arch=$(echo "$i" | tr -s " ")
		nombreArchivo="${arch##*/}"

		archNuevo="${nombreArchivo// /_}"
		directorioBase=${arch%/*}

		nombre="${archNuevo%.*}"
		extension=$([[ "$archNuevo" == *.* ]] && echo ".${archNuevo##*.}" || echo '')

		# En caso de que se trate de un archivo sin extension
		if [ "${archNuevo}" = "${extension}" ]; then
			nombre=${archNuevo}
			extension=""
		fi

		#Si ya existe ese archivo, tengo que obtener un nombre alternativo
		if [[ -e "$directorioBase"/$nombre$extension ]]; then
			j=2
			while [[ -e "$directorioBase"/$nombre"($j)"$extension ]]; do
				#hago un j++
				let j++
			done
			nombre=$nombre"($j)"$extension
		else
			nombre=$nombre$extension
		fi
		#echo "$i" "$directorioBase"/"$nombre"
		mv "$i" "$directorioBase"/"$nombre"
		archRenombrados=$((archRenombrados + 1))
	done
}

validarCantidadParametros "$@"
archRenombrados=0
buscarDadoDirectorioArchivosTxt "$@"
echo "Archivos renombrados: " $archRenombrados
