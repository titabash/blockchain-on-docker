// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721PresetMinterPauserAutoId {
    constructor()
        public
        ERC721PresetMinterPauserAutoId(
            "NFTSample",
            "NFT",
            "http://127.0.0.1:8006/"
        )
    {}
}
