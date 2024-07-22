// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Openzeppelin-v4.0.0
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/security/ReentrancyGuard.sol";

/// @title NewENOBadge
/// @notice This contract implements a new ERC721 badge with enumerable, ownable, and reentrancy guard features.
/// @dev Inherits from ERC721Enumerable, Ownable, and ReentrancyGuard.
contract NewENOBadge is ERC721Enumerable, Ownable, ReentrancyGuard {
    /// @notice Maximum supply of tokens that can be minted.
    uint256 public MAX_SUPPLY;
    /// @notice ID for the next token to be minted.
    uint256 public _tokenId = 1;
    /// @notice Common URI for all tokens.
    string public _commonURI;
    /// @notice Indicates if transfers are enabled.
    bool public transfersEnabled = false;

    /// @notice Mapping to track the number of tokens minted by each address.
    mapping(address => uint256) private _mintedCount;

    /// @notice Timestamp when the sale starts.
    uint256 public saleStartTime;

    /// @notice Emitted when a token is minted.
    /// @param to Address to which the token is minted.
    /// @param tokenId ID of the minted token.
    event Minted(address indexed to, uint256 tokenId);
    /// @notice Emitted when the sale start time is set.
    /// @param newStartTime New start time for the sale.
    event SaleStartTimeSet(uint256 newStartTime);
    /// @notice Emitted when the common URI is set.
    /// @param newURI New common URI.
    event CommonURISet(string newURI);
    /// @notice Emitted when transfers are toggled.
    /// @param enabled Indicates if transfers are enabled.
    event TransfersToggled(bool enabled);
    /// @notice Emitted when the maximum supply is set.
    /// @param newMaxSupply New maximum supply.
    event MaxSupplySet(uint256 newMaxSupply);

    /// @notice Constructor to initialize the contract with a name, symbol, maximum supply, and sale start time.
    /// @param name Name of the token.
    /// @param symbol Symbol of the token.
    /// @param maxSupply Maximum supply of tokens.
    /// @param _saleStartTime Timestamp when the sale starts.
    constructor(string memory name, string memory symbol, uint256 maxSupply, uint256 _saleStartTime) ERC721(name, symbol) {
        MAX_SUPPLY = maxSupply;
        saleStartTime = _saleStartTime;
    }

    /// @notice Function to mint a new token.
    /// @param to Address to which the token is minted.
    /// @dev Requires the sale to have started and the maximum supply not to be exceeded.
    function mint(address to) public nonReentrant {
        require(block.timestamp >= saleStartTime, "Sale has not started yet");
        require(_tokenId <= MAX_SUPPLY, "Max supply reached");
        require(_mintedCount[msg.sender] < 1, "Each address may only mint one NFT");

        _mintedCount[msg.sender] += 1;
        _mint(to, _tokenId);
        emit Minted(to, _tokenId);
        _tokenId++;
    }

    /// @notice Function to set the sale start time.
    /// @param newStartTime New start time for the sale.
    /// @dev Requires the new start time to be in the future.
    function setSaleStartTime(uint256 newStartTime) public onlyOwner {
        require(newStartTime > block.timestamp, "New start time must be in the future");
        saleStartTime = newStartTime;
        emit SaleStartTimeSet(newStartTime);
    }

    /// @notice Function to set the common URI.
    /// @param newURI New common URI.
    /// @dev Requires the new URI to be non-empty.
    function setCommonURI(string memory newURI) public onlyOwner {
        require(bytes(newURI).length > 0, "URI cannot be empty");
        _commonURI = newURI;
        emit CommonURISet(newURI);
    }

    /// @notice Function to get the URI of a token.
    /// @param tokenId ID of the token.
    /// @return string Common URI of the token.
    /// @dev Requires the token to exist.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _commonURI;
    }

    /// @notice Function to transfer a token from one address to another.
    /// @param from Address from which the token is transferred.
    /// @param to Address to which the token is transferred.
    /// @param tokenId ID of the token to be transferred.
    /// @dev Requires transfers to be enabled for non-owner accounts.
    function transferFrom(address from, address to, uint256 tokenId) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.transferFrom(from, to, tokenId);
    }

    /// @notice Function to safely transfer a token from one address to another.
    /// @param from Address from which the token is transferred.
    /// @param to Address to which the token is transferred.
    /// @param tokenId ID of the token to be transferred.
    /// @dev Requires transfers to be enabled for non-owner accounts.
    function safeTransferFrom(address from, address to, uint256 tokenId) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.safeTransferFrom(from, to, tokenId);
    }

    /// @notice Function to safely transfer a token from one address to another with additional data.
    /// @param from Address from which the token is transferred.
    /// @param to Address to which the token is transferred.
    /// @param tokenId ID of the token to be transferred.
    /// @param _data Additional data.
    /// @dev Requires transfers to be enabled for non-owner accounts.
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    /// @notice Function to toggle the transfer state.
    /// @dev Can only be called by the owner.
    function toggleTransfers() public onlyOwner {
        transfersEnabled = !transfersEnabled;
        emit TransfersToggled(transfersEnabled);
    }

    /// @notice Function to set the maximum supply of tokens.
    /// @param newMaxSupply New maximum supply of tokens.
    /// @dev Requires the new maximum supply to be greater than the current maximum supply.
    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply > MAX_SUPPLY, "New max supply must be greater than current max supply");
        MAX_SUPPLY = newMaxSupply;
        emit MaxSupplySet(newMaxSupply);
    }
}