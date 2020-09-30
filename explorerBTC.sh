#!/bin/bash

# By @M4lal0

### Colours
greenColour="\e[0;32m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
endColour="\033[0m\e[0m"

trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${turquoiseColour}[${yellowColour}!${turquoiseColour}]${redColour} Saliendo...\n${endColour}"
    rm ut.t* money* total_entrada_salida.tmp entradas.tmp salidas.tmp address_information.tmp bitcoin-to-dollars.tmp 2>/dev/null
    tput cnorm
    exit 1
}

# variables globales
unconfirmed_transactions="https://www.blockchain.com/es/btc/unconfirmed-transactions"
inspect_transaction_url="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

function helpPanel(){
    echo -e "\n\n${turquoiseColour}[${yellowColour}!${turquoiseColour}]${purpleColour} Uso: ./explorerBTC${endColour}"
    for i in $(seq 1 100); do echo -ne "${purpleColour}-"; done; echo -ne "${endColour}"
    echo -e "\n${grayColour}Opciones:${endColour}"
    echo -e "\n\t${turquoiseColour}[${yellowColour}-e${turquoiseColour}]${grayColour} Modo exploración${endColour}"
    echo -e "\t\t${redColour}unconfirmed_transactions${grayColour}:\t Listar transacciones no confirmadas; default: 100 resultados${endColour}"
    echo -e "\t\t${redColour}inspect${grayColour}:\t\t\t Inspeccionar un hash de transacción${endColour}"
    echo -e "\t\t${redColour}address${grayColour}:\t\t\t Inspeccionar una transacción de dirección${endColour}"
    echo -e "\n\t${turquoiseColour}[${yellowColour}-n${turquoiseColour}]${grayColour} Limitar el número de resultados${blueColour} (Ejemplo: ./explorerBTC -e unconfirmed_trasactions -n 10)${endColour}"
    echo -e "\n\t${turquoiseColour}[${yellowColour}-i${turquoiseColour}]${grayColour} Proporcionar el identificador de transacción${blueColour} (Ejemplo ./explorerBTC -e inspect -i 2sd12d34f1s1123)${endColour}"
    echo -e "\n\t${turquoiseColour}[${yellowColour}-a${turquoiseColour}]${grayColour} Proporcionar una dirección de transacción${blueColour} (Ejemplo ./explorerBTC -e address -a adsd34a3a2as4da2)${endColour}"
    echo -e "\n\t${turquoiseColour}[${yellowColour}-h${turquoiseColour}]${grayColour} Mostrar este panel de ayuda${endColour}\n"

    tput cnorm; exit 1
}

function banner(){
    echo -e "\t${blueColour} ___       _ __  _                     ${greenColour}  ___  _____   ___ ${endColour}"
    echo -e "\t${blueColour}| __|__ __| '_ \| | ___  _ _  ___  _ _ ${greenColour} | _ )|_   _| / __|${endColour}"
    echo -e "\t${blueColour}| _| \ \ /| .__/| |/ _ \| '_|/ -_)| '_|${greenColour} | _ \  | |  | (__ ${endColour}"
    echo -e "\t${blueColour}|___|/_\_\|_|   |_|\___/|_|  \___||_|  ${greenColour} |___/  |_|   \___|${endColour}"
    echo -e "\n\tExplorador de transacciones de Bitcoin${redColour} --[ By @m4lal0 ] --${endColour}\n"
}

function validates(){
sudo dpkg -s html2text > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${turquoiseColour}[${yellowColour}!${turquoiseColour}]${redColour} No tienes instalado la aplicación ${grayColour}html2text${redColour}...iniciando la instalación${endColour}"
    sudo apt-get install html2text -y > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${turquoiseColour}[${redColour}✘${turquoiseColour}]${redColour} No se pudo instalar html2text, debes instalarlo de manera manual.${endColour}"
        tput cnorm
        exit 1
    else
        echo -e "${turquoiseColour}[${greenColour}✔${turquoiseColour}]${greenColour} Finalizado la instalación de ${grayColour}html2text${endColour}"
        echo -e "\n${turquoiseColour}[${yellowColour}!${turquoiseColour}]${grayColour} Debes reiniciar la ejecución del programa.${endColour}"
        tput cnorm
        exit 0
    fi
fi
sudo dpkg -s bc > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${turquoiseColour}[${yellowColour}!${turquoiseColour}]${redColour} No tienes instalado la aplicación ${grayColour}bc${redColour}...iniciando la instalación${endColour}"
    sudo apt-get install bc -y > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${turquoiseColour}[${redColour}✘${turquoiseColour}]${redColour} No se pudo instalar bc, debes instalarlo de manera manual.${endColour}"
        tput cnorm
        exit 1
    else
        echo -e "${turquoiseColour}[${greenColour}✔${turquoiseColour}]${greenColour} Finalizado la instalación de ${grayColour}bc${endColour}"
        echo -e "\n${turquoiseColour}[${yellowColour}!${turquoiseColour}]${grayColour} Debes reiniciar la ejecución del programa.${endColour}"
        tput cnorm
        exit 0
    fi
fi
}

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function unconfirmedTransactions(){
    number_output=$1
    
    echo '' > ut.tmp

    while [ "$(cat ut.tmp | wc -l)" == "1" ]; do
        curl -s "$unconfirmed_transactions" | html2text > ut.tmp
    done
    
    hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Tiempo" | head -n $number_output)
    
    echo "Hash_Cantidad_Bitcoin_Tiempo" > ut.table

    for hash in $hashes; do
        echo "${hash}_$(cat ut.tmp | grep "$hash" -A 6 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 4 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 2 | tail -n 1)" >> ut.table
    done

    cat ut.table | tr '_' ' ' | awk '{print $2}' | grep -v "Cantidad" | tr -d '$' | sed 's/\..*//g' | tr -d ',' > money

    money=0; cat money | while read money_in_line; do
        let money+=$money_in_line
        echo $money > money.tmp
    done;

    echo -n "Cantidad Total_" > amount.table
    echo "\$$(printf "%'.d\n" $(cat money.tmp))" >> amount.table

    if [ "$(cat ut.table | wc -l)" != "1" ]; then
        echo -ne "${grayColour}"
        printTable '_' "$(cat ut.table)"
        echo -ne "${endColour}"
        echo -ne "${greenColour}"
        printTable '_' "$(cat amount.table)"
        echo -ne "${endColour}"
        rm ut.* money* amount.table 2>/dev/null
        tput cnorm; exit 0
    else
        rm ut.t* 2>/dev/null
    fi

    rm ut.* money* amount.table 2>/dev/null
    tput cnorm
}

function inspectTransaction(){
    inspect_transaction_hash=$1

    echo "Entrada Total_Salida Total" > total_entrada_salida.tmp

    while [ "$(cat total_entrada_salida.tmp | wc -l)" == "1" ]; do
        curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep -E "Total entradas|Total de salida" -A 1 | grep -v -E "Total entradas|Total de salida" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> total_entrada_salida.tmp
    done

    echo -ne "${grayColour}"
    printTable '_' "$(cat total_entrada_salida.tmp)"
    echo -ne "${endColour}"
    rm total_entrada_salida.tmp 2>/dev/null

    echo "Dirección (Entradas)_Valor" > entradas.tmp

    while [ "$(cat entradas.tmp | wc -l)" == "1" ]; do
        curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep "Entradas" -A 500 | grep "Salidas" -B 500 | grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> entradas.tmp
    done

    echo -ne "${greenColour}"
    printTable '_' "$(cat entradas.tmp)"
    echo -ne "${endColour}"
    rm entradas.tmp 2>/dev/null

    echo "Dirección (Salidas)_Valor" > salidas.tmp

    while [ "$(cat salidas.tmp | wc -l)" == "1" ]; do
        curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep "Salidas" -A 500 | grep "***** Hab" -B 500 | grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> salidas.tmp
    done

    echo -ne "${redColour}"
    printTable '_' "$(cat salidas.tmp)"
    echo -ne "${endColour}"
    rm salidas.tmp 2>/dev/null

    tput cnorm
}

function inspectAddress(){
    address_hash=$1

    echo "Transacciones realizadas_Cantidad total recibida (BTC)_Cantidad total enviada (BTC)_Saldo total en la cuenta (BTC)" > address_information.tmp
    curl -s "${inspect_address_url}${address_hash}" | html2text | grep -E "Transacciones|Total Recibidas|Cantidad total enviada|Saldo final" -A 1 | head -n -2 | grep -v -E "Transacciones|Total Recibidas|Cantidad total enviada|Saldo final" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> address_information.tmp

    echo -ne "${grayColour}"
    printTable '_' "$(cat address_information.tmp)"
    echo -ne "${endColour}"
    rm address_information.tmp 2>/dev/null

    bitcoin_value=$(curl -s "https://es.cointelegraph.com/bitcoin-price-index" | html2text | grep "Last Price" | head -n 1 | awk 'NF{print $NF}' | tr -d ',')

    curl -s "${inspect_address_url}${address_hash}" | html2text | grep "Transacciones" -A 1 | head -n -2 | grep -v -E "Transacciones|\--" > address_information.tmp
    curl -s "${inspect_address_url}${address_hash}" | html2text | grep -E "Total Recibidas|Cantidad total enviada|Saldo final" -A 1 | grep -v -E "otal Recibidas|Cantidad total enviada|Saldo final|\--" > bitcoin-to-dollars.tmp

    cat bitcoin-to-dollars.tmp | while read value; do
        echo "\$$(printf "%'.d\n" $(echo "$(echo $value | awk '{print $1}')*$bitcoin_value" | bc) 2>/dev/null)" >> address_information.tmp
    done

    line_null=$(cat address_information.tmp | grep -n "^\$$" | awk '{print $1}' FS=":")

    if [ $line_null ]; then
        sed "${line_null}s/\$/0.00/" -i address_information.tmp
    fi

    cat address_information.tmp | xargs | tr ' ' '_' >> address_information2.tmp
    rm address_information.tmp 2>/dev/null  && mv address_information2.tmp address_information.tmp
    sed '1iTransacciones realizadas_Cantidad total recibidas (USD)_Cantidad total enviada (USD)_Saldo actual en la cuenta (USD)' -i address_information.tmp

    echo -ne "${yellowColour}"
    printTable '_' "$(cat address_information.tmp)"
    echo -ne "${endColour}"

    rm address_information.tmp bitcoin-to-dollars.tmp 2>/dev/null
    tput cnorm
}

banner
validates

parameter_counter=0; while getopts "e:n:i:a:h:" arg; do
    case $arg in
        e) exploration_mode=$OPTARG; let parameter_counter+=1;;
        n) number_output=$OPTARG; let parameter_counter+=1;;
        i) inspect_transaction=$OPTARG; let parameter_counter+=1;;
        a) inspect_address=$OPTARG; let parameter_counter+=1;;
        h) helpPanel;;
    esac
done

tput civis

if [ $parameter_counter -eq 0 ]; then
    helpPanel
else
    if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
        if [ ! "$number_output" ]; then
            number_output=100
            unconfirmedTransactions $number_output
        else
            unconfirmedTransactions $number_output
        fi
    elif [ "$(echo $exploration_mode)" == "inspect" ]; then
        inspectTransaction $inspect_transaction
    elif [ "$(echo $exploration_mode)" == "address" ]; then
        inspectAddress $inspect_address
    fi
fi