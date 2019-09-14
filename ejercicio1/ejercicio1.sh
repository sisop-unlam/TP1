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
    echo "......................: $0 nombre_archivo L" # COMPLETAR
    echo "......................: $0 nombre_archivo C" # COMPLETAR
    echo "......................: $0 nombre_archivo M" # COMPLETAR
}
ErrorP() {
    echo "Error. nombre_archivo ....................." # COMPLETAR
}
if test $# -lt 2; then
    ErrorS
fi

if !test $1 -r; then
    ErrorP
elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
    if test $2 = "L"; then
        res=$(wc –l $1)
        echo ".................................: $res" # COMPLETAR
    elif test $2 = "C"; then
        res=$(wc –m $1)
        echo ".................................: $res" # COMPLETAR
    elif test $2 = "M"; then
        res=$(wc –L $1)
        echo ".................................: $res" # COMPLETAR
    fi
else
    ErrorS
fi
