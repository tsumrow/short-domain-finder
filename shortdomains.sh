#!/bin/bash
if [[ $5 == true ]]; then
whoisdatadir="whoisdata"
mkdir -p $whoisdatadir
fi

trap ctrl_c INT

function ctrl_c() {
        echo -e "\e[91m---> Terminating ...\e[0m"
        exit
}

#LOOK FOR WHOIS COMMAND
if ! whois_loc="$(type -p "whois")" || [ -z "$whois_loc" ]; then
  echo "\e[31m---> Whois is missing, trying to install it with APT.
  \e[31m---> You need sudo and APT.\e[0m"
  sudo apt-get install whois
fi

if [ -n "$1" ] ; then
	# .si domain: slovenia cctld, arnes registry, 100 queries per hour or ban
	# .no domain: norwegian, uninett norid registry, 3000 queries per day wait till midnight
	# .de domain: germany, no data of registry, 1000 queries per day or ban
	# .it domain: italy, no data of registry, no data of requests per time amount
	oneltr=(0 0 1 0 0 1 1 0 1 0 0 1 1 1 0 0 0 0 0 1 1 1 0 1 1 0 1)
	tlds=(si no de it ru co uk me us ca pw fr cc cn be nl tn eu su cz dk ro lt at se hu nu)
	availables=('No entries found' 'No whois information found' 'Status: free' 'Status:             AVAILABLE' 'No entries found for the selected source' 'No Data Found' 'No whois information found.' 'NOT FOUND' 'No Data Found' 'Not found' 'DOMAIN NOT FOUND' 'No entries found' 'No whois information found.' 'No whois information found.' 'Status: AVAILABLE' '.nl is free' 'NO OBJECT FOUND!' 'Status: AVAILABLE' 'No entries found for the selected source(s).' '%ERROR:101: no entries found' 'Not found:' 'No entries found for the selected source(s).' 'available' 'nothing found' ' not found.' 'No match' 'not found')
	denieds=('Query denied' 'limit exceeded' '55000000002' 'denied', 'You have exceeded allowed connection rate' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'denied' 'You have exceeded allowed connection rate' 'denied' 'denied' 'denied' 'denied' 'Quota exceeded' 'denied' 'denied' 'denied') # ne vem za: it co me us ca pw fr cc cn be nl tn eu cz dk ro lt se hu nu
	sleeps=(36 29 87 87 2 87 87 87 87 87 60 87 87 87 87 173 173 1 2 173 87 173 1 87 1 87 1) # idk about: me it uk us ca fr cc cn be tn cz dk at hu
	# add your domains, you get the point
	spanje=${sleeps[0]} # max sleep of sleeps will be the sleep (-;
if [[ $1 == 'all' ]]; then
        for n in "${sleeps[@]}" ; do
	        ((n > spanje)) && spanje=$n
        done
	# everything is already set!
else

                for i in "${!tlds[@]}"; do
                        if [[ "${tlds[$i]}" = "$1" ]]; then
                                index=$i;
                        fi
                done



     if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
	if [ -z $index ] ; then
		echo -e "\e[91m$---> Terminating: no whois response values stored for this domain. Input them as arguments.\e[0m"
              	exit
	fi
     fi
	if [ ${#2} -ge 1 ] ; then
		availables=$2
	else
		availables=${availables[$index]}
		echo $availables
	fi

	if [ ${#3} -ge 1 ] ; then
		denieds=$3
	else
		denieds=${denieds[${index}]}
	fi

	if [ ${#4} -ge 1 ] ; then
		spanje=$4
	else
		spanje=${sleeps[$index]}
	fi
	tlds=($1)
fi

  ok=true
  if [ -n "$7" ] ; then
    list=`cat $7`
  else
		if [[ $8 == true ]]; then
	    list=`echo {{a..z},{0..9}}`
			newtlds=()
			tldcount=${#tlds[@]}
			for (( iter=0; iter<$tldcount; iter++));
			do
				if [[ ${oneltr[iter]} == 1 ]]; then
					newtlds+=(${tlds[iter]})
					newavailables+=(${availables[iter]})
					newdenieds+=(${denieds[iter]})
				fi
			done
			tlds=("${newtlds[@]}")
			availables=("${newavailables[@]}")
			denieds=("${newdenieds[@]}")
		else
  	  list=`echo {{a..z},{0..9}}{{a..z},{0..9}}`
		fi
  fi
else
  echo -e "\e[93m"'  /----------------------> Short domain finder Beta <-----------------------\'
  echo -e "\e[93m"' /------------------> 2019 Anton Sijanec, github/AstiriL <-------------------\'
  echo -e "\e[93m"'/--------> Checks all short domain names for availability using WhoIs <-------\'
  echo -e "\e[93m"'\---> Usage: ./shortdomains.sh <TLD|all> [notfound-str] [querydenied-str] <---/'
  echo -e "\e[93m"' \---> [delayseconds-int] [save-whois-bool] [show-whois-bool] [list-path] <--/'
  echo -e "\e[93m"'  \-----------------> [search-one-letter-domains-bool=false] <--------------/'
  echo -e "\e[93m"'   \--------> Sends out a sound alert when a free domain is found <--------/'"\e[0m"
fi


if [ $ok ] ; then
	tldcount=${#tlds[@]}
	for (( i=0; i<$tldcount; i++ ));
	do
		mv freedomains.$tlds[$i] freedomains.$tlds[$i].old
		echo "---> moved freedomains.$tlds[$i] to freedomains.$tlds[$i].old"
	done
	echo "---> Starting... Delay: "$spanje s", TLDs: "$tldcount"."
	for domain in $list # do for every 2 character possibility
	do
		sleep $spanje
		for (( i=0; i<$tldcount; i++ )); # do for every tld
		do
			VAL=`whois $domain.${tlds[$i]}`
			while [[ $VAL == *${denieds[$i]}* ]]
			do
				echo -e "\e[95m$domain.${tlds[$i]} DENIED\e[0m"
				if [[ $5 == true ]]; then
					echo $VAL > "$whoisdatadir/$domain.${tlds[$i]}"
				fi
				sleep $spanje
				VAL=`whois $domain.${tlds[$i]}`
			done
			if [[ $5 == true ]]; then
				echo $VAL > "$whoisdatadir/$domain.${tlds[$i]}"
			fi
			if [[ $6 == true ]]; then
				echo $VAL
			fi
			if [[ $VAL == *${availables[$i]}* ]]
			then
				echo -e "\e[92m$domain.${tlds[$i]} FREE\e[0m\007"
				echo "$domain.${tlds[$i]}" >> freedomains.${tlds[$i]}
			else
				echo -e "\e[91m$domain.${tlds[$i]} TAKEN\e[0m"
			fi
		done
	done
	echo -e "\e[39m"
fi
