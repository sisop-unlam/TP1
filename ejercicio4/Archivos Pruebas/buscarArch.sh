 #!/bin/bash

 buscarArchivosTxt(){
 	DirectorioPara=$1
	res=$(find  $DirectorioPara -type f -name "* *" -and -name "*.txt")
	//123123
	//prueba slash
	/**/
	
	echo  " $res "
}

buscarArchivosTxt /SistemaOperativo/TP1/