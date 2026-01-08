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
echo "Verifying file existance: "
if [ ! -f "$file" ]; then
	echo "ERROR: No configuration file provided."
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
	echo "Warning! Unexecutable file."
	exit 1
fi

if [ -r "$file" ]; then
	echo "All good, readable file."
else
	echo "Warning! Unreadable file."
	exit 1
fi

if [ -w "$file" ]; then
	echo "All good, writable file."
else
	echo "Warning! Unwritable file."
fi
echo

perm=$(stat -c "%a" "$file")
others=${perm: -1}
if (( others & 4 )); then
	echo "Warning! Others can read the file."
	exit 1
fi
if (( others & 2 )); then
	echo "Warning! Others can write to the file."
	exit 1
fi
if (( others & 1 )); then
	echo "Warning! Others can execute the file."
	exit 1
fi
