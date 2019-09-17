# !/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio5.sh
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

#Constantes utiles para trabajar con los archivos
directorio=$(echo ~)/.papelera
infoPapelera="$directorio"/info/info.dat
directorioArchivos="$directorio"/files
directorioInfo="$directorio"/info
PATH_RESTORE=""

#Error generico
parametrosIncorrectos() {
      echo 'La cantidad de parámetros ingresada no es correcta'
      echo "Para obtener ayuda sobre el script utilice -h o -help o -?"
      exit
}
#-------------------------------------------------#

#Funcion de ayuda
mostrarAyuda() {
      echo "Nombre: "$0" <Path> [-l] [-r] [-e]"
      echo 'Descripción: Este script emula el comportamiento del comando rm, pero utilizando el concepto de la papelera de reciclaje.'
      echo '-------------------------------------------------------------------'
      echo 'Parámetros:'
      echo '  -l              Lista los archivos que contiene la papelera de reciclaje'
      echo '  -r [archivo]    Recupera un archivo ubicado en la papelera de reciclaje'
      echo '  -e              Vacia la papelera de reciclaje'
      echo "Ejemplo: "$0" ~/carpeta1/"
      exit
}

#Validacion de parámetros
validaParam() {
      if [ $# -eq 0 ]; then
            parametrosIncorrectos
      fi

      if [ $# -gt 2 ]; then
            #Redirecciona a la funcion correspondiente
            parametrosIncorrectos
      fi

      if [ $# -eq 2 ]; then
            FILE="$2"
            #Si tengo -r, me fijo si existe ese archivo en la lista
            #evalArch tendra un 1 en el caso de haber encontrado el mismo en la lista
            evalArch=$(awk -v arch="$FILE" -F"\t" '{
                        if ($2 == arch)
                        {
                              print 1;exit;
                        }
                  }' "$infoPapelera" 2>/dev/null)

            #Si no encontre ese archivo en la papelera, imprime por stdout
            if [[ "$1" == '-r' && $evalArch != 1 ]]; then
                  echo "Ingrese un archivo presente en la papelera de reciclaje."
                  exit 1
            fi
      fi

      #En el caso de tener un unico parámetro
      if [ $# -eq 1 ]; then
            #ayuda y me voy
            if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
                  mostrarAyuda
                  exit 1
            fi

            #Si no es una carpeta/archivo válido, informa y sale
            if ! [ -e "$directorio" ]; then
                  echo "Ingrese un directorio o archivo válido"
                  exit 1
            fi

            #Compruebo si estoy poniendo bien el parámetro
            if [ "$1" != '-l' -a "$1" != '-e' ]; then

                  #En caso de que se haya puesto -r y se haya omitido el path
                  if [ "$1" = '-r' ]; then
                        echo "Ingrese el archivo que desea recuperar."
                        exit
                  fi

                  #Si el archivo ingresado (A eliminar) no existe
                  if ! [ -e "$1" ]; then
                        echo "Archivo inexistente."
                        exit 1
                  fi
            fi
      fi
}
#-------------------------------------------------#

#Validacion de la papelera, en caso de no existir la carpeta, la crea
validaPapelera() {
      if ! [ -d "$directorio" ]; then
            $(mkdir "$directorio")
            $(mkdir "$directorioArchivos")
            $(mkdir "$directorioInfo")
            $(touch "$infoPapelera")
            echo "Papelera creada!"
            echo ""
      fi
}

#Muestra la papelera
mostrarPapelera() {
      #Imprimo path y fecha de eliminación
      arch=$(awk -F"\t" '{print $3,"\t",$2}' "$infoPapelera" 2>/dev/null)
      if [[ $arch == "" ]]; then
            echo "No hay archivos en la papelera de reciclaje."
      else
            echo ''
            echo 'Archivos que contiene la papelera de reciclaje'
            echo '=============================================='
            echo 'Fecha                    Nombre del archivo'
            echo ''

            for i in "$arch"; do
                  echo "$i"
            done
            echo ''
      fi
}

#####################################################
#chequea si esta duplicado
#en caso de estar duplicado, pregunta si quiere reemplazar, mover con otro nombre (agregandole el (N)) o cancelar
comprobarDuplicado() {
      local directorio=$(echo "$1" | awk 'BEGIN {FS="\t"}{print $2}' 2>/dev/null)

      if [ -e "$directorio" ]; then
            esArchDuplicado=1
            echo "$directorio existe!"
            echo ""
            unset decision
            #Validacion de decision
            while [[ ! $decision =~ ^(r|m|c)$ ]]; do
                  read -p "Qué desea realizar? [r]eemplazar/[m]antener ambos/[c]ancelar: " decision
            done
            case $decision in
            r)
                  mover "$1"
                  ;;
            m)
                  obtenerNombreNuevo "$1"
                  ;;
            c)
                  exit
                  ;;
            esac
      fi
}
######################################################################

obtenerNombreNuevo() {
      local directorio=$(echo "$1" | awk 'BEGIN {FS="\t"}{print $2}' 2>/dev/null)

      theFileName="$directorio"

      name="${theFileName%.*}"

      extension=$([[ "$theFileName" == *.* ]] && echo ".${theFileName##*.}" || echo '')

      if [ "${theFileName}" = "${extension}" ]; then
            name=${theFileName}
            extension=""
      fi

      #https://stackoverflow.com/questions/12187859/create-new-file-but-add-number-if-filename-already-exists-in-bash
      #Ya se comprobo antes, podria obviarse
      if [[ -e "$directorio" ]]; then

            j=2
            while [[ -e "$name""($j)"$extension ]]; do
                  let j++
            done
            name="$name""($j)""$extension"

      else
            name="$name""$extension"
      fi

      mover "$1" "$name"
}

mover() {

      local nombreEncriptado=$(echo "$1" | awk 'BEGIN {FS="\t"}{print $1}' 2>/dev/null)
      local dirOriginal=$(echo "$1" | awk 'BEGIN {FS="\t"}{print $2}' 2>/dev/null)

      if [ $# -eq 1 ]; then
            dirOriginal="$dirOriginal"
      else
            dirOriginal="$2"
      fi

      $(mv "$directorioArchivos"/$nombreEncriptado "$dirOriginal")

      $(awk -v pat="$nombreEncriptado" 'BEGIN{RS="\n";FS="\t"} {
                  if ($1 != pat)
                  {
                        print $0
                  }
            }' $infoPapelera >"$directorioInfo"/temp && mv "$directorioInfo"/temp "$infoPapelera")
}

comprobarDuplicadoEnLista() {
      FILE="$1"
      #Si tengo -r, me fijo si existe ese archivo en la lista
      #evalArch tendra un 1 en el caso de haber encontrado el mismo en la lista
      evalArch2=$(awk -v arch="$FILE" -F"\t" '{
                        if ($2 == arch)
                        {
                              COUNT++
                        }
                  } END { print COUNT } ' "$infoPapelera" 2>/dev/null)

      #Si no encontre ese archivo en la papelera, imprime por stdout
      if [[ "$1" == '-r' && $evalArch2 == 0 ]]; then
            echo "Ingrese un archivo presente en la papelera de reciclaje."
            exit 1
      fi
      if [ $evalArch2 -gt 1 ]; then
            echo ""
            echo "Se encontraron varios archivos con el mismo nombre en la papelera de reciclaje"
            echo "Determine que archivo desea restaurar observando la fecha y hora de eliminación"
            echo "==============================================================================="

            #Imprimo path y fecha de eliminación
            archNombreRepetido=$(awk -v arch="$FILE" -F"\t" 'BEGIN{NUM=1}{
                        if ($2 == arch)
                        {
                              print NUM")  " $2,"\t",$3;NUM++
                        } 
                   }' "$infoPapelera" 2>/dev/null)

            #Imprimo path y fecha de eliminación
            numMaximo=$(awk -v arch="$FILE" -F"\t" 'BEGIN{NUM=1}{
                        if ($2 == arch)
                        {
                        NUM++
                        } 
                   } END {print NUM}' "$infoPapelera" 2>/dev/null)

            #Me pase en uno, entonces le resto
            numMaximo=$(($numMaximo - 1))

            #Muestro la lista
            for j in "$archNombreRepetido"; do
                  echo "$j"
            done

            unset decisionNumerica
            #Validacion de decision
            while [[ $decisionNumerica -lt 1 || $decisionNumerica -gt $numMaximo ]]; do
                  read -p "Ingrese el número de archivo: " decisionNumerica
            done
            echo ""
            echo "Archivo #$decisionNumerica elegido"
            echo ""

            #Imprimo path y fecha de eliminación
            archElegido=$(awk -v opc="$decisionNumerica" -v arch="$FILE" -F"\t" 'BEGIN{NUM=1}{
                        if ($2 == arch)
                        {
                              if (NUM == opc)
                              {
                                    print $0;
                                    exit;
                              }
                              NUM++
                        } 
                   }' "$infoPapelera" 2>/dev/null)

            PATH_RESTORE="$archElegido"
      else
            archElegido=$(awk -v arch="$FILE" -F"\t" '{
                        if ($2 == arch)
                        {
                              print $0;exit;
                        }
                  } ' "$infoPapelera" 2>/dev/null)
            PATH_RESTORE="$archElegido"
      fi
}

restaurar() {
      esArchDuplicado=0

      #En el caso de tener varios que se llaman igual
      comprobarDuplicadoEnLista "$2"

      #con esto me guardo tal cual figura en la lista, esto lo voy a usar para buscar!
      #PATH_MOVE="$2"

      #Compruebo duplicado
      comprobarDuplicado "$PATH_RESTORE"

      if [[ $esArchDuplicado == 0 ]]; then
            mover "$PATH_RESTORE"
      fi

      echo "Archivo restaurado correctamente"
      exit
}

vaciarPapelera() {
      unset decisionVaciarPapelera
      #Validacion de decisionVaciarPapelera
      while [[ ! $decisionVaciarPapelera =~ ^(n|N|S|s)$ ]]; do
            read -p "Está seguro que desea vaciar la papelera de reciclaje? [S]i/[N]o: " decisionVaciarPapelera
      done
      if [[ $decisionVaciarPapelera == 'n' || $decisionVaciarPapelera == 'N' ]]; then
            exit
      fi

      $(rm -rf "$directorioArchivos" && mkdir "$directorioArchivos")
      $(cat /dev/null >"$infoPapelera")

      echo "Papelera de reciclaje limpia!"
}

eliminar() {
      FILE="$1"

      if ! [ -w "$FILE" ]; then
            echo "No se poseen permisos sobre el archivo $FILE"
            exit
      fi

      #Verifica si es PATH_MOVE absoluto o relativo
      if [ "${FILE:0:1}" = "/" ]; then
            nombreOriginal=$FILE
      else
            nombreOriginal=$(echo "$(pwd)/"$FILE)
      fi

      #Aca arreglo si me mandan algo relativo etc
      PATH_VIEJO=$(pwd)
      PATH_FILE_DELETE=$(dirname "${nombreOriginal}")
      cd "$PATH_FILE_DELETE"
      ABSPATH=$(pwd)

      FILE_BASENAME=$(basename "${nombreOriginal}")
      nombreOriginal="$ABSPATH"/"$FILE_BASENAME"
      cd $PATH_VIEJO

      #Para identificar mejor
      FECHA_Y_HORA=$(date "+%d/%m/%y %H:%M:%S")

      nombreEncriptado=$(echo -n "$(pwd)/"$nombreOriginal | openssl dgst -sha1 | awk '{print $2}')
      local evalArch=$(awk -v arch="$nombreOriginal" -F"\t" '{
                        if ($2 == arch)
                        {
                              CAD=$1
                        }
                  } END{print CAD}' "$infoPapelera" 2>/dev/null)

      if [[ $evalArch != "" ]]; then
            numero="${evalArch: -1}"
            numero=$((numero + 1))
            nombreEncriptado="$nombreEncriptado"-$numero
      else
            nombreEncriptado="$nombreEncriptado"-1
      fi

      #En el caso de la carpeta, solamente encripto el nombre de la carpeta principal NADA MAS, EL RESTO QUEDA IDENTICO
      $(echo "$nombreEncriptado"$'\t'"$nombreOriginal"$'\t'"$FECHA_Y_HORA" >>"$infoPapelera")
      $(mv "$nombreOriginal" "$directorioArchivos"/"$nombreEncriptado")
      echo "Operación correcta."
}
###########################MAIN########################################

validaPapelera

validaParam "$@"

if [ -e "$1" ]; then
      eliminar "$@"
else
      case $1 in
      -l) mostrarPapelera ;;
      -r) restaurar "$@" ;;
      -e) vaciarPapelera ;;
      esac
fi
