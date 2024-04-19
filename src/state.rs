use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use cosmwasm_std::Addr;
use cw_storage_plus::Item;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Eq, JsonSchema)]
pub struct State {
    pub owner: Addr,
}

pub const STATE: Item<State> = Item::new("state");
pub const NFTS: Item<Vec<String>> = Item::new("nfts");
pub const NFT_CONTRACT_ADDR: Item<Addr> = Item::new("nft_contract_addr");
