
#1.Port (de preferat sa nu fie cel default adica 22)

#cautam ultima linie care incepe cu Port
linie_port=$(grep "^Port" "$file" | tail -n 1)

#daca aceasta exista, preluam valoarea si o verificam
if [ -n "$linie_port" ]; then
	echo "Port"
	port=$(echo "$linie_port" | awk '{print $2}')

	if [ -z "$port" ]; then
		echo -e "[WARNING] Portul nu este setat. Se foloseste valoarea default '22'.\n Recomandat: schimbati pe un port custom" 
	elif [ "$port" == "22" ]; then
		echo -e "[WARNING]  Este setat un port default.\nRecomandat: schimbati pe un port custom"
	else
		echo -e "[OK] Este setat un port custom"
	fi
fi

echo
 
#2.PermitRootLogin (cel mai bine no sau prin chei ssh)

#cautam ultima linie care incepe cu PermitRootLogin
linie_root_login=$(grep "^PermitRootLogin" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_root_login" ]; then
	echo "PermitRootLogin"
	root_login=$(echo "$linie_root_login" | awk '{print $2}')

	if [ -z "$root_login" ]; then
        	echo -e "[WARNING] Accesul prin root  nu este setat! Se foloseste valoarea default.\nRecomandat: setati accesul prin root la 'no'" 
	elif [ "$root_login" == "no" ]; then
		echo "[OK] Accesul prin root este dezactivat"
	elif [ "$root_login" == "yes" ]; then
       		echo -e "[ALERT] Accesul prin root este permis! Securitate slaba!\nUrgent: dezactivati accesul prin root" 
	else
		echo -e "[OK] Accesul prin root permis doar prin chei ssh"
	fi
fi

echo

#3.PasswordAuthentication (trebuie sa fie no)

#cautam ultima linie care incepe cu PasswordAuthentication
linie_pass_auth=$(grep "^PasswordAuthentication" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_pass_auth" ]; then
	echo "PasswordAuthentication"
	pass_auth=$(echo "$linie_pass_auth" | awk '{print $2}')

	if [ -z "$pass_auth" ]; then
        	echo "[ALERT] Autentificarea prin parola nu este setata! Se foloseste valoarea default = 'yes'.\nUrgent: setati autentificarea prin parola la 'no'"
	elif [ "$pass_auth" == "no" ]; then
        	echo  "[OK] Autentificarea prin parola este dezactivata"
	else
        	echo -e "[ALERT] Autentificarea prin parola este permisa! Securitate slaba!\nUrgent: dezactivati autentificarea prin parola"
	fi
fi

echo

#4.PermitEmptyPasswords (trebuie sa fie no)

#cautam ultima linie care incepe cu PermitEmptyPasswords
linie_empty_pass=$(grep "^PermitEmptyPasswords" "$file" | tail -n 1)

#daca aceasta exista, ii verificam starea
if [ -n "$linie_empty_pass" ]; then
	echo "PermitEmptyPasswords"
	empty_pass=$(echo "$linie_empty_pass" | awk '{print $2}')

	if [ -z "$empty_pass" ]; then
		echo -e "[WARNING] Folosirea parolelor goale nu este setata.\nRecomandat: setati folosirea parolelor goale la 'no'"
	elif [ "$empty_pass" == "no" ]; then
		echo "[OK] Parolele goale nu sunt permise."
	else 
		echo -e "[ALERT] Parolele goale sunt permise! Securitate slaba!\nUrgent: dezactivati folosirea parolelor goale"
	fi
fi

echo

#5.MaxAuthTries (ideal <=4)

#cautam ultima linie care incepe cu MaxAuthTries
linie_max_tries=$(grep  "^MaxAuthTries" "$file" | tail -n 1)

#daca aceasta exista, ii verificam valoarea
if [ -n "$linie_max_tries" ]; then
	echo "MaxAuthTries"
	max_tries=$(echo "$linie_max_tries" | awk '{print $2}')

	if [ -z "$max_tries" ]; then
		echo -e  "[WARNING] Numarul de incercari pentru autentificare nu este specificat. Default = 6\nRecomandat: setati numarul de incercari la cel mult 4"
	elif [ "$max_tries" -le 4 ]; then
		echo "[OK] Numarul de incercari pentru autentificare este ideal"
	elif [ "$max_tries" -le 6 ]; then
		echo -e "[WARNING] Numarul de incercari pentru autentificare este ridicat.\nRecomandat: setati numarul de incercari la cel mult 4"
	else
		echo -e "[ALERT] NUmarul de incercari pentru autentificare este mult prea mare! Securitate slaba!\nUrgent: setati numarul de incercari la cel mult 4"
	fi
fi
