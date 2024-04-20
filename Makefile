build:
	cargo wasm

optimize:
	docker run --rm -v "$$(pwd)":/code \
		--mount type=volume,source="$$(basename "$$(pwd)")_cache",target=/code/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		cosmwasm/rust-optimizer:0.14.0
test:
	cargo unit-test

<<<<<<< HEAD
FROM=nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692
AIRDROP_CONTRACT=nibi10jwwkmmn0rzxvfec5swhgvtkh4l94fshz0r8ndj9ldym87lkgdjs4z4cyp
=======
WALLET=nibi1d3lmwkgjgdyfpsn4xgh299jnpk4r89kd5xs420
AIRDROP_CONTRACT=nibi1lz6h4tav6q8jrpxxs6kv63hztlmpu27jj50jcnrt9p7wd2nrmz9s9600vz
CODE_ID=421
WALLET_NAME=jarvis
>>>>>>> f8a4af504d3b45ae487ba064c7d39c846c54be0e

make-wallet:
	@nibid keys add wallet ${WALLET_NAME}

show-wallet:
	@nibid keys show -a ${WALLET}

get-balance:
	@nibid query bank balances ${WALLET} --denom unibi

upload-testnet:
	@nibid tx wasm store artifacts/jarvis_airdrop.wasm --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

instantiate-testnet:
	@nibid tx wasm instantiate ${CODE_ID} --admin ${WALLET} --label airdrop --from ${WALLET} --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

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