// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract InvoiceNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address escrowContract;

    constructor(address _escrowContractAddress) ERC721("dInvoice Tokens", "DIT") {
        escrowContract = _escrowContractAddress;
    }

    function createToken(address _client, string memory _tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(_client, newItemId);
        _setTokenURI(newItemId, _tokenURI);

        return newItemId;
    }

}