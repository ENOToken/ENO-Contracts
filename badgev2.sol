// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Strings.sol";

// NO Whitelist
// NO Owner

contract ENOBadge is ERC721Enumerable, Ownable {
    uint256 public MAX_SUPPLY;
    uint256 public _tokenId = 1;
    string public _baseTokenURI;
    uint256 public maxPerWallet = 1;
    bool public transfersEnabled = false;

    mapping(address => uint256) private _whitelistQuota;

    constructor(uint256 maxSupply) ERC721("Badge Paris ENO", "PARISENO") {
        MAX_SUPPLY = maxSupply;
    }

    function mint(address to) public {

        if (msg.sender != owner()) {
            require(_whitelistQuota[msg.sender] > 0, "Quota exceeded");
            _whitelistQuota[msg.sender] -= 1;
        }

        require(_tokenId <= MAX_SUPPLY, "Max supply reached");
        
        _mint(to, _tokenId);
        _tokenId++;
    }

    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        
        if (bytes(_baseTokenURI).length > 0) {
            return string(abi.encodePacked(
                _baseTokenURI, 
                Strings.toString(tokenId), 
                ".json"
            ));
        }
        
        return "";
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

    function getWhitelistQuota(address account) public view returns (uint256) {
        return _whitelistQuota[account];
    }

    function toggleTransfers() public onlyOwner {
        transfersEnabled = !transfersEnabled;
    }

    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        MAX_SUPPLY = newMaxSupply;
    }

    function setMaxPerWallet(uint256 newMaxPerWallet) public onlyOwner {
        maxPerWallet = newMaxPerWallet;
    }
}