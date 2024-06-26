#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{
    to_json_binary, Addr, Binary, CosmosMsg, Deps, DepsMut, Env, MessageInfo, Response, StdResult,
    SubMsg, WasmMsg,
};
use cw2::set_contract_version;
use cw721::Cw721ExecuteMsg;

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg, AllNftsResponse, NftContractAddrResponse, SendNftParam};
use crate::state::{State, STATE, NFTS, NFT_CONTRACT_ADDR};

// version info for migration info
const CONTRACT_NAME: &str = "crates.io:jarvis-airdrop";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    let state = State {
        owner: info.sender.clone(),
    };
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;
    STATE.save(deps.storage, &state)?;

    Ok(Response::new()
        .add_attribute("method", "instantiate")
        .add_attribute("owner", info.sender))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::SetNftContractAddr { addr } => {
            execute::set_nft_contract_addr(deps, env, info, addr)
        }
        ExecuteMsg::ReceiveNft {
            sender,
            token_id,
            msg,
        } => execute::receive_nft(deps, env, info, token_id),
        ExecuteMsg::SendNfts { allocations } => execute::send_nfts(deps, env, info, allocations),
    }
}

pub mod execute {
    use super::*;

    pub fn set_nft_contract_addr(
        deps: DepsMut,
        _env: Env,
        info: MessageInfo,
        addr: String,
    ) -> Result<Response, ContractError> {
        let state = STATE.load(deps.storage)?;

        // Check if the sender is the owner
        if info.sender != state.owner {
            return Err(ContractError::Unauthorized {});
        }

        // Optionally, add authorization checks here to ensure only specific addresses can update this
        let nft_contract_addr = deps.api.addr_validate(&addr)?;
        NFT_CONTRACT_ADDR.save(deps.storage, &nft_contract_addr)?;
        Ok(Response::new()
            .add_attribute("action", "set_nft_contract_addr")
            .add_attribute("address", addr))
    }

    pub fn receive_nft(
        deps: DepsMut,
        _env: Env,
        _info: MessageInfo,
        token_id: String,
    ) -> Result<Response, ContractError> {
        let mut nfts = NFTS.load(deps.storage).unwrap_or_default();
        nfts.push(token_id);
        NFTS.save(deps.storage, &nfts)?;

        Ok(Response::new().add_attribute("action", "receive_nft"))
    }

    pub fn send_nfts(
        deps: DepsMut,
        _env: Env,
        info: MessageInfo,
        allocations: Vec<SendNftParam>,
    ) -> Result<Response, ContractError> {
        let state = STATE.load(deps.storage)?;

        // Check if the sender is the owner
        if info.sender != state.owner {
            return Err(ContractError::Unauthorized {});
        }

        // Load and validate the NFT contract address
        let nft_contract_addr = NFT_CONTRACT_ADDR.load(deps.storage)?;
        let validated_addr = deps.api.addr_validate(nft_contract_addr.as_str())?;

        let mut nfts = NFTS.load(deps.storage)?;
        let mut response = Response::new().add_attribute("action", "send_nfts");
    
        for ele in allocations {
            for _ in 0..ele.amount {
                if let Some(token_id) = nfts.pop() {
                    // Create a transfer message for the cw721 NFT
                    let transfer_msg = Cw721ExecuteMsg::TransferNft {
                        recipient: ele.recipient.to_string(),
                        token_id: token_id,
                    };

                    let msg = CosmosMsg::Wasm(WasmMsg::Execute {
                        contract_addr: validated_addr.clone().to_string(),
                        msg: to_json_binary(&transfer_msg)?,
                        funds: vec![],
                    });

                    response.messages.push(SubMsg::new(msg));
                } else {
                    return Err(ContractError::InsufficientNFTs {});
                }
            }
        }

        NFTS.save(deps.storage, &nfts)?;
        Ok(response)
    }
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetAllNfts {} => to_json_binary(&query::all_nfts(deps)?),
        QueryMsg::GetNftContractAddr {} => to_json_binary(&query::nft_contract_addr(deps)?),
    }
}

pub mod query {
    use super::*;

    pub fn all_nfts(deps: Deps) -> StdResult<AllNftsResponse> {
        let nfts = NFTS.load(deps.storage)?;
        Ok(AllNftsResponse { nfts })
    }

    pub fn nft_contract_addr(deps: Deps) -> StdResult<NftContractAddrResponse> {
        let nft_contract_addr = NFT_CONTRACT_ADDR.load(deps.storage)?;
        Ok(NftContractAddrResponse { nft_contract_addr })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use cosmwasm_std::testing::{mock_dependencies, mock_env, mock_info};
    use cosmwasm_std::{coins, from_json};

    #[test]
    fn proper_initialization() {
        let mut deps = mock_dependencies();

        let msg = InstantiateMsg {};
        let info = mock_info("creator", &coins(1000, "earth"));

        // we can just call .unwrap() to assert this was a success
        let res = instantiate(deps.as_mut(), mock_env(), info, msg).unwrap();
        assert_eq!(0, res.messages.len());
    }
}
