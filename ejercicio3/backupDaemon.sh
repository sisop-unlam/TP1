#!/bin/bash

#***********************************************************************************
# Nombre Del Script:        backupDaemon.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           3
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

start() {
   #Guardo la carpeta del script, para crear mi archivo de control
   CARPETA_SCRIPT="$(pwd)"
   FECHA_Y_HORA=$(date "+%d-%m-%y_%H-%M-%S")
   NOMBRE_ARCHIVO="Backup_$FECHA_Y_HORA.tgz"
   #Hago el mkdir correspondiente
   #no error if existing, make parent directories as needed
   mkdir -p "$3"
   #Para no mostrar los path relativos
   cd "$3"
   CARPETA_DESTINO="$(pwd)"
   cd "$2"
   CARPETA_BACKUP="$(pwd)"

   #Creo mi archivo de control
   cd "$CARPETA_SCRIPT"

   #Imprimo en orden
   echo "$CARPETA_DESTINO" >dest.tmp
   echo "$CARPETA_BACKUP" >>dest.tmp

   #Oculto los posibles notice por ejemplo por barras
   tar cfz "$CARPETA_DESTINO"/"$NOMBRE_ARCHIVO" "$CARPETA_BACKUP" 2>/dev/null

   echo "$NOMBRE_ARCHIVO"" ------------------ Creado con éxito"

   #esta parte es para ponerlo en segundo plano con un intervalo de tiempo
   trap start SIGUSR1
   while true; do
      sleep $4 &#$4 es el parametro del intervalo en segundos
      wait $!
      start "$@"
   done
}

stop() {
   proceso=$(ps aux | grep "[b]ackup.sh" | awk '{print $2;exit}')

   if [[ $proceso != $$ ]]; then
      #Envio SIGTERM
      kill -15 $proceso
      echo "El proceso se ha detenido."
      exit
   else
      echo "El proceso no se encuentra corriendo."
   fi
}

count() {
   #Primero debo leer el nombre de la carpeta de backups
   if ! [[ -f "dest.tmp" ]]; then
      echo "Error, destino desconocido"
      echo "Finalizando..."
      stop 2>/dev/null
   fi

   #Obtengo el path de la carpeta de backups
   PATH_DEST=$(cat dest.tmp | head -n 1)

   #Cuento la cantidad
   cantidad=$(find "$PATH_DEST/" -maxdepth 1 -type f -perm -a+r -name "Backup*.tgz" | wc -l)

   #Hago el print
   echo "Archivos de backup en el directorio: " $cantidad
}

clear() {

   #Valido la cant de parametros
   if [[ $# -gt 2 ]]; then
      echo "Cantidad de parametros inválida"
      exit
   fi

   #Primero debo leer el nombre de la carpeta de backups
   if ! [[ -f "dest.tmp" ]]; then
      echo "Error, destino desconocido"
      echo "Finalizando..."
      stop 2>/dev/null
   fi

   #Obtengo el path de la carpeta de backups
   PATH_DEST=$(cat dest.tmp | head -n 1)

   cant=$(find "$PATH_DEST/" -maxdepth 1 -type f -perm -a+r -name "Backup*.tgz" | wc -l)

   if [ $# -eq 1 ]; then
      cant_mantiene=0
   else
      cant_mantiene=$2
   fi

   #inicializo el contador
   archivoEliminado=0

   if [ $cant_mantiene = 0 ]; then
      archivosTotales=$(find "$PATH_DEST/" -maxdepth 1 -perm -a+r -type f -name "Backup_*.tgz" | wc -l)
      rm -rf "$PATH_DEST/"{*,.*} 2>/dev/null #borra toda la carpeta
      archivoEliminado=$archivosTotales
   elif [ $cant_mantiene -ne 0 ]; then
      cantArchivosRemoves=$(($archivosTotales - $cant_mantiene))

      #Voy a sacar los N primeros
      archivosARemover=$(find "$PATH_DEST/" -maxdepth 1 -type f -perm -a+r -name "Backup_*.tgz" | sort | head -n $cantArchivosRemoves)

      for f in $archivosARemover; do
         #Elimino
         $(rm "$f")

         # Si elimino correctamente, incremento
         if [ $? -eq 0 ]; then
            archivoEliminado=$((archivoEliminado + 1))
         fi
      done
   fi
   #Print final
   echo $archivoEliminado" archivo(s) eliminado(s) correctamente"
}

play() {
   FECHA_Y_HORA=$(date "+%d-%m-%y_%H-%M-%S")
   NOMBRE_ARCHIVO="Backup_$FECHA_Y_HORA.tgz"

   #Obtengo el path de la carpeta de backups
   CARPETA_DESTINO=$(cat dest.tmp | awk 'NR == 1')
   CARPETA_BACKUP=$(cat dest.tmp | awk 'NR == 2')

   #Oculto los posibles notice por ejemplo por barras
   tar cfz "$CARPETA_DESTINO"/"$NOMBRE_ARCHIVO" "$CARPETA_BACKUP" 2>/dev/null

   echo "$NOMBRE_ARCHIVO"" ------------------ Creado con éxito"
}
