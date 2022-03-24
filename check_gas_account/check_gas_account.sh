#!/usr/bin/bash

HOST=$1
ADDRESS=$2
[[ -v $3 ]] && WARN=$3 || WARN=2
[[ -v $4 ]] && CRIT=$4 || CRIT=1
[[ -v $5 ]] && MAX=$5 || MAX=100

JQ_BIN=`which jq`
BC_BIN=`which bc`
cURL_BIN=`which curl`

if [ "$JQ_BIN" = "" ] || [ "$BC_BIN" = "" ] || [ "$cURL_BIN" = "" ];then
	echo ""
        echo "You need to have installed 'jq', 'bc' and 'cURL' tools, do it with: sudo apt install jq bc curl"
	echo ""
	exit 3
fi

help() {
	echo ""
	echo "Usage: check_gas_account.sh NODE ADDRESS [WARNING] [CRITICAL] [MAXIMUM]"
	echo ""
	echo "	NODE: Miner Node Hostname"
	echo "	ADDRESS: Account address showed in 'phala status' command as 'GAS account address' on the specified miner"
	echo "	WARNING (optional): PHA balance threshold to trigger warning alert (Default: 2 PHA. Must be greater than CRITICAL)"
	echo "	CRITICAL (optional): PHA balance threshold to trigger critical alert (Default: 1 PHA. Must be lower than WARNING)"
	echo "	MAXIMUM (optional): Max amount of funds on the account (Default: 100. Only for graph pourposes)"
	echo ""
}

if [ $# -lt 2 ] || [ $WARN -le $CRIT ] || [ "$JQ_BIN" = "" ] || [ "$BC_BIN" = "" ];then
	help
	exit 3
fi

## Our file to save previous account balance
TEMPFILE="/var/tmp/gas_balance_${HOST}_${ADDRESS}"

## Check if Temp File Exist and not empty, if not, we create it
if [ -s $TEMPFILE ];then
    PREVIOUS_BALANCE=`cat $TEMPFILE`
else
    touch $TEMPFILE
    BALANCE=`$cURL_BIN -s -X POST 'https://khala.api.subscan.io/api/open/account' --header 'Content-Type: application/json' --data-raw '{"address":"'$ADDRESS'"}'|$JQ_BIN '.data.balance' -r |tee $TEMPFILE`
    echo "First run! TEMPFILE does not exist. Creating with Balance = $BALANCE PHA"
    exit 3
fi

## Get current account balance from SubScan API
CURRENT_BALANCE=`$cURL_BIN -s -X POST 'https://khala.api.subscan.io/api/open/account' --header 'Content-Type: application/json' --data-raw '{"address":"'$ADDRESS'"}'|$JQ_BIN '.data.balance' -r|tee $TEMPFILE`

## Format balance for performance data
PERF_BALANCE=`echo $CURRENT_BALANCE|awk '{printf "%.3f", $0}'`

## Lets go with the math
if [ $(echo "$PREVIOUS_BALANCE > $CURRENT_BALANCE" |$BC_BIN -l) -ne 0 ];then
        DECREMENT=`echo "$PREVIOUS_BALANCE - $CURRENT_BALANCE" | $BC_BIN | awk '{printf "%f", $0}'`
        echo "OK - GAS Account Balance is decreasing. Last Fee: -$DECREMENT PHA|PHA=$PERF_BALANCE;$WARN;$CRIT;0;$MAX FEE=$DECREMENT"
        STATE=0
else
        echo "CRITICAL - GAS Account Balance is NOT decreasing ($PREVIOUS_BALANCE = $CURRENT_BALANCE)|PHA=$PERF_BALANCE;$WARN;$CRIT;0;$MAX FEE=0"
        STATE=2
fi

## There must always be funds in the GAS Account
if [ $(echo "2 > $CURRENT_BALANCE" |$BC_BIN -l) -ne 0 ];then
        echo "WARNING - GAS Account Balance is low ( $CURRENT_BALANCE < 2 PHA)|PHA=$PERF_BALANCE;$WARN;$CRIT;0;$MAX FEE=$DECREMENT"
        STATE=1
elif [ $(echo "1 > $CURRENT_BALANCE" |$BC_BIN -l) -ne 0 ];then
        echo "CRITICAL - GAS Account Balance is dangerously low ( $CURRENT_BALANCE < 1 PHA)|PHA=$PERF_BALANCE;$WARN;$CRIT;0;$MAX FEE=$DECREMENT"
        STATE=2
fi

exit $STATE
