// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/Strings.sol";

contract BB11 is ERC721Enumerable, Ownable {
    uint256 public MAX_SUPPLY;
    uint256 public _tokenId = 1;
    string public _baseTokenURI;
    uint256 public maxPerWallet;
    bool public transfersEnabled = false;

    mapping(address => uint256) private _whitelistQuota;
    mapping(address => bool) private _whitelistedAddresses;

    constructor(uint256 maxSupply, uint256 _maxPerWallet) ERC721("Badge Blackbox 1.1", "BB1.1") {
        MAX_SUPPLY = maxSupply;
        maxPerWallet = _maxPerWallet;
    }

    function addToWhitelistBulk(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            if (!_whitelistedAddresses[accounts[i]]) {
                _whitelistQuota[accounts[i]] = maxPerWallet;
                _whitelistedAddresses[accounts[i]] = true;
            }
        }
    }

    function addToWhitelist(address account) public onlyOwner {
        if (!_whitelistedAddresses[account]) {
            _whitelistQuota[account] = maxPerWallet;
            _whitelistedAddresses[account] = true;
        }
    }

    function removeFromWhitelist(address account) public onlyOwner {
        _whitelistQuota[account] = 0;
        _whitelistedAddresses[account] = false;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelistedAddresses[account];
    }

    function mint(address to) public {

        if (msg.sender != owner()) {
            require(_whitelistedAddresses[msg.sender], "Not whitelisted");
            require(_whitelistQuota[msg.sender] > 0, "Quota exceeded");
            _whitelistQuota[msg.sender] -= 1;
        }

        require(_tokenId <= MAX_SUPPLY, "Max supply reached");
        require(to != address(0), "Cannot mint to the zero address");
        
        _mint(to, _tokenId);
        _tokenId++;
    }

    function mintBulk(address[] calldata recipients) public onlyOwner {
        require(_tokenId + recipients.length - 1 <= MAX_SUPPLY, "Max supply exceeded");
        
        for(uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot mint to the zero address");
            _mint(recipients[i], _tokenId++);
        }
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
