use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{Addr, Binary};

#[cw_serde]
pub struct InstantiateMsg {
    pub count: i32,
}

#[cw_serde]
pub enum ExecuteMsg {
    Increment {},
    Reset { count: i32 },
    ReceiveNft {
        sender: String,
        token_id: String,
        msg: Binary,
    },
    SendNfts {
        allocations: Vec<SendNftParam>, // Each tuple contains an address and the number of NFTs to send
    },
    SetNftContractAddr { addr: String },
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    // GetCount returns the current count as a json-encoded number
    #[returns(GetCountResponse)]
    GetCount {},

    #[returns(AllNftsResponse)]
    GetAllNfts {},

    #[returns(NftContractAddrResponse)]
    GetNftContractAddr {},
}

// We define a custom struct for each query response
#[cw_serde]
pub struct GetCountResponse {
    pub count: i32, 
}

#[cw_serde]
pub struct AllNftsResponse {
    pub nfts: Vec<String>,
}

#[cw_serde]
pub struct NftContractAddrResponse {
    pub nft_contract_addr: Addr,
}

#[cw_serde]
pub struct SendNftParam {
    pub recipient: Addr,
    pub amount: u32
}