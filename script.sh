#!/bin/bash
# Acesta este scriptul initial pentru proiectul SHHConfigCheck!

#Verificare numar de argumente:
if [ "$#" -ne 1 ]; then
	echo "ERROR: Please provide exactly one path to the configuration file."
	exit 1
fi

#Preluare argument
file="$1"

#Verificare existenta fisier
if [ ! -f "$file" ]; then
	echo "ERROR: No configuration file provided."
	exit 1
fi
