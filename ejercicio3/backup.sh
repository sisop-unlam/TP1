#!/bin/bash

#***********************************************************************************
# Nombre Del Script:        backup.sh
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

source backupDaemon.sh #esto es para tomar este archivo como fuente al otro backupDemon.sh

get_help() {

   echo 'La funcionalidad del script es crear un backup de un directorio cada un intervalo de tiempo en segundos.'
   echo 'Comandos: -start -stop -count -clear -play -help'
   echo '-start: Inicia la ejecucion, debe pasar por parametro el directorio a salvar, a guardar y el intervalo de tiempo entre backups en seguundos'
   echo '-stop: Finaliza el proceso'
   echo '-count: Indica la cantidad de backups que hay en el directorio ,se debe pasar la ruta completa'
   echo '-clear: Limpia el directorio de backups, recibe por parametro la cantidad de backups que se mantienen en la carpeta'
   echo '-play: Crea el backup en ese instante'
   exit
}

if [[ $# -eq 0 ]]; then
   echo "Ingrése un parámetro"
   echo "Para más información, ingrese $0 -help"
   exit
fi

if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
   get_help
   exit 1
fi

if [[ $1 != "-start" && $1 != "-stop" && $1 != "-play" && $1 != "-count" && $1 != "-clear" ]]; then
   echo "Ingrese un parámetro válido"
   echo "Para más información, ingrese $0 -help"
   exit
fi

if [[ $1 == "-start" ]]; then

   proceso=$(ps aux | grep "[b]ackup.sh" | awk '{print $2;exit}')

   #En primer lugar, valido que ya no este corriendo
   if [[ $proceso == $$ ]]; then

      #Primero, hago todas las validaciones correspondientes
      if [ $# -ne 4 ]; then
         echo "Sintaxis de ejecución parametro start:"
         echo "    ./backup.sh -start <directorio-origen> <directorio-backup> <intervalo-segundos>"
         exit
      elif ! [ -d "$2" ]; then
         echo "Ingrese un directorio a salvar válido"
         exit
      elif ! [[ $4 =~ ^[0-9]+$ ]]; then
         echo "Ingrese una cantidad de segundos válida"
         exit
      fi

      #Luego de pasar por las validaciones, puedo iniciar el proceso
      start "$@"
   else
      echo "El proceso ya se encuentra corriendo con el PID $proceso."
      exit
   fi

fi

if [[ $1 == "-stop" ]]; then
   if [ $# -gt 1 ]; then
      echo "Parametros inválidos"
      exit
   fi

   proceso=$(ps aux | grep "[b]ackup.sh" | awk '{print $2;exit}')

   if [[ $proceso == $$ ]]; then
      echo "El proceso no se encuentra corriendo."
   else
      stop
   fi

   exit
fi

if [[ $1 == '-count' ]]; then
   if [ $# -gt 1 ]; then
      echo "Parametros inválidos"
      exit
   fi

   count
   exit 1
fi

if [[ $1 == '-clear' ]]; then
   clear "$@"
   exit 1
fi

if [[ $1 == '-play' ]]; then
   if [ $# -gt 1 ]; then
      echo "Parametros inválidos"
      exit
   fi
   proceso=$(ps aux | grep "[b]ackup.sh" | awk '{print $2;exit}')

   if [[ $proceso == $$ ]]; then
      echo "El proceso no se encuentra corriendo."
   else
      play
   fi
   exit 1
fi
