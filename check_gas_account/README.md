# check_gas_account.sh

Pretty simple shell script to check if GAS account balance used to pay miner transactions is decreasing over time. If GAS account balance is not decreasing might means there is any issue.

It is specifically designed to be used on nagios/naemon or similar monitoring tools, but you can run it from cron and add some kind of notifications to it.

NOTE: The check interval should be adjusted on a case-by-case basis, but it is not recommended to be less than 2 hours.

To see help, execute it without parameters:

`user@host~$ ./check_gas_account`

       Usage: check_gas_account.sh NODE ADDRESS [WARNING] [CRITICAL] [MAXIMUM]

                NODE: Miner Node Hostname
                ADDRESS: Account address showed in 'phala status' command as 'GAS account address' on the specified miner
                WARNING (optional): PHA balance threshold to trigger warning alert (Default: 2 PHA. Must be greater than CRITICAL)
                CRITICAL (optional): PHA balance threshold to trigger critical alert (Default: 1 PHA. Must be lower than WARNING)
                MAXIMUM (optional): Max amount of funds on the account (Default: 100. Only for graph pourposes)


NOTE: You need to have installed `jq` and `bc` tools, do it with command `sudo apt install jq bc`
