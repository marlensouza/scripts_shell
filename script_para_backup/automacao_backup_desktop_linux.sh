#!/bin/bash

#
# Autor......: Marlen Souza
# nome.......: automacao_backup_desktop_linux.sh
# versão.....: 2.0
# descrição..: Facilitar o processo de backup de arquivos
#

CONFIG_FILE="automacao_backup_desktop_linux.conf"

if [[ -f "$CONFIG_FILE" ]] 
then
  linhas=$( egrep "^[^#]" "$CONFIG_FILE" | wc -l | cut -d" " -f 1 )
  if [[ "$linhas" -lt "1" ]]
  then
    echo \
    "
    Não foi encontrado no arquivo list_backup.conf, lista de 
    diretório para backup.
    "
    exit 1
  fi
else
  echo \
'# O caminho por extenso do diretório que será "backupeado"
# deve ser posto abaixo para que o backup seja realizado.
# Exemplo:
# /home/seunomedeusuario/Documentos
# 
' >> "$CONFIG_FILE"
  
  echo \
  "
  Arquivo de configuração list_backup.conf, foi criado!

  Adicionar o caminho completo do diretório que será 
  feito o backup no arquivo list_backup.conf.  
  "
  exit 1
fi

while read LISTA 
do 
  if (echo "$LISTA"|egrep "(^#|^$)")
  then
    continue
  else
    if rsync --log-file=.rsync_error.log --append-verify --progress -azP "$LISTA" .
    then 
      echo -e "\n\e[32mSUCESSO!\e[0m\n" 
    else
      echo -e "\n\e[31mERROR: Verifique o erro e tente novamente para que o próximo\nitem da lista, caso haja, possa ser executado.\e[0m\n"
      egrep "\][[:blank:]]*rsync" .rsync_error.log
      rm .rsync_error.log
      exit 2
    fi
  fi
done < "$CONFIG_FILE"
