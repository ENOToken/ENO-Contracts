// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./NFTENOOnlyETH.sol";

contract NFTENOFactory {
    mapping(uint256 => address) public createdNFTENOs;
    uint256 public totalNFTENOs;

    event NFTENOCreated(address indexed creator, address indexed nftAddress, uint256 indexed index, string name, string symbol);

    function createNFTENO(
        string memory _name,
        string memory _symbol,
        address _commissionWallet,
        address _ownerWallet,
        uint256 _saleStartTime,
        uint256 _maxMintsPerWallet,
        uint256 _maxSupply,
        uint256 _NFTPriceInETH,
        bool _sameMetadataForAll,
        uint256 _commission
    ) external returns (address) {
        address nftAddress = address(new NFTENO(
            _name,
            _symbol,
            _commissionWallet,
            _ownerWallet,
            _saleStartTime,
            _maxMintsPerWallet,
            _maxSupply,
            _NFTPriceInETH,
            _sameMetadataForAll,
            _commission
        ));

        createdNFTENOs[totalNFTENOs] = nftAddress;
        
        emit NFTENOCreated(msg.sender, nftAddress, totalNFTENOs, _name, _symbol);
        
        totalNFTENOs++;

        return nftAddress;
    }

    function getNumberOfCreatedNFTENOs() external view returns (uint256) {
        return totalNFTENOs;
    }

    function getCreatedNFTENOsPaginated(uint256 offset, uint256 limit) external view returns (address[] memory) {
        require(offset < totalNFTENOs, "Offset out of bounds");
        
        uint256 endIndex = offset + limit;
        if (endIndex > totalNFTENOs) {
            endIndex = totalNFTENOs;
        }
        
        uint256 length = endIndex - offset;
        address[] memory result = new address[](length);
        
        for (uint256 i = 0; i < length; i++) {
            result[i] = createdNFTENOs[offset + i];
        }
        
        return result;
    }
}