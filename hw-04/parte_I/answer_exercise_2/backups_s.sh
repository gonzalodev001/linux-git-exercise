#!/bin/bash

#Guaradamos en una variable el directorio
DIRE=/backup/gonzalo/$(date +'%Y')/$(date +'%B')/$(date +'%d')
#Preguntamos si el directorio existe
if [ -d "$DIRE" ]
then
        echo "Existe" 
else
#	si no existe se creara el directorio
        mkdir -p $DIRE

#	copiamos los logs de fichero txt a  otro fichero .log con la fecha de creación en el directorio creado DIRE
        less nginx_requests_total.txt >> $DIRE/nginx_log_requests_$(date +'%Y%m%d').log

#	Preguntamos si es domingo para crear el fichero comprimido .tar.gz
        if [ $(date +'%A') == 'domingo' ]
        then
#		Nos dirigimos al directorio donde se encuentra los logs del día 
                cd /backup/gonzalo/$(date +'%Y')/$(date +'%B')/$(date +'%d')

#		En una variable guardamos el directorio donde se guardara un fichero comprimido con los logs
		DIREC=/backup/gonzalo/$(date +'%Y')/$(date +'%B')

#		Empaquetamos el fichero log del día domingo
                tar -cvf $DIREC/nginx_logs_$(date +'%Y%m%d').tar nginx_log_requests_$(date +'%Y%m%d').log

#		En un ciclo for contará los días de la semana para retroceder a partir del día domingo
                for (( i=1; i<7; i++))
                do
#			En una variable auxiliar guardamos un directorio con el día anterior al domingo hasta llegar a restar los seis días anterios al domingo para 			     verificar si existen.
                        AUX=/backup/gonzalo/$(date +'%Y')/$(date +'%B')/$(date +'%e' -d "-$i day")

#			Preguntamos si existe ese directorio 
                        if [ -d "$AUX" ]
                        then
#				Si existe entonces empaquetamos el fichero log en el paquete donde se encuentra el del día domingo
                                tar -rvf /backup/gonzalo/$(date +'%Y')/$(date +'%B')/nginx_logs_$(date +'%Y%m%d').tar nginx_log_requests_$(date +'%Y%m%d' -d "-$i day").log

                        fi
                done
#		Una vez empaquetados los ficheros log de los días anteriores existente al domingo, nos ubicamos en el directorio donde esta el fichero empaquetado
                cd $DIREC
#		Al final comprimimos en un zip el fichero empaquetado.
                gzip nginx_logs_$(date +'%Y%m%d').tar

        fi
        echo "Fue creado los directorios $(date +'%A')"
fi
