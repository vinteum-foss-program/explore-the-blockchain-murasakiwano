# Which tx in block 257,343 spends the coinbase output of block 256,128?

blockhash=$(bitcoin-cli getblockhash 256128)
coinbasetxid=$(
  bitcoin-cli getblock $blockhash |
    jq -r ".tx.[0]" # First transaction in a block is the coinbase tx
)

blockhash=$(bitcoin-cli getblockhash 257343)
txids=$(bitcoin-cli getblock $blockhash | jq -r ".tx.[]")

for txid in ${txids[@]}; do
  tx=$(bitcoin-cli getrawtransaction $txid 1)
  txvin=$(echo $tx | jq -r '.vin.[] | .txid')

  for txvinid in ${txvin[@]}; do
    if [[ $txvinid = $coinbasetxid ]]; then
      break 2
    fi
  done
done

echo $tx | jq -r '.txid'
