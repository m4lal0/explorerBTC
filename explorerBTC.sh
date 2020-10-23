#!/bin/bash

# By @M4lal0

# Regular Colors
Black='\033[0;30m'      # Black
Red='\033[0;31m'        # Red
Green='\033[0;32m'      # Green
Yellow='\033[0;33m'     # Yellow
Blue='\033[0;34m'       # Blue
Purple='\033[0;35m'     # Purple
Cyan='\033[0;36m'       # Cyan
White='\033[0;97m'      # White
Color_Off='\033[0m'     # Text Reset

# Additional colors
LGray='\033[0;37m'      # Ligth Gray
DGray='\033[0;90m'      # Dark Gray
LRed='\033[0;91m'       # Ligth Red
LGreen='\033[0;92m'     # Ligth Green
LYellow='\033[0;93m'    # Ligth Yellow
LBlue='\033[0;94m'      # Ligth Blue
LPurple='\033[0;95m'    # Light Purple
LCyan='\033[0;96m'      # Ligth Cyan

# Bold
BBlack='\033[1;30m'     # Black
BGray='\033[1;37m'		# Gray
BRed='\033[1;31m'       # Red
BGreen='\033[1;32m'     # Green
BYellow='\033[1;33m'    # Yellow
BBlue='\033[1;34m'      # Blue
BPurple='\033[1;35m'    # Purple
BCyan='\033[1;36m'      # Cyan
BWhite='\033[1;37m'     # White

# Underline
UBlack='\033[4;30m'     # Black
UGray='\033[4;37m'		# Gray
URed='\033[4;31m'       # Red
UGreen='\033[4;32m'     # Green
UYellow='\033[4;33m'    # Yellow
UBlue='\033[4;34m'      # Blue
UPurple='\033[4;35m'    # Purple
UCyan='\033[4;36m'      # Cyan
UWhite='\033[4;37m'     # White

# Background
On_Black='\033[40m'     # Black
On_Red='\033[41m'       # Red
On_Green='\033[42m'     # Green
On_Yellow='\033[43m'    # Yellow
On_Blue='\033[44m'      # Blue
On_Purple='\033[45m'    # Purple
On_Cyan='\033[46m'      # Cyan
On_White='\033[47m'     # White


trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${Cyan}[${Yellow}!${Cyan}]${Red} Saliendo...\n${Color_Off}"
    rm ut.t* money* total_entrada_salida.tmp entradas.tmp salidas.tmp address_information.tmp bitcoin-to-dollars.tmp 2>/dev/null
    tput cnorm
    exit 1
}

# variables globales
unconfirmed_transactions="https://www.blockchain.com/es/btc/unconfirmed-transactions"
inspect_transaction_url="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

function helpPanel(){
    echo -e "\n${Cyan}[${Yellow}!${Cyan}]${BGray} USO:\n\t ${Purple}./explorerBTC [Opción]${Color_Off}"
    for i in $(seq 1 115); do echo -ne "${Purple}-"; done; echo -ne "${Color_Off}"
    echo -e "\n${BGray}OPCIONES:${Color_Off}"
    echo -e "\t${Cyan}[${Yellow}-e${Cyan}]${LGray} Modo exploración${Color_Off}"
    echo -e "\t\t${Red}unconfirmed_transactions${LGray}:\t Listar transacciones no confirmadas; resultados por default: 100${Color_Off}"
    echo -e "\t\t${Red}inspect${LGray}:\t\t\t Inspeccionar un hash de transacción${Color_Off}"
    echo -e "\t\t${Red}address${LGray}:\t\t\t Inspeccionar una transacción de dirección${Color_Off}"
    echo -e "\t${Cyan}[${Yellow}-n${Cyan}]${LGray} Limitar el número de resultados${Color_Off}"
    echo -e "\t${Cyan}[${Yellow}-i${Cyan}]${LGray} Proporcionar el identificador de transacción${Color_Off}"
    echo -e "\t${Cyan}[${Yellow}-a${Cyan}]${LGray} Proporcionar una dirección de transacción${Color_Off}"
    echo -e "\t${Cyan}[${Yellow}-h${Cyan}]${LGray} Mostrar este panel de ayuda${Color_Off}"
    echo -e "\n${BGray}EJEMPLOS:${Color_Off}"
    echo -e "\t${LGray}./explorerBTC ${Yellow}-e ${Red}unconfirmed_trasactions ${Yellow}-n ${LGray}10${Color_Off}"
    echo -e "\t${LGray}./explorerBTC ${Yellow}-e ${Red}inspect ${Yellow}-i ${LGray}2sd12d34f1s1123hjty543sdf${Color_Off}"
    echo -e "\t${LGray}./explorerBTC ${Yellow}-e ${Red}address ${Yellow}-a ${LGray}adsd34a3a2as4da2lugdf565f${Color_Off}\n"

    tput cnorm; exit 1
}

function banner(){
    echo -e "\t${BBlue} ___       _ __  _                     ${BGreen}  ___  _____   ___ ${Color_Off}"
    echo -e "\t${BBlue}| __|__ __| '_ \| | ___  _ _  ___  _ _ ${BGreen} | _ )|_   _| / __|${Color_Off}"
    echo -e "\t${BBlue}| _| \ \ /| .__/| |/ _ \| '_|/ -_)| '_|${BGreen} | _ \  | |  | (__ ${Color_Off}"
    echo -e "\t${BBlue}|___|/_\_\|_|   |_|\___/|_|  \___||_|  ${BGreen} |___/  |_|   \___|${Color_Off}"
    echo -e "\n\tExplorador de transacciones de Bitcoin${Red} --[ By @m4lal0 ] --${Color_Off}\n"
}

function validates(){
    if [ ! -x "$(command -v html2text)" ];then
            echo -e "${Cyan}[${Yellow}!${Cyan}]${Red} html2text no detectado... Instalando${Color_Off}"
            sudo apt-get install html2text -y  > /dev/null 2>&1
    fi
    if [ ! -x "$(command -v bc)" ];then
            echo -e "${Cyan}[${Yellow}!${Cyan}]${Red} bc no detectado... Instalando${Color_Off}"
            sudo apt-get install bc -y  > /dev/null 2>&1
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
        echo -ne "${BGray}"
        printTable '_' "$(cat ut.table)"
        echo -ne "${Color_Off}"
        echo -ne "${Green}"
        printTable '_' "$(cat amount.table)"
        echo -ne "${Color_Off}"
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

    echo -ne "${BGray}"
    printTable '_' "$(cat total_entrada_salida.tmp)"
    echo -ne "${Color_Off}"
    rm total_entrada_salida.tmp 2>/dev/null

    echo "Dirección (Entradas)_Valor" > entradas.tmp

    while [ "$(cat entradas.tmp | wc -l)" == "1" ]; do
        curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep "Entradas" -A 500 | grep "Salidas" -B 500 | grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> entradas.tmp
    done

    echo -ne "${Green}"
    printTable '_' "$(cat entradas.tmp)"
    echo -ne "${Color_Off}"
    rm entradas.tmp 2>/dev/null

    echo "Dirección (Salidas)_Valor" > salidas.tmp

    while [ "$(cat salidas.tmp | wc -l)" == "1" ]; do
        curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep "Salidas" -A 500 | grep "***** Hab" -B 500 | grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> salidas.tmp
    done

    echo -ne "${Red}"
    printTable '_' "$(cat salidas.tmp)"
    echo -ne "${Color_Off}"
    rm salidas.tmp 2>/dev/null

    tput cnorm
}

function inspectAddress(){
    address_hash=$1

    echo "Transacciones realizadas_Cantidad total recibida (BTC)_Cantidad total enviada (BTC)_Saldo total en la cuenta (BTC)" > address_information.tmp
    curl -s "${inspect_address_url}${address_hash}" | html2text | grep -E "Transacciones|Total Recibidas|Cantidad total enviada|Saldo final" -A 1 | head -n -2 | grep -v -E "Transacciones|Total Recibidas|Cantidad total enviada|Saldo final" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> address_information.tmp

    echo -ne "${LGray}"
    printTable '_' "$(cat address_information.tmp)"
    echo -ne "${Color_Off}"
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

    echo -ne "${Yellow}"
    printTable '_' "$(cat address_information.tmp)"
    echo -ne "${Color_Off}"

    rm address_information.tmp bitcoin-to-dollars.tmp 2>/dev/null
    tput cnorm
}

banner
validates

parameter_counter=0; while getopts "e:n:i:a:h" arg; do
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
    else
        helpPanel
    fi
fi