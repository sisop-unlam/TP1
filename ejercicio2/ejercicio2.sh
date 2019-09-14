#!/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio2.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           5
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
	echo 'Descripcion: Este script hace dado un directorio, busca los archivos que tengan uno o ma espacios 
	en sus nombres y los remplaza por el _ y devuelve la cantidad de archivos que se modificaron su nombre '
	echo 'Nombre: ./ejercicio2.sh <DirectorioParametro>'
	echo 'Parametro: <DirectorioParametro> ---Es el directorio donde voy a buscar los archivos con espacios'
	echo 'Ejemplo: ./ejercicio2.sh Escritorio'
	exit

}

validarCantidadParametros() {
	if [ $# -ne 1 ]; then
		echo 'La cantidad de parametros no es correcta'
		echo 'Utilizar la ayuda con -h/-?/-help para mayor informacion'
		exit
	fi

	if [ $1 = '-h' -o $1 = '-?' -o $1 = '-help' ]; then
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

	varArcEsp=$(find "$directorioParametro" -maxdepth 1 -type f -name "* *")

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
validarCantidadParametros $@
archRenombrados=0
buscarDadoDirectorioArchivosTxt $@
echo "Archivos renombrados: " $archRenombrados
