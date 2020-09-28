#!/bin/bash
 . /home/oracle/.bash_profile                                                #Carga variables de Entorno del Perfil y usuario Oracle
MAQUINA=`hostname`                                                          #Seteo Variable Nombre de Maquina
LOG=/home/oracle/                                                           #Carpeta donde alojar logs
HORA=`date +%H%M_%d%m%Y`                                                    #Sintaxys Hora
FECHA=`date +%d%m%Y`                                                        #Sintaxys Fecha
CORREO=marco.escobar@veeam.com
Append=1
#Comienzo Script
for ORACLE_SID in $($ORACLE_HOME/bin/srvctl config database)   #Loop para extraer nombre de SID en archivo
do
export ORACLE_SID=$ORACLE_SID$Append
LOGFILE=${LOG}/${ORACLE_SID}_${FECHA}_${HORA}.log                           #Construye Nombre de Arhivo Log
exec >> ${LOGFILE} 2>&1                                                     #Escribe Log
#Ejecucion RMAN, aqui puede ir el script de RMAN del Cliente
${ORACLE_HOME}/bin/rman <<EOF
connect target /
run {
backup spfile;
backup current controlfile;
backup database plus archivelog;
}
LIST BACKUP SUMMARY;
EOF
echo  Base de Datos: "${ORACLE_SID}" >> ${LOG}/mail         #Escribe el SID en log mail para envia el nombre
cat ${LOGFILE} >> ${LOG}/mail                               #Lee el Archivo log y lo inserta al mail
done                                                        # Fin del Loop
grep RMAN-06273 ${LOG}/mail >>/dev/null                     #Busca error RMAN en caso de falla.
if [ $? -eq 0 ]                                             # Si es distinto a 0 pasa a la sigueinte instruccion si es igual a 0 envia correo con alerta
then
ASUNTO='ALERTA!: Respaldo de '${MAQUINA}' ha fallado'       #Configuracion Asunto Alerta 1
else
grep -i error ${LOGFILE} >>/dev/null                        #Busca la palabra error
if [ $? -eq 0 ]                                             #Si es distinto a 0 pasa a la sigueinte instruccion si es igual a 0 envia correo con alerta
then
ASUNTO='ALERTA!: Respaldo de '${MAQUINA}' ha fallado'       #Configuracion Asunto Alerta 2
else
ASUNTO='Respaldo '${MAQUINA}' Correcto'                     #Sitodo esta OK, enviara correo con Asunto correcto.
fi
fi
## Mail ##
cat ${LOG}/mail | /usr/bin/mailx -s "${ASUNTO}" "${CORREO}"     #Lee el archivo Mail para enviarlo como cuerpo del correo.
rm -rf ${LOG}/mail                                              #elimino log utilizado
echo $exit 0
