# Which public key signed input 0 in this tx:
#   `e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163`

txid="e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163"
tx=$(bitcoin-cli getrawtransaction $txid 1)
input=$(echo $tx | jq -r '.vin[0].txinwitness[1]')
script=$(echo $tx | jq -r '.vin[0].txinwitness[2]')

bitcoin-cli decodescript $script | jq '.asm' | grep -oE '02[0-9a-f]{64}|03-[0-9a-f]{64}' >tmp.txt

if [[ "$input" == "01" ]]; then
  head -n 1 tmp.txt
else
  tail -n 1 tmp.txt
fi

rm tmp.txt
