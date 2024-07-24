// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
 *
 *  /$$$$$$$$ /$$   /$$  /$$$$$$  /$$$$$$$$ /$$$$$$  /$$   /$$ /$$$$$$$$ /$$   /$$     /$$$$$$  /$$$$$$ 
 * | $$_____/| $$$ | $$ /$$__  $$|__  $$__//$$__  $$| $$  /$$/| $$_____/| $$$ | $$    |_  $$_/ /$$__  $$
 * | $$      | $$$$| $$| $$  \ $$   | $$  | $$  \ $$| $$ /$$/ | $$      | $$$$| $$      | $$  | $$  \ $$
 * | $$$$$   | $$ $$ $$| $$  | $$   | $$  | $$  | $$| $$$$$/  | $$$$$   | $$ $$ $$      | $$  | $$  | $$
 * | $$__/   | $$  $$$$| $$  | $$   | $$  | $$  | $$| $$  $$  | $$__/   | $$  $$$$      | $$  | $$  | $$
 * | $$      | $$\  $$$| $$  | $$   | $$  | $$  | $$| $$\  $$ | $$      | $$\  $$$      | $$  | $$  | $$
 * | $$$$$$$$| $$ \  $$|  $$$$$$/   | $$  |  $$$$$$/| $$ \  $$| $$$$$$$$| $$ \  $$ /$$ /$$$$$$|  $$$$$$/
 * |________/|__/  \__/ \______/    |__/   \______/ |__/  \__/|________/|__/  \__/|__/|______/ \______/ 
 *
 * @title Launchpad
 * @notice This contract represents a launchpad for NFTs that can be bought using ENO tokens.
 * @dev Implements ERC721 tokens and uses ERC20 tokens for purchasing NFTs.
 * @web https://enotoken.io/
 * @author Juan José de la Rosa | ENO CTO
 * @link https://www.linkedin.com/in/juan-jose-de-la-rosa/
 *
 */    

// Openzeppelin-v4.0.0
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title NFTENO
/// @notice This contract implements an ERC721 token that can be bought with an ERC20 token (ENO).
/// @dev Inherits from ERC721Enumerable, Ownable, and ReentrancyGuard.
contract NFTENO is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    /// @notice Maximum supply of tokens that can be minted.
    uint256 public max_supply;
    /// @notice Price of each NFT in ENO tokens.
    uint256 public NFTPriceInENO;
    /// @notice ID for the next token to be minted.
    uint256 private _tokenId = 1;

    /// @notice Address of the owner wallet.
    address public immutable ownerWallet;
    /// @notice Address of the commission wallet.
    address public immutable commissionWallet;
    /// @notice Instance of the ENO token.
    IERC20 public immutable enoToken;
    /// @notice Mapping to track the number of tokens minted by each address.
    mapping(address => uint256) private _mintedCount;

    /// @notice Timestamp when the sale starts.
    uint256 public immutable saleStartTime;
    /// @notice Maximum number of mints allowed per wallet.
    uint256 public immutable maxMintsPerWallet;

    /// @notice Indicates if the same metadata is used for all tokens.
    bool public immutable sameMetadataForAll;
    /// @notice Commission percentage for each sale.
    uint256 public immutable comision;
    /// @notice Base URI for token metadata.
    string public baseURI;
    /// @notice Common metadata URI for all tokens.
    string public commonMetadataURI;

    /// @notice Emitted when the metadata URI is set.
    /// @param newURI New metadata URI.
    event MetadataURISet(string newURI);
    /// @notice Emitted when the NFT price in ENO is set.
    /// @param newPrice New price for the NFT in ENO.
    event NFTPriceSet(uint256 newPrice);
    /// @notice Emitted when the maximum supply is set.
    /// @param newSupply New maximum supply.
    event MaxSupplySet(uint256 newSupply);
    /// @notice Emitted when an NFT is bought and minted.
    /// @param buyer Address of the buyer.
    /// @param tokenId ID of the minted token.
    /// @param price Price paid in ENO.
    /// @param commissionAmount Commission amount in ENO.
    /// @param ownerAmount Amount sent to the owner wallet in ENO.
    event NFTBoughtAndMinted(address indexed buyer, uint256 tokenId, uint256 price, uint256 commissionAmount, uint256 ownerAmount);

    /// @notice Constructor to initialize the contract with required parameters.
    /// @param _commissionWallet Address of the commission wallet.
    /// @param _ownerWallet Address of the owner wallet.
    /// @param _enoTokenAddress Address of the ENO token contract.
    /// @param _saleStartTime Timestamp when the sale starts.
    /// @param _maxMintsPerWallet Maximum mints allowed per wallet.
    /// @param _maxSupply Maximum supply of tokens.
    /// @param _NFTPriceInENO Price of each NFT in ENO.
    /// @param _sameMetadataForAll Indicates if the same metadata is used for all tokens.
    /// @param _comision Commission percentage for each sale.
    constructor(
        address _commissionWallet,
        address _ownerWallet,
        address _enoTokenAddress,
        uint256 _saleStartTime,
        uint256 _maxMintsPerWallet,
        uint256 _maxSupply,
        uint256 _NFTPriceInENO,
        bool _sameMetadataForAll,
        uint256 _comision
    ) ERC721("NFTENO", "NFTENO") Ownable() {
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
        comision = _comision;
    }

    /// @notice Function to set the metadata URI.
    /// @param newURI New metadata URI.
    /// @dev If sameMetadataForAll is true, sets commonMetadataURI, otherwise sets baseURI.
    function setMetadataURI(string memory newURI) public onlyOwner {
        require(block.timestamp < saleStartTime, "Cannot set metadata URI");
        if (sameMetadataForAll) {
            commonMetadataURI = newURI;
        } else {
            baseURI = newURI;
        }
        emit MetadataURISet(newURI);
    }

    /// @notice Function to get the URI of a token.
    /// @param tokenId ID of the token.
    /// @return string URI of the token metadata.
    /// @dev Requires the token to exist.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if (sameMetadataForAll) {
            return commonMetadataURI;
        } else {
            return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
        }
    }

    /// @notice Function to buy an NFT with ENO tokens.
    /// @dev Transfers ENO from the buyer to the contract, then mints a new NFT.
    function buyNFTWithENO() public nonReentrant {
        require(block.timestamp >= saleStartTime, "Sale has not started yet");
        
        uint256 price = NFTPriceInENO;
        require(price > 0, "NFT price must be greater than zero");

        uint256 mintedCount = _mintedCount[msg.sender];
        require(mintedCount < maxMintsPerWallet, "Exceeds maximum NFTs");

        _mintedCount[msg.sender] = mintedCount + 1;
        require(enoToken.transferFrom(msg.sender, address(this), price), "Failed to transfer ENO");

        uint256 commissionAmount = price * comision / 100;
        uint256 ownerAmount = price - commissionAmount;
        enoToken.safeTransfer(commissionWallet, commissionAmount);
        enoToken.safeTransfer(ownerWallet, ownerAmount);

        uint256 newTokenId = _tokenId;
        require(newTokenId <= max_supply, "Max supply reached");
        _mint(msg.sender, newTokenId);
        _tokenId++;

        emit NFTBoughtAndMinted(msg.sender, newTokenId, price, commissionAmount, ownerAmount);
    }

}