# Jarvis Airdrop

This is a airdrop contract.

## Clone the repository

* `git clone git@github.com:mymiracle0118/jarvis-coswasm-nft-airdrop.git`
* `cd jarvis-coswasm-nft-airdrop`

## Environments for test on linux

* Install nibid 
    `curl -s https://get.nibiru.fi/! | bash`
* Set network config 

    `Testnet config` \
    RPC_URL="https://rpc.testnet-1.nibiru.fi:443" \
    nibid config node $RPC_URL \
    nibid config chain-id nibiru-testnet-1 \
    nibid config broadcast-mode sync \
    nibid config # Prints your new config to verify correctness 

    `Mainnet config` \
    RPC_URL="https://rpc.nibiru.fi:443" \
    nibid config node $RPC_URL \
    nibid config chain-id cataclysm-1 \
    nibid config broadcast-mode sync \
    nibid config # Prints your new config to verify correctness 

## Wallet config
If you are already created wallet by using nibid, you dont need to try these commands but you have to save the values to makefile.

    `make make-wallet`              # create wallet named `jarvis`. And save wallet name to `WALLET_NAME` in makefile. default is 'jarvis'. you dont need change
    `make show-wallet`              # show your pub key of created wallet. And save pub key to `WALLET_ADDRESS` in makefile.
    `make get-balance`              # get balance of your wallet. you need to have some amount nibi in your wallet for test. you can send nibi to this wallet

## Contract Deploy

### Upload & Deploy contract
    * `make upload-testnet`           # upload wasm file on nibiru chain and get code_id by analyzing tx_hash. `.logs[0].events[1].attributes[1].value`. save it *CODE_ID* in makefile 

    * `make instantiage`              # before using this command, you can change *instantiate.json* for your requirements and instantiate with `CODE_ID`. Save contract_address in `NFT_CONTRACT` of makefile. Contract address maybe is in `.logs[0].events[1].attributes[0].value` of tx
    
### !Confirm all variables are correct in makefile.
    WALLET=                           # your wallet pub key
    WALLET_NAME=                      # your wallet name, default is 'jarvis'
    CODE_ID=                          # uploaded code_id
    AIRDROP_CONTRACT=                     # deployed contract address

### Test
you can use these all commands. to use \
    first, you can change related json file in commands folder for your requirements \
    second, run this command by using make. `make command_name` \
    in addition, you need to call set-functions before using get-functions 

    get-nft-contract-address:
        $(eval GET_NFT_CONTRACT_ADDRESS := $$(shell cat ./commands/get_nft_contract_addr.json))
        @nibid query wasm contract-state smart ${AIRDROP_CONTRACT} '$(GET_NFT_CONTRACT_ADDRESS)'

    get-all-nfts:
        $(eval GET_ALL_NFTS := $$(shell cat ./commands/get_all_nfts.json))
        @nibid query wasm contract-state smart ${AIRDROP_CONTRACT} '$(GET_ALL_NFTS)'

    exe-set-nft-contract-addr:
        $(eval SET_NFT_CONTRACT_ADDR := $$(shell cat ./commands/set_nft_contract_addr.json))
        @nibid tx wasm execute ${AIRDROP_CONTRACT} '$(SET_NFT_CONTRACT_ADDR)' --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes 

    exe-send-nfts:
        $(eval SEND_NFTS := $$(shell cat ./commands/send_nfts.json))
        @nibid tx wasm execute ${AIRDROP_CONTRACT} '$(SEND_NFTS)' --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

