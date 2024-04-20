build:
	cargo wasm

optimize:
	docker run --rm -v "$$(pwd)":/code \
		--mount type=volume,source="$$(basename "$$(pwd)")_cache",target=/code/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		cosmwasm/rust-optimizer:0.14.0
test:
	cargo unit-test

FROM=nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692
AIRDROP_CONTRACT=nibi10jwwkmmn0rzxvfec5swhgvtkh4l94fshz0r8ndj9ldym87lkgdjs4z4cyp

make-wallet:
	@nibid keys add wallet

show-wallet:
	@nibid keys show -a ${id}

upload-testnet:
	@nibid tx wasm store artifacts/jarvis_airdrop.wasm --from ${FROM} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

instantiate-testnet:
	@nibid tx wasm instantiate ${id} '{"count": 1}' --admin ${FROM} --label airdrop --from ${FROM} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

get-count:
	$(eval GET_COUNT := $$(shell cat ./commands/get_count.json))
	@nibid query wasm contract-state smart ${AIRDROP_CONTRACT} '$(GET_COUNT)'

get-nft-contract-addres:
	$(eval GET_NFT_CONTRACT_ADDRESS := $$(shell cat ./commands/get_nft_contract_addr.json))
	@nibid query wasm contract-state smart ${AIRDROP_CONTRACT} '$(GET_NFT_CONTRACT_ADDRESS)'

get-all-nfts:
	$(eval GET_ALL_NFTS := $$(shell cat ./commands/get_all_nfts.json))
	@nibid query wasm contract-state smart ${AIRDROP_CONTRACT} '$(GET_ALL_NFTS)'

exe-set-nft-contract-addr:
	$(eval SET_NFT_CONTRACT_ADDR := $$(shell cat ./commands/set_nft_contract_addr.json))
	@nibid tx wasm execute ${AIRDROP_CONTRACT} '$(SET_NFT_CONTRACT_ADDR)' --from ${FROM} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes 

exe-send-nfts:
	$(eval SEND_NFTS := $$(shell cat ./commands/send_nfts.json))
	@nibid tx wasm execute ${AIRDROP_CONTRACT} '$(SEND_NFTS)' --from ${FROM} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes