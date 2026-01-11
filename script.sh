#!/bin/bash
# Acesta este scriptul final al proiectului SSHConfigCheck!

echo
#Verificare numar de argumente:
if [ "$#" -ne 1 ]; then
	echo "ERROR: Please provide exactly one path to the configuration file." >&2
	exit 1
fi


#Preluare argument
rawfile="$1"


#Verificare existenta fisier
echo "Verifying file existance: "
if [ ! -f "$rawfile" ]; then
	echo "ERROR: No configuration file provided." >&2
	exit 1
else
	echo "File exists."
fi
echo


#Verificare permisiuni
echo "Verifying file permissions: "
if [ -r "$rawfile" ]; then
	echo "All good, readable file."
else
	echo "ERROR: Unreadable file." >&2
	exit 1
fi

if [ -w "$rawfile" ]; then
	echo "All good, writable file."
else
	echo "Warning: Unwritable file."
fi

perm=$(stat -c "%a" "$rawfile")
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
sed -i '/^$/d' "$rawfile"

#2. linii care contin doar spatii sau tab-uri
sed -i -E '/^[[:space:]]+$/d' "$rawfile"

#Ignorare comentarii
file=$(mktemp)
sed '/^[[:space:]]*#/d' "$rawfile" > "$file"


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
		echo "Warning! Option ${key} is overwritten on lines ${seen[$key]} and ${crtLine}" >&2
		flag=1
	else
		seen[$key]=$crtLine
	fi
done < "$file"
if (( flag == 0 )); then
	echo "No overwritten options found."
fi

echo
echo "Options available:"
cat "$file"
#Verificare optiuni de securitate

echo
echo
#1.Port (de preferat sa nu fie cel default adica 22)

#cautam ultima linie care incepe cu Port
linie_port=$(grep "^Port" "$file" | tail -n 1)

#daca aceasta exista, preluam valoarea si o verificam
if [ -n "$linie_port" ]; then
	port=$(echo "$linie_port" | awk '{print $2}')

	if [ -z "$port" ]; then
		echo -e "[WARNING] Port is not set. Default value '22' is being used.\n Recommended: change it to a custom port." >&2
	elif [ "$port" == "22" ]; then
		echo -e "[WARNING] Port is default.\n Recommended: change it to a custom port." >&2
	else
		echo "[OK] A custom port is being used."
	fi
fi

echo



 
#2.PermitRootLogin (cel mai bine no sau prin chei ssh)

#cautam ultima linie care incepe cu PermitRootLogin
linie_root_login=$(grep "^PermitRootLogin" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_root_login" ]; then
	root_login=$(echo "$linie_root_login" | awk '{print $2}')

	if [ -z "$root_login" ]; then
        	echo -e "[WARNING] PermitRootLogin is not set! Default value is being used.\n Recommended: set PermitRootLogin to 'no'."  >&2
	elif [ "$root_login" == "no" ]; then
		echo "[OK] PermitRootLogin is set to 'no'."
	elif [ "$root_login" == "yes" ]; then
       		echo -e "[ALERT] PermitRootLogin is set to 'yes'! Compromised security!\n Critical: set PermitRootLogin to 'no'."  >&2
	else
		echo "[OK] PermitRootLogin only with ssh keys."
	fi
fi

echo




#3.PasswordAuthentication (trebuie sa fie no)

#cautam ultima linie care incepe cu PasswordAuthentication
linie_pass_auth=$(grep "^PasswordAuthentication" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_pass_auth" ]; then
	pass_auth=$(echo "$linie_pass_auth" | awk '{print $2}')

	if [ -z "$pass_auth" ]; then
        	echo "[ALERT] PasswordAuthentication is not set! Default value 'yes' is being used." >&2
		echo "Critical: set PasswordAuthentication to 'no'." >&2
	elif [ "$pass_auth" == "no" ]; then
        	echo  "[OK] PasswordAuthentication is set to 'no'."
	else
        	echo -e "[ALERT] PasswordAuthentication is set to 'yes'! Compromised security! \nCritical: set PasswordAuthentication to 'no'." >&2
	fi
fi

echo



#4.PermitEmptyPasswords (trebuie sa fie no)

#cautam ultima linie care incepe cu PermitEmptyPasswords
linie_empty_pass=$(grep "^PermitEmptyPasswords" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_empty_pass" ]; then
	empty_pass=$(echo "$linie_empty_pass" | awk '{print $2}')

	if [ -z "$empty_pass" ]; then
		echo -e "[WARNING] PermitEmptyPasswords is not set.\nRecommended: set PermitEmptyPasswords to 'no'." >&2
	elif [ "$empty_pass" == "no" ]; then
		echo "[OK] PermitEmptyPasswords is set to 'no'."
	else 
		echo -e "[ALERT] PermitEmptyPasswords is set to 'yes'! Compromised security!\nCritical: set PermitEmptyPasswords to 'no'." >&2
	fi
fi

echo



#5.MaxAuthTries (ideal <=4)

#cautam ultima linie care incepe cu MaxAuthTries
linie_max_tries=$(grep  "^MaxAuthTries" "$file" | tail -n 1)

#daca aceasta exista, ii verificam valoarea
if [ -n "$linie_max_tries" ]; then
	max_tries=$(echo "$linie_max_tries" | awk '{print $2}')

	if [ -z "$max_tries" ]; then
		echo -e  "[WARNING] MaxAuthTries is not set. Default is 6. \n Recommended: set MaxAuthTries to no more than 4." >&2
	elif [ "$max_tries" -le 4 ]; then
		echo "[OK] MaxAuthTries is ideal."
	elif [ "$max_tries" -le 6 ]; then
		echo -e "[WARNING] MaxAuthTries is high.\nRecommended: set MaxAuthTries to no more than 4." >&2
	else
		echo -e "[ALERT]  MaxAuthTries is way too high. Compromised security!\nCritical: set MaxAuthTries to no more than 4." >&2
	fi
fi
