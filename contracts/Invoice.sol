// SPDX-License-Identifier: GPL-3.0

/*
       /$$ /$$$$$$                               /$$                    
      | $$|_  $$_/                              |__/                    
  /$$$$$$$  | $$   /$$$$$$$  /$$    /$$ /$$$$$$  /$$  /$$$$$$$  /$$$$$$ 
 /$$__  $$  | $$  | $$__  $$|  $$  /$$//$$__  $$| $$ /$$_____/ /$$__  $$
| $$  | $$  | $$  | $$  \ $$ \  $$/$$/| $$  \ $$| $$| $$      | $$$$$$$$
| $$  | $$  | $$  | $$  | $$  \  $$$/ | $$  | $$| $$| $$      | $$_____/
|  $$$$$$$ /$$$$$$| $$  | $$   \  $/  |  $$$$$$/| $$|  $$$$$$$|  $$$$$$$
 \_______/|______/|__/  |__/    \_/    \______/ |__/ \_______/ \_______/
                                                                        
                                                                        
                                                                        
*/

pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Invoice is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _invoiceIds; // number of invoices created

    struct InvoiceDetails {
        uint256 invoiceId;
        string tokenURI;
        address payable seller;
        address payable client;
        uint256 startDate;
        uint256 endDate;
    }

    //TODO: Milestones should be inside of the InvoiceDetails struct so every invoice has it's own array of Milestones mapped to it only, will figure it out when I get back home
    struct Milestone {
        uint256 milestoneId;
        uint256 price;
        uint256 startDate;
        uint256 endDate;
    }

    mapping(uint256 => InvoiceDetails) internal idToInvoice; // invoice id => invoice details
    mapping(uint256 => address) internal idToClient; // invoice id => buyer address
    mapping(uint256 => address) internal idToSeller; // invoice id => seller address
    mapping(uint256 => mapping(uint256 => Milestone)) internal idToMilestone; // invoice id => (milestone id => milestone details)
    mapping(uint256 => Milestone) internal milestonesPerInvoice;

    event InvoiceCreated(
        uint256 indexed _invoiceId,
        string _tokenURI,
        address _seller,
        address _client,
        uint256 _startDate, // Epoch timestamp
        uint256 _endDate
    );

    event MilestoneAssigned(
        uint256 indexed _milestoneId,
        uint256 _price,
        uint256 _startDate,
        uint256 _endDate
    );

    function createInvoice(
        string memory _tokenURI,
        address _client,
        Milestone[] calldata _milestones, // why is it of "calldata" type?
        uint256 _startDate,
        uint256 _endDate
    ) public {
        // counter to keep track of invoice created in our contract
        _invoiceIds.increment();
        uint256 invoiceId = _invoiceIds.current();

        // creates an invoice instance
        idToInvoice[invoiceId] = InvoiceDetails(
            invoiceId,
            _tokenURI,
            payable(msg.sender),
            payable(_client),
            _startDate,
            _endDate
        );

        for (uint256 i = 0; i < _milestones.length; i++) {
            assignMilestone(
                invoiceId,
                _milestones[i].milestoneId,
                _milestones[i].price,
                _milestones[i].startDate,
                _milestones[i].endDate
            );
        }

        // store the address of the client
        idToClient[invoiceId] = _client;

        // store address of the seller
        idToSeller[invoiceId] = msg.sender;

        emit InvoiceCreated(
            invoiceId,
            _tokenURI,
            msg.sender,
            _client,
            _startDate,
            _endDate
        );
    }

    function assignMilestone(
        uint256 _invoiceId,
        uint256 _milestoneId,
        uint256 _price,
        uint256 _startDate,
        uint256 _endDate
    ) internal {
        idToMilestone[_invoiceId][_milestoneId] = Milestone(
            _milestoneId,
            _price,
            _startDate,
            _endDate
        );

        emit MilestoneAssigned(_milestoneId, _price, _startDate, _endDate);
    }

    function getTokenURI(uint256 _invoiceId)
        external
        view
        returns (string memory)
    {
        return idToInvoice[_invoiceId].tokenURI;
    }

    function getPricePerMilestone(uint256 _invoiceId, uint256 _milestoneId)
        public
        view
        returns (uint256)
    {
        return idToMilestone[_invoiceId][_milestoneId].price;
    }

    function getMilestoneDates(uint256 _invoiceId, uint256 _milestoneId)
        public
        view
        returns (uint256, uint256)
    {
        return (
            idToMilestone[_invoiceId][_milestoneId].startDate,
            idToMilestone[_invoiceId][_milestoneId].endDate
        );
    }

    function getMilestoneCount(uint256 _invoiceId)
        public
        view
        returns (uint256)
    {}

    function getClient(uint256 _invoiceId) public view returns (address) {
        return idToClient[_invoiceId];
    }

    function getSeller(uint256 _invoiceId) public view returns (address) {
        return idToSeller[_invoiceId];
    }
}
