# !/bin/bash
#***********************************************************************************
# Nombre Del Script:        ejercicio1.sh
# Trabajo Practico Nro.:    1
# Ejercicio Nro.:           1
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

ErrorS() {
    echo "Error. La sintaxis del script es la siguiente:"
    echo "Cantidad de lineas: $0 nombre_archivo L"
    echo "Cantidad de caracteres: $0 nombre_archivo C"
    echo "Mayor longitud de linea: $0 nombre_archivo M"
}
ErrorP() {
    echo "Error. nombre_archivo no existe o no tiene permisos de lectura"
}

#En caso de tener menos de dos parametros, muestra el mensaje de error
if test $# -lt 2; then
    ErrorS
fi

#Verifica si el archivo ingresado existe y tiene permisos de lectura,
#caso contrario muestra un mensaje aclaratorio
if !(test -r $1); then
    ErrorP
#Ahora, verifica que se trate de un archivo (y no una carpeta) y que además,
#el segundo parametro sea L, C o M
elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
    #Según cada caso, ejecutara el comando correspondiente
    if test $2 = "L"; then
        res=$(wc -l $1)
        echo "Cantidad de lineas: $res"
    elif test $2 = "C"; then
        res=$(wc -m $1)
        echo "Cantidad de caracteres: $res"
    elif test $2 = "M"; then
        res=$(wc -L $1)
        echo "Mayor longitud de linea: $res"
    fi
else
    #En caso de que no se trate de un archivo, o que el parametro ingresado no fue
    #L, C o M, se llama a ErrorS, el cual mostrara una ayuda
    ErrorS
fi

#
# a) El objetivo del script es obtener (según el parametro ingresado) la cantidad de lineas
#    la cantidad de caracteres o la mayor longitud de linea de un archivo, también ingresado
#    por parametro.
#
# b) El primer parametro del script sera el nombre del archivo. Por otro lado, el segundo parametro
#    indicara el modo en el que se analizará el mismo
#
# e) La variable "$#" indica la cantidad de parametros ingresados. Por ejemplo, si ingreso
#    ./ej.sh param1 param2, $# retornará dos.
#    Otras variables similares a "$#" son:
#       1) "$*": Contiene todos los parametros (excepto $0, el cual es el nombre del ejecutable)
#                en forma de un único string.
#       2) "$@": Al igual que en el caso anterior, contiene todos los parametros excepto el del
#                nombre del ejecutable, pero se diferencia en que devuelve los mismos en un array.
#       3) "$$": PID del proceso.
#       4) "$?": Estado del ultimo comando ejecutado. En caso correcto, sera 0, de lo contrario, 1.
#       5) "$!": Numero de proceso del ultimo comando que esta en segundo plano.
#
# f) Comillas simples (''): El contenido se interpreta de forma literal (Por ejemplo, si tendríamos
#    un echo '$USER', en vez de mostrar el nombre, simplemente imprimiría "$USER")
#
#    Comillas dobles (""): En este caso, se interpretan las referencias a las variables, mostrando
#    el contenido de las mismas.
#
#    Comillas invertidas (``): Permite ejecutar un comando y posibilita la asignacion de su  output a una variable.
#
