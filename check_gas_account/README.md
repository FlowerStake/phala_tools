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

Sample output:

`user@host~$ ./check_gas_account myminer1 44FhjTudjfIfusK8fKdofudlf7KSdfkK98Sgs57SsLkfuMn`
`OK - GAS Account Balance is decreasing. Last Fee: -0.010000 PHA|PHA=49.142;2;1;0;100 FEE=0.010000`

`user@host~$ ./check_gas_account myminer1 44FhjTudjfIfusK8fKdofudlf7KSdfkK98Sgs57SsLkfuMn`
`CRITICAL - GAS Account Balance is NOT decreasing (49.142343429333 = 49.142343429333)|PHA=49.142;2;1;0;100 FEE=0`
