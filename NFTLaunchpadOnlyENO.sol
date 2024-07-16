// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

contract NFTENO is ERC721Enumerable, Ownable {
    uint256 public max_supply = 20;
    uint256 public NFTPriceInENO = 10000000000000000;
    uint256 private _tokenId = 1;
    uint256 public comision = 10;
    
    address public ownerWallet;
    address public commissionWallet;
    IERC20 public enoToken;
    mapping(address => uint256) private _mintedCount;
    
    uint256 public saleStartTime;
    uint256 public maxMintsPerWallet;

    constructor(
        address _commissionWallet,
        address _ownerWallet,
        address _enoTokenAddress,
        uint256 _saleStartTime,
        uint256 _maxMintsPerWallet
    ) ERC721("NFTENO", "NFTENO") Ownable() {
        commissionWallet = _commissionWallet;
        ownerWallet = _ownerWallet;
        enoToken = IERC20(_enoTokenAddress);
        saleStartTime = _saleStartTime;
        maxMintsPerWallet = _maxMintsPerWallet;
    }

    function setNFTPriceInENO(uint256 newPrice) public onlyOwner {
        NFTPriceInENO = newPrice; // Asume que ENO tiene 18 decimales
    }

    function setMaxSupply(uint256 newSupply) public onlyOwner {
        max_supply = newSupply;
    }

    function setComision(uint256 newComision) public onlyOwner {
        comision = newComision;
    }

    function setSaleStartTime(uint256 newStartTime) public onlyOwner {
        saleStartTime = newStartTime;
    }

    function setMaxMintsPerWallet(uint256 newMaxMints) public onlyOwner {
        maxMintsPerWallet = newMaxMints;
    }

    function buyNFTWithENO() public {
        require(block.timestamp >= saleStartTime, "Sale has not started yet"); // Verificar si la venta ha comenzado
        require(enoToken.transferFrom(msg.sender, address(this), NFTPriceInENO), "Failed to transfer ENO");
        require(_mintedCount[msg.sender] < maxMintsPerWallet, "Exceeds maximum NFTs");
        handlePayment(NFTPriceInENO);
        _mintedCount[msg.sender] += 1;
        mint(msg.sender);
    }

    function handlePayment(uint256 paymentAmount) internal {
        uint256 commissionAmount = paymentAmount * comision / 100;
        uint256 ownerAmount = paymentAmount - commissionAmount;

        require(enoToken.transfer(commissionWallet, commissionAmount), "Commission transfer failed");
        require(enoToken.transfer(ownerWallet, ownerAmount), "Owner transfer failed");
    }

    function mint(address to) internal {
        require(_tokenId <= max_supply, "Max supply reached");
        _mint(to, _tokenId);
        _tokenId++;
    }
}
