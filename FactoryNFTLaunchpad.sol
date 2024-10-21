// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./NFTENOOnlyETH.sol";

/**
 * @title NFTENOFactory
 * @notice This contract allows users to create their own NFTENO contracts and keeps track of them
 * @dev Factory contract for deploying and managing NFTENO contracts, optimized for minimal storage
 */
contract NFTENOFactory {
    // Mapping of index to NFTENO contract address
    mapping(uint256 => address) public createdNFTENOs;

    // Total number of created NFTENOs
    uint256 public totalNFTENOs;

    // Event emitted when a new NFTENO contract is created
    event NFTENOCreated(address indexed creator, address indexed nftAddress, uint256 indexed index);

    /**
     * @notice Creates a new NFTENO contract
     * @param _commissionWallet Address of the commission wallet
     * @param _ownerWallet Address of the owner wallet
     * @param _saleStartTime Timestamp when the sale starts
     * @param _maxMintsPerWallet Maximum mints allowed per wallet
     * @param _maxSupply Maximum supply of tokens
     * @param _NFTPriceInETH Price of each NFT in ETH
     * @param _sameMetadataForAll Indicates if the same metadata is used for all tokens
     * @param _commission Commission percentage for each sale
     * @return address The address of the newly created NFTENO contract
     */
    function createNFTENO(
        address _commissionWallet,
        address _ownerWallet,
        uint256 _saleStartTime,
        uint256 _maxMintsPerWallet,
        uint256 _maxSupply,
        uint256 _NFTPriceInETH,
        bool _sameMetadataForAll,
        uint256 _commission
    ) external returns (address) {
        NFTENO newNFTENO = new NFTENO(
            _commissionWallet,
            _ownerWallet,
            _saleStartTime,
            _maxMintsPerWallet,
            _maxSupply,
            _NFTPriceInETH,
            _sameMetadataForAll,
            _commission
        );

        address nftAddress = address(newNFTENO);
        uint256 index = totalNFTENOs;

        createdNFTENOs[index] = nftAddress;
        totalNFTENOs++;

        emit NFTENOCreated(msg.sender, nftAddress, index);

        return nftAddress;
    }

    /**
     * @notice Returns the number of NFTENO contracts created
     * @return uint256 The total number of created NFTENO contracts
     */
    function getNumberOfCreatedNFTENOs() external view returns (uint256) {
        return totalNFTENOs;
    }

    /**
     * @notice Returns a page of created NFTENO contract addresses
     * @param offset The starting index
     * @param limit The maximum number of items to return
     * @return address[] An array of NFTENO contract addresses
     */
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