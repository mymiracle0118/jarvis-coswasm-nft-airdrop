build:
	cargo wasm

optimize:
	docker run --rm -v "$$(pwd)":/code \
		--mount type=volume,source="$$(basename "$$(pwd)")_cache",target=/code/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		cosmwasm/rust-optimizer:0.14.0
test:
	cargo unit-test

make-wallet:
	nibid keys add wallet

show-wallet:
	nibid keys show -a ${id}

upload-testnet:
	nibid tx wasm store artifacts/jarvis_airdrop.wasm --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

instantiate-testnet:
	nibid tx wasm instantiate ${id} '{"count": 1}' --admin nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --label airdrop --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

get-count:
	nibid query wasm contract-state smart nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"get_count":{}}'

get-nft-contract-addres:
	nibid query wasm contract-state smart nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"get_nft_contract_addr":{}}'

get-all-nfts:
	nibid query wasm contract-state smart nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"get_all_nfts":{}}'

exe-set-nft-contract-addr:
	nibid tx wasm execute nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"set_nft_contract_addr":{"addr": "${id}"}}' --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

exe-send-nfts:
	nibid tx wasm execute nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"send_nfts": { \
            "allocations": [ \
                { "recipient": "terra1...", "amount": 3 }, \
                { "recipient": "terra2...", "amount": 5 } \
            ] \
        }}' --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.025unibi --yes

check-real:
	nibid tx wasm execute nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"send_nfts": { "allocations": [ { "recipient": "nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv", "amount": 3 }, { "recipient": "nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv", "amount": 5 } ] }}' --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.725unibi --yes

check:
	nibid tx wasm execute nibi178kzznh9cepjckjefqc3mgt9gf9rfkyw6kk0pymeypx9rplggvyq9yjjuv '{"send_nfts": { "allocations": [] }}' --from nibi10rdtquh3jl44hg00x0plzeawuclqqet0he4692 --gas auto --gas-adjustment 1.5 --gas-prices 0.725unibi --yes