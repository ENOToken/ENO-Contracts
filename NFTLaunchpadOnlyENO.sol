// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

contract NFTENO is ERC721Enumerable, Ownable {
    uint256 public max_supply = 20;
    uint256 public NFTPriceInENO = 10000000000000000; // Precio del NFT en subunidades de ENO (0.01 ENO asumido con 18 decimales)
    uint256 private _tokenId = 1;
    uint256 public comision = 10;
    
    address public ownerWallet;
    address public commissionWallet;
    IERC20 public enoToken;
    
    uint256 public saleStartTime; // Timestamp para el inicio de la venta

    constructor(
        address _commissionWallet,
        address _ownerWallet,
        address _enoTokenAddress,
        uint256 _saleStartTime // Parámetro para establecer la fecha de inicio en el constructor
    ) ERC721("NFTENO", "NFTENO") Ownable() {
        commissionWallet = _commissionWallet;
        ownerWallet = _ownerWallet;
        enoToken = IERC20(_enoTokenAddress); // Inicializar el contrato ENO
        saleStartTime = _saleStartTime; // Establecer la fecha de inicio
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

    function buyNFTWithENO() public {
        require(block.timestamp >= saleStartTime, "Sale has not started yet"); // Verificar si la venta ha comenzado
        require(enoToken.transferFrom(msg.sender, address(this), NFTPriceInENO), "Failed to transfer ENO");
        handlePayment(NFTPriceInENO);
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
