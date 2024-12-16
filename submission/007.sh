# Only one single output remains unspent from block 123,321. What address was it sent to?
blockhash=$(bitcoin-cli getblockhash 123321)
transactionids=$(bitcoin-cli getblock $blockhash | jq -r .tx.[])

gettransaction() {
  rawtx=$(bitcoin-cli getrawtransaction $txid)

  bitcoin-cli decoderawtransaction $rawtx | jq .
}

for txid in ${transactionids[@]}; do
  vouts=$(gettransaction $txid | jq ".vout.[].n")

  for n in ${vouts[@]}; do
    txout=$(bitcoin-cli gettxout $txid $n)

    if [[ ! -z $txout ]]; then
      break 2
    fi
  done
done

echo $txout | jq -r .scriptPubKey.address
