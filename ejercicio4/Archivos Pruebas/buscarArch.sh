 #!/bin/bash

 buscarArchivosTxt(){
 	DirectorioPara=$1
	res=$(find  $DirectorioPara -type f -name "* *" -and -name "*.txt")//ni idea
	//123123
	//asdasdasd
	/**/
	
	echo  " $res "
}

buscarArchivosTxt /SistemaOperativo/TP1/