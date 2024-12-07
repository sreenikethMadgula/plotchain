// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LandNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;

    struct LandProperties {
        uint256 area; // in square meters
        string coordinates; // Latitude/Longitude or grid reference
        string zoning; // Residential, commercial, etc.
        uint256 valuation; // Appraised value
        string additionalInfo; // Optional metadata
    }

    mapping(uint256 => LandProperties) private landDetails;

    event LandMinted(
        uint256 indexed tokenId,
        address indexed to,
        uint256 area,
        string coordinates,
        string zoning,
        uint256 valuation,
        string additionalInfo
    );

    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC721(name, symbol) Ownable(initialOwner) {}

    function mintLand(
        address to,
        string memory tokenURI,
        uint256 area,
        string memory coordinates,
        string memory zoning,
        uint256 valuation,
        string memory additionalInfo
    ) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(bytes(tokenURI).length > 0, "Token URI required");
        require(area > 0, "Invalid area value");

        uint256 tokenId = nextTokenId;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        landDetails[tokenId] = LandProperties({
            area: area,
            coordinates: coordinates,
            zoning: zoning,
            valuation: valuation,
            additionalInfo: additionalInfo
        });

        emit LandMinted(tokenId, to, area, coordinates, zoning, valuation, additionalInfo);
        nextTokenId++;
    }

    function getLandDetails(uint256 tokenId) external view returns (LandProperties memory) {
        require(_exists(tokenId), "Token ID does not exist");
        return landDetails[tokenId];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
