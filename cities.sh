#!/bin/bash

selected_country="XX"
CADENA='(("\w+(+\w+)+")|\w+)'
country_code="XX"
country_name="XX"
state_code="XX"
state_name="XX"

while true; do

echo "Tria una opció de les següents: q, lp, sc, se, le, lcp, ecp, lce, ece, gwd, est"

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
           if [ -n "$input_country_name" ]; then
             new_country_code=$(awk -F, -v country_name="$input_country_name" '$8 == country_name {print $7}' cities.csv | uniq)
             if [ -z "$new_country_code" ]; then
               echo "El país no existeix o no es troba."
               country_code="XX"
               country_name="XX"
             else
               country_name="$input_country_name"
               country_code="$new_country_code"
               echo "País seleccionat: $country_name"
               echo "Codi: $country_code"
             fi
           else
             echo "País seleccionat: $country_name"
             echo "Codi: $country_code"
           fi
           ;;

        se)
            if [ "$country_code" != "XX" ]; then
                 read -p "Introdueix el nom de l'estat: " input_state_name
                 if [ -n "$input_state_name" ]; then
                         new_state_code=$(awk -F, -v state_name="$input_state_name" -v country="$country_code" \
                '$7 == country && ($5 == state_name || $5 ~ "\""state_name"\"") {print $4}' cities.csv | uniq)
                         if [ -z "$new_state_code" ]; then
                                echo "L'estat no existeix o no pertany al país seleccionat."
                                state_code="XX"
                                state_name="XX"
                         else
                                state_name="$input_state_name"
                                state_code="$new_state_code"
                                echo "Estat seleccionat: $input_state_name"
                                echo "Codi: $state_code"
                         fi
                else
                        echo "Estat seleccionat: $state_name"
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

	gwd)
           if [ "$country_code" != "XX" ] && [ "$state_code" != "XX" ]; then
                read -p "Introdueix el nom de la població: " input_city_name
                city_wikidata_id=$(awk -F, -v country="$country_code" -v state="$state_code" -v city="$input_city_name" \
                '$7 == country && $4 == state && ($2 == city || $2 ~ "\""city"\"") {print $11}' cities.csv | uniq)

                if [ -z "$city_wikidata_id" ]; then
                        echo "La població no existeix o no pertany a l'estat i país seleccionats."
                else
                        echo "Obtenint dades de la WikiData per la població $input_city_name (wikidataId: $city_wikidata_id)..."
                        wget -O "${city_wikidata_id}.json" "https://www.wikidata.org/wiki/Special:EntityData/${city_wikidata_id}.json"
                        echo "Dades emmagatzemades en ${city_wikidata_id}.json."
                fi

           else
                echo "Primer has de seleccionar un país i un estat (utilitza l'ordre sc i se)."
           fi

           ;;

        est)
          awk -F ',' 'BEGIN{num_north=0; num_south=0; num_east=0; num_west=0; num_no_ubic=0; num_no_wikidata_id=0} \
                {if (NR>0) {
                        num_north+=($9 > 0.0);
                        num_south+=($9<0.0);
                        num_east+=($10<0.0)
                        num_west+=($10<0.0);
                        num_no_ubic+=($9 == 0.0) && ($10 == 0.0);
                        num_no_wikidata_id+=($11 == "")
                }}
                END {print "Nord " num_north " Sud " num_south " Est "num_east " Oest "num_west " No ubic "num_no_location " No WDId "num_no_wikidata_id }' cities.csv
         ;;

        *)
           echo "Comanda no reconeguda: $comanda"
           ;;
	esac
done
