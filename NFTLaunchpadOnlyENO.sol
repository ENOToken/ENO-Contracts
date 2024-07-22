// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

// Openzeppelin-v4.0.0
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/utils/SafeERC20.sol";

contract NFTENO is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeERC20 for IERC20;

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

    event MetadataURISet(string newURI);
    event NFTPriceSet(uint256 newPrice);
    event MaxSupplySet(uint256 newSupply);
    event NFTBoughtAndMinted(address indexed buyer, uint256 tokenId, uint256 price, uint256 commissionAmount, uint256 ownerAmount);

    constructor(address _commissionWallet, address _ownerWallet, address _enoTokenAddress, uint256 _saleStartTime, uint256 _maxMintsPerWallet, uint256 _maxSupply, uint256 _NFTPriceInENO, bool _sameMetadataForAll) ERC721("NFTENO", "NFTENO") Ownable() {
        require(_commissionWallet != address(0), "Commission wallet address cannot be zero");
        require(_ownerWallet != address(0), "Owner wallet address cannot be zero");
        require(_enoTokenAddress != address(0), "ENO token address cannot be zero");

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
        emit MetadataURISet(newURI);
    }

    function setNFTPriceInENO(uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "Price must be greater than zero");
        NFTPriceInENO = newPrice;
        emit NFTPriceSet(newPrice);
    }

    function setMaxSupply(uint256 newSupply) public onlyOwner {
        require(newSupply > max_supply, "New supply must be greater than the current supply");
        max_supply = newSupply;
        emit MaxSupplySet(newSupply);
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
        require(block.timestamp >= saleStartTime, "Sale has not started yet");
        require(NFTPriceInENO > 0, "NFT price must be greater than zero");
        require(_mintedCount[msg.sender] < maxMintsPerWallet, "Exceeds maximum NFTs");
        require(enoToken.transferFrom(msg.sender, address(this), NFTPriceInENO), "Failed to transfer ENO");

        uint256 commissionAmount = NFTPriceInENO * comision / 100;
        uint256 ownerAmount = NFTPriceInENO - commissionAmount;
        enoToken.safeTransfer(commissionWallet, commissionAmount);
        enoToken.safeTransfer(ownerWallet, ownerAmount);

        _mintedCount[msg.sender] += 1;
        uint256 newTokenId = _tokenId;
        mint(msg.sender);
        emit NFTBoughtAndMinted(msg.sender, newTokenId, NFTPriceInENO, commissionAmount, ownerAmount);
    }

    function mint(address to) internal {
        require(_tokenId <= max_supply, "Max supply reached");
        _mint(to, _tokenId);
        _tokenId++;
    }
}