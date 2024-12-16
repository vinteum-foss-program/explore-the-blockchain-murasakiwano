# Which tx in block 257,343 spends the coinbase output of block 256,128?

gettransaction() {
  rawtx=$(bitcoin-cli getrawtransaction $1)

  bitcoin-cli decoderawtransaction $rawtx | jq .
}

blockhash=$(bitcoin-cli getblockhash 256128)
coinbasetxid=$(
  bitcoin-cli getblock $blockhash |
    jq ".tx.[0]" | # First transaction in a block is the coinbase tx
    awk '{gsub(/^\"/, ""); gsub(/\"$/, ""); print}'
)

blockhash=$(bitcoin-cli getblockhash 257343)
txids=$(bitcoin-cli getblock $blockhash | jq ".tx.[]")

for txid in ${txids[@]}; do
  tx=$(gettransaction $(echo $txid | awk '{gsub(/"/, ""); print}'))
  txvin=$(echo $tx | jq '.vin.[] | .txid')

  for txvinid in ${txvin[@]}; do
    txvinid=$(echo $txvinid | awk '{gsub(/"/, ""); print}')

    if [[ $txvinid = $coinbasetxid ]]; then
      break 2
    fi
  done
done

echo $txvinid
