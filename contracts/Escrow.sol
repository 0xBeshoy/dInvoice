// SPDX-License-Identifier: GPL-3.0

/*
       /$$ /$$$$$$                               /$$                           /$$$$$$$$                                                      
      | $$|_  $$_/                              |__/                          | $$_____/                                                      
  /$$$$$$$  | $$   /$$$$$$$  /$$    /$$ /$$$$$$  /$$  /$$$$$$$  /$$$$$$       | $$        /$$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$  /$$  /$$  /$$
 /$$__  $$  | $$  | $$__  $$|  $$  /$$//$$__  $$| $$ /$$_____/ /$$__  $$      | $$$$$    /$$_____/ /$$_____/ /$$__  $$ /$$__  $$| $$ | $$ | $$
| $$  | $$  | $$  | $$  \ $$ \  $$/$$/| $$  \ $$| $$| $$      | $$$$$$$$      | $$__/   |  $$$$$$ | $$      | $$  \__/| $$  \ $$| $$ | $$ | $$
| $$  | $$  | $$  | $$  | $$  \  $$$/ | $$  | $$| $$| $$      | $$_____/      | $$       \____  $$| $$      | $$      | $$  | $$| $$ | $$ | $$
|  $$$$$$$ /$$$$$$| $$  | $$   \  $/  |  $$$$$$/| $$|  $$$$$$$|  $$$$$$$      | $$$$$$$$ /$$$$$$$/|  $$$$$$$| $$      |  $$$$$$/|  $$$$$/$$$$/
 \_______/|______/|__/  |__/    \_/    \______/ |__/ \_______/ \_______/      |________/|_______/  \_______/|__/       \______/  \_____/\___/ 
                                                                                                                                              
                                                                                                                                              
                                                                                                                                                                                                                                                                                            
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "./InvoiceNFT.sol";
// import "./Invoice.sol";

contract Escrow is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _invoiceIds; // number of invoices created

    bool public initialized;
    InvoiceNFT public invoiceNFT;
    Invoice public invoice;

    mapping(uint256 => uint256) balancesOfBuyers; // token id => amount escrowed
    mapping(uint256 => uint256) balancesOfSellers; // token id => amount to be redeemed
    mapping(uint256 => bool) approvals; // token id => withdrawl approval by admin

    event Escrowed(
        address _buyer, 
        address _seller, 
        uint256 _tokenId, 
        uint256 _amount
    );

    event Released(
        uint256 _tokenId,
        uint256 _milestoneId,
        address _buyer,
        uint256 _balance,
        uint256 _price
    );

    event Redeemed(
        uint256 _tokenId,
        uint256 _milestoneId,
        address _seller,
        uint256 _balance,
        uint256 _price
    );

    event WithdrawlApproved(uint256 _tokenId);

    event WithdrewAllETH(
        uint256 _tokenId,
        address _buyer,
        uint256 _balance,
        bool _isSuccessful
    );

    modifier isInitialized() {
        require(initialized, "Contract is not yet initialized");
        _;
    }

    modifier isSeller(address _seller, uint256 _id) {
        require(_seller == invoice.getSeller(_id), "Must be the registered seller under the project." );
        _;
    }

    function initialize(address _invoiceNFTContractAddress, address _invoiceContractAddress) external onlyOwner {
        /** 
            instead of using a constructor, 
            the contract owner can invoke the initialize function
            ref: https://soliditydeveloper.com/design-pattern-solidity-initialize-contract-after-deployment
        */
        invoiceNFT = InvoiceNFT(_invoiceNFTContractAddress);
        invoice = Invoice(_invoiceContractAddress);
        initialized = true;
    }

    function escrowToken(address _seller, uint256 _invoiceId, uint256 _amount) external payable isInitialized nonReentrant {
        require(_seller != address(0), "Cannot escrow to zero address.");
        require(msg.value > 0, "Cannot escrow 0 ETH.");
        require(msg.value > _amount, "Please deposit a sufficient amount.");

        string memory uri = invoice.getTokenURI(_invoiceId);

        uint256 tokenId = invoiceNFT.createToken(msg.sender, uri);

        balancesOfBuyers[tokenId] = msg.value;

        emit Escrowed(
            msg.sender,
            _seller,
            tokenId,
            _amount
        );
    }

    /// @dev releasing ETH also means the approval of the client
    function releaseETH(uint256 _tokenId, uint256 _milestoneId) public isInitialized {
        require(invoiceNFT.ownerOf(_tokenId) == msg.sender, "Must own token to release the funds.");

        uint256 price = invoice.getPricePerMilestone(_tokenId, _milestoneId);

        require(balancesOfBuyers[_tokenId] >= price, "Must have a sufficient balance.");

        balancesOfSellers[_tokenId] += price; // add to seller
        balancesOfBuyers[_tokenId] -= price; // deduct from buyer

        emit Released(
            _tokenId,
            _milestoneId,
            msg.sender,
            balancesOfBuyers[_tokenId],
            price
        );
    }

    function reedemETHPerMilestone(uint256 _tokenId, uint256 _milestoneId) public isInitialized isSeller(msg.sender, _tokenId) {
        (uint256 startDate, uint256 endDate) = invoice.getMilestoneDates(_tokenId, _milestoneId);

        require(endDate < block.timestamp, "Can't redeem ETH before the registered end date.");
        require(balancesOfSellers[_tokenId] > 0, "Can't redeem ETH from an empty balance.");

        uint256 price = invoice.getPricePerMilestone(_tokenId, _milestoneId);

        balancesOfSellers[_tokenId] -= price; // deduct amount from balance

        (bool success, ) = msg.sender.call{value: price}("");

        emit Redeemed(
            _tokenId,
            _milestoneId,
            msg.sender,
            balancesOfSellers[_tokenId],
            price
        );
    }

    function approveWithdrawl(uint256 _tokenId) public onlyOwner {
        approvals[_tokenId] = true;

        emit WithdrawlApproved(_tokenId);
    }
    
    function withdrawETH(uint256 _tokenId) public isInitialized {
        require(invoiceNFT.ownerOf(_tokenId) == msg.sender, "Must own token to withdraw the funds.");
        require(approvals[_tokenId], "Must get admin approval to withdraw.");
        require(balancesOfBuyers[_tokenId] > 0, "Can't withdraw ETH from an empty balance.");

        // 1. retrieve current balance
        uint256 amount = balancesOfBuyers[_tokenId];

        // 2. clear the balance
        balancesOfBuyers[_tokenId] = 0;

        // 3. transfer the amount
        (bool success, ) = msg.sender.call{value: amount}("");

        emit WithdrewAllETH(
            _tokenId,
            msg.sender,
            balancesOfBuyers[_tokenId],
            success
        );
    }

} 