build:
	cargo wasm

optimize:
	docker run --rm -v "$$(pwd)":/code \
		--mount type=volume,source="$$(basename "$$(pwd)")_cache",target=/code/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		cosmwasm/rust-optimizer:0.14.0
test:
	cargo unit-test

WALLET=nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692
AIRDROP_CONTRACT=nibi1hc3cl36mnty08e34cp6gy4rnej378w7qhrxjxxzq3jdm04qa5w5seqwemv
CODE_ID=436
WALLET_NAME=jarvis

make-wallet:
	@nibid keys add wallet ${WALLET_NAME}

show-wallet:
	@nibid keys show -a ${WALLET}

get-balance:
	@nibid query bank balances ${WALLET} --denom unibi

upload-testnet:
	@nibid tx wasm store artifacts/jarvis_airdrop.wasm --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

instantiate-testnet:
	$(eval INSTANTIATE := $$(shell cat ./commands/instantiate.json))
	@nibid tx wasm instantiate ${CODE_ID} '${INSTANTIATE}' --admin ${WALLET} --label airdrop --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

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