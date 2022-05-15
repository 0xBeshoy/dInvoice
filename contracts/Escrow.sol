//SPDX-License-Identifier: GPL

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

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    constructor() payable {}

    /*=============================================== All Methods ===============================================*/

    function getInvoiceDetails() public {}

    function getMyInvoices() public {}

    function setInvoiceComplete() public {}

    /*========================================= Buyer or Seller Methods =========================================*/

    function createInvoice() public {}

    function acceptTerms() public {}

    function updateTerms() public {}

    function setMilestones() public {}

    function addMilestone() public {}

    function updateMilestone() public {}

    function raiseDispute() public {}

    function setInvoiceTerms() public {}

    function disputeWithdraw() public {}

    /*=========================================== Buyer Only Methods ===========================================*/

    function buyerFundInvoice() public {}

    function buyerAddMoreFunds() public {}

    /*=========================================== Seller Only Methods ===========================================*/

    function sellerRequestFunds() public {}

    function sellerWithdraw() public {}

    /*============================================== Admin Methods ==============================================*/

    /// @notice Function should allow buyer or admin to approve contract competition
    function adminApproveInvoice() private {}

    function adminSetDispute(bool state) private {}

    function adminSetFees() private {}

    function adminSetGracePeriod() private {}

    function adminGetAllInvoices() private {}

    function adminWithdraw() private {}

    /*============================================== Contract Methods ==============================================*/

    function createInvoiceNFT() internal {}

    function setInvoiceRewards() internal {}

    function transferTRewards() internal {}
}
