#!/bin/bash
# Acesta este scriptul initial pentru proiectul SHHConfigCheck!

echo
#Verificare numar de argumente:
if [ "$#" -ne 1 ]; then
	echo "ERROR: Please provide exactly one path to the configuration file." >&2
	exit 1
fi


#Preluare argument
file="$1"


#Verificare existenta fisier
echo "Verifying file existance: "
if [ ! -f "$file" ]; then
	echo "ERROR: No configuration file provided." >&2
	exit 1
else
	echo "File exists."
fi
echo


#Verificare permisiuni
echo "Verifying file permissions: "
if [ -x "$file" ]; then
	echo "All good, executable file."
else
	echo "ERROR: Unexecutable file." >&2
	exit 1
fi

if [ -r "$file" ]; then
	echo "All good, readable file."
else
	echo "ERROR: Unreadable file." >&2
	exit 1
fi

if [ -w "$file" ]; then
	echo "All good, writable file."
else
	echo "ERROR: Unwritable file." >&2
	exit 1
fi

perm=$(stat -c "%a" "$file")
others=${perm: -1}
if (( others & 4 )); then
	echo "Warning! Others can read the file." >&2
fi
if (( others & 2 )); then
	echo "Warning! Others can write to the file." >&2
fi
if (( others & 1 )); then
	echo "Warning! Others can execute the file." >&2
fi


#Eliminare linii vide
#1. linii complet goale
sed -i '/^$/d' "$file"

#2. linii care contin doar spatii sau tab-uri
sed -i -E '/^[[:space:]]+$/d' "$file"

#Ignorare comentarii
sed '/^[[:space:]]*#/d' "$file" > /dev/null



#Identificare optiuni suprascrise
echo
echo "Verifying overwritten options:"
#declaram un array asociativ pentru memorarea tuturor optiunilor din fisier
declare -A seen
crtLine=0
flag=0
while read -r line
do
	((crtLine++))
	key="${line%%:*}" # linia curenta, separata dupa : => cheia
	if [[ -n "${seen[$key]}" ]]; then
		echo
		echo "Warning! Option ${key} is overwritten on lines ${seen[$key]} and ${crtLine}" >&2
		flag=1
	else
		seen[$key]=$crtLine
	fi
done < "$file"
if (( flag == 0 )); then
	echo "No overwritten options found."
fi
