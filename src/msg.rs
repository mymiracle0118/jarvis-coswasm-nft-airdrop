use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{Addr, Binary};

#[cw_serde]
pub struct InstantiateMsg {}

#[cw_serde]
pub enum ExecuteMsg {
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
    #[returns(AllNftsResponse)]
    GetAllNfts {},

    #[returns(NftContractAddrResponse)]
    GetNftContractAddr {},
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