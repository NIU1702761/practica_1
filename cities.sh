#!/bin/bash
selected_country="XX"
CADENA='(("\w+(+\w+)+")|\w+)'
country_code="XX"
state_code="XX"
while true; do
read -p "Introdueix una comanda: " comanda
  case $comanda in
        q)
           echo "Sortint de l'aplicació"
           exit 0
           ;;
        lp)
           cut -d ',' -f 7,8 cities.csv |uniq|head -5
           exit 0
           ;;
        sc)
           read -p "Introdueix el nom del país: " input_country_name
           country_code=$(awk -F, -v country_name="$input_country_name" '$8 == country_name {print $7}' cities.csv |uniq)
           if [ -z "$country_code" ]; then
                echo "El país no existeix o no es troba."
                country_code="XX"
           else
                echo "País seleccionat: $input_country_name"
                echo "Codi: $country_code"
           fi
           ;;
        se)
            if [ "$country_code" != "XX" ]; then
                 read -p "Introdueix el nom de l'estat: " input_state_name
                state_code=$(awk -F, -v state_name="$input_state_name" -v country="$country_code" \
                '$7 == country && ($5 == state_name || $5 ~ "\""state_name"\"") {print $4}' cities.csv | uniq)
                if [ -z "$state_code" ]; then
                        echo "L'estat no existeix o no pertany al país seleccionat."
                        state_code="XX"
                else
                        echo "Estat seleccionat: $input_state_name"
                        echo "Codi: $state_code"
                fi
           else
                echo "Primer has de seleccionar un país (utilitza l'ordre sc)."
           fi
           ;;
	le)
           if [ "$country_code" != "XX" ]; then
                echo "Els estats del país seleccionat ($country_code) són:"
                awk -F, -v country="$country_code" '$7 == country {print $4, $5}' cities.csv | uniq
           else
                echo "Primer has de seleccionar un país (utilitza l'ordre sc)."
           fi
           exit 0
           ;;

        lcp)
           if [ "$country_code" != "XX" ]; then
                echo "Les poblacions del país seleccionat ($country_code) són:"
                awk -F, -v country="$country_code" '$7 == country {print $2, $11}' cities.csv | uniq
           else
                 echo "Primer has de seleccionar un país (utilitza l'ordre sc)."
           fi
           exit 0
           ;;
        ecp)
           if [ "$country_code" != "XX" ]; then
                echo "Extreient les poblacions del país seleccionat ($country_code)..."
                awk -F, -v country="$country_code" '{if ($7 == country) print $2 "," $11}' cities.csv | uniq > "${country_code}.csv"
                echo "Poblacions extretes i guardades en ${country_code}.csv."
           else
                echo "Primer has de seleccionar un país (utilitza l'ordre sc)."
           fi
           exit 0
           ;;
	lce)
	   if [ "$country_code" != "XX" ] || ["$state_code" != "XX" ]; then
		echo "Llistant les poblacions de l'estat seleccionat ($state_code) del país ($country_code)..."
		awk -F, -v country="$country_code" -v state="$state_code" '$7 == country && $4 == state {print $2, $11}' cities.csv

	   else
		echo "El teu país seleccionat és: $country_code i l'estat és: $state_code"
		echo "Selecciona un país o un estat del país (utiltiza les ordres sc o se)."
	   fi
	   exit 0
	   ;;
	ece)
           if [ "$country_code" != "XX" ] && [ "state_code" != "XX"]; then
                echo "Extreient les poblacions del país l'estat seleccionat $state_code..."
                awk -F, -v country="$country_code" -v state="$state_code" '{if ($7 == country && $4 == state) print $2 "," $11}' cities.csv | uniq > "${state_code}.csv"
                echo "Poblacions extretes i guardades en ${country_code}_${state_code}.csv."
           else
                echo "Primer has de seleccionar un país i un estat (utilitza les ordres sc i se)."
           fi
           exit 0
           ;;
	#gwd)
	 #  if [ "$country_code" != "XX"] && [ "state_code" != "XX"]; then
	#	read -p "Introdueix el nom d'una població del país: $country_code i de l'estat: $state_code: " input_coutry_name
	#	wikidata=$(awk -F, -v country_name="$input_country_name" '$8 == country_name {print $11}' cities.csv)
	#	awk -F, -v country="$country_code" -v state="$state_code" -v name="$country_name"'{if ($7 == country && $4 == state && $2 == name) wikidata="$11" } cities.csv
		echo "Dades de ${country_name} extretes i guardades a ${wikidata}.json."  
	 #   else
          #      echo "Primer has de seleccionar un país i un estat (utilitza les ordres sc i se)."
         #  fi
          # exit 0
           #;;
	est)
       	   nord=$(awk -F',' '$9>0' cities.csv | wc -l)
           sud=$(awk -F',' '$9<0' cities.csv | wc -l)
           est=$(awk -F',' '$10>0' cities.csv | wc -l)
           oest=$(awk -F',' '$10<0' cities.csv | wc -l)
           noubic=$(awk -F',' '$9 == "" && $10 == ""' cities.csv | wc -l)
	   nowdid=$(awk -F',' '$11 == ""' cities.csv | wc -l)
	   echo "Nord $nord Sud $sud Est $est Oest $oest No ubic $noubic No WDId $nowdid"
	   exit 0
	   ;;
        *)
           echo "Comanda no reconeguda: $comanda"
           ;;
	esac
done
