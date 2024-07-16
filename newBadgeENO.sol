// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/security/ReentrancyGuard.sol";

contract NewENOBadge is ERC721Enumerable, Ownable, ReentrancyGuard {
    uint256 public MAX_SUPPLY;
    uint256 public _tokenId = 1;
    string public _commonURI;
    bool public transfersEnabled = false;

    mapping(address => uint256) private _mintedCount;

    uint256 public saleStartTime; // Timestamp para el inicio de la venta

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 _saleStartTime // Parámetro para establecer la fecha de inicio en el constructor
    ) ERC721(name, symbol) {
        MAX_SUPPLY = maxSupply;
        saleStartTime = _saleStartTime; // Establecer la fecha de inicio
    }

    function mint(address to) public nonReentrant {
        require(block.timestamp >= saleStartTime, "Sale has not started yet"); // Verificar si la venta ha comenzado
        require(_tokenId <= MAX_SUPPLY, "Max supply reached");
        require(_mintedCount[msg.sender] < 1, "Each address may only mint one NFT");

        _mintedCount[msg.sender] += 1;
        _mint(to, _tokenId);
        _tokenId++;
    }

    function setSaleStartTime(uint256 newStartTime) public onlyOwner {
        saleStartTime = newStartTime;
    }

    function setCommonURI(string memory newURI) public onlyOwner {
        _commonURI = newURI; 
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _commonURI; 
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override (ERC721, IERC721) {
        if (from != owner()) {
            require(transfersEnabled, "Transfers are currently disabled for non-owner accounts.");
        }
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function toggleTransfers() public onlyOwner {
        transfersEnabled = !transfersEnabled;
    }

    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply > MAX_SUPPLY, "New max supply must be greater than current max supply");
        MAX_SUPPLY = newMaxSupply;
    }
}
