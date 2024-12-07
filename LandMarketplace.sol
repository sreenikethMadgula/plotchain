// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LandNFT.sol";

contract LandMarketplace {
    struct Sale {
        address seller;
        uint256 price;
        address buyer;
        bool isApprovedByGovernment;
    }

    LandNFT public landNFTContract;
    address public government;
    mapping(uint256 => Sale) public sales;

    event LandListed(uint256 indexed tokenId, address seller, uint256 price);
    event SaleApproved(uint256 indexed tokenId, address buyer, address government);
    event SaleCompleted(uint256 indexed tokenId, address buyer, address seller, uint256 price);

    constructor(address _landNFTContract, address _government) {
        landNFTContract = LandNFT(_landNFTContract);
        government = _government;
    }

    modifier onlyGovernment() {
        require(msg.sender == government, "Only the government can approve this");
        _;
    }

    function listLand(uint256 tokenId, uint256 price) public {
        require(landNFTContract.ownerOf(tokenId) == msg.sender, "You do not own this land");
        sales[tokenId] = Sale(msg.sender, price, address(0), false);
        emit LandListed(tokenId, msg.sender, price);
    }

    function buyLand(uint256 tokenId) public payable {
        Sale storage sale = sales[tokenId];
        require(msg.value == sale.price, "Incorrect price sent");
        require(sale.seller != address(0), "Land not for sale");
        require(sale.buyer == address(0), "Already has a buyer");

        sale.buyer = msg.sender;
    }

    function approveSale(uint256 tokenId) public onlyGovernment {
        Sale storage sale = sales[tokenId];
        require(sale.buyer != address(0), "No buyer yet");
        sale.isApprovedByGovernment = true;

        emit SaleApproved(tokenId, sale.buyer, msg.sender);
    }

    function completeSale(uint256 tokenId) public {
        Sale storage sale = sales[tokenId];
        require(sale.isApprovedByGovernment, "Sale not approved by government");

        address seller = sale.seller;
        address buyer = sale.buyer;

        // Transfer ownership of the NFT
        landNFTContract.transferFrom(seller, buyer, tokenId);

        // Transfer funds to the seller
        payable(seller).transfer(sale.price);

        delete sales[tokenId]; // Remove the sale record

        emit SaleCompleted(tokenId, buyer, seller, sale.price);
    }
}
