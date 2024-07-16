// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/security/ReentrancyGuard.sol";

contract NFTENO is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public max_supply;
    uint256 public NFTPriceInENO;
    uint256 private _tokenId = 1;
    uint256 public comision = 10;
    
    address public ownerWallet;
    address public commissionWallet;
    IERC20 public enoToken;
    mapping(address => uint256) private _mintedCount;
    
    uint256 public saleStartTime;
    uint256 public maxMintsPerWallet;

    bool public sameMetadataForAll;
    string public baseURI;
    string public commonMetadataURI;

    constructor(
        address _commissionWallet,
        address _ownerWallet,
        address _enoTokenAddress,
        uint256 _saleStartTime,
        uint256 _maxMintsPerWallet,
        uint256 _maxSupply,
        uint256 _NFTPriceInENO,
        bool _sameMetadataForAll
    ) ERC721("NFTENO", "NFTENO") Ownable() {
        commissionWallet = _commissionWallet;
        ownerWallet = _ownerWallet;
        enoToken = IERC20(_enoTokenAddress);
        saleStartTime = _saleStartTime;
        maxMintsPerWallet = _maxMintsPerWallet;
        max_supply = _maxSupply;
        NFTPriceInENO = _NFTPriceInENO;
        sameMetadataForAll = _sameMetadataForAll;
    }

    function setMetadataURI(string memory newURI) public onlyOwner {
        if (sameMetadataForAll) {
            commonMetadataURI = newURI;
        } else {
            baseURI = newURI;
        }
    }

    function setNFTPriceInENO(uint256 newPrice) public onlyOwner {
        NFTPriceInENO = newPrice; // Asume que ENO tiene 18 decimales
    }

    function setMaxSupply(uint256 newSupply) public onlyOwner {
        require(newSupply > max_supply, "New supply must be greater than the current supply");
        max_supply = newSupply; // Solo se puede aumentar, no disminuir
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if (sameMetadataForAll) {
            return commonMetadataURI;
        } else {
            return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
        }
    }

    function buyNFTWithENO() public nonReentrant {
        require(block.timestamp >= saleStartTime, "Sale has not started yet"); // Verificar si la venta ha comenzado
        require(enoToken.transferFrom(msg.sender, address(this), NFTPriceInENO), "Failed to transfer ENO");
        require(_mintedCount[msg.sender] < maxMintsPerWallet, "Exceeds maximum NFTs");

        uint256 commissionAmount = NFTPriceInENO * comision / 100;
        uint256 ownerAmount = NFTPriceInENO - commissionAmount;
        require(enoToken.transfer(commissionWallet, commissionAmount), "Commission transfer failed");
        require(enoToken.transfer(ownerWallet, ownerAmount), "Owner transfer failed");
 
        _mintedCount[msg.sender] += 1;
        mint(msg.sender);
    }

    function mint(address to) internal {
        require(_tokenId <= max_supply, "Max supply reached");
        _mint(to, _tokenId);
        _tokenId++;
    }
}