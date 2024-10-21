// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./NFTENOOnlyETH.sol";

/**
 * @title CustomNFTFactory
 * @notice This contract allows users to create their own CustomNFT contracts and keeps track of them
 * @dev Factory contract for deploying and managing CustomNFT contracts, optimized for minimal storage
 */
contract CustomNFTFactory {
    // Mapping of index to CustomNFT contract address
    mapping(uint256 => address) public createdNFTs;

    // Total number of created NFTs
    uint256 public totalNFTs;

    // Event emitted when a new CustomNFT contract is created
    event NFTCreated(address indexed creator, address indexed nftAddress, uint256 indexed index, string name, string symbol);

    /**
     * @notice Creates a new CustomNFT contract
     * @param _name Name of the NFT collection
     * @param _symbol Symbol of the NFT collection
     * @param _commissionWallet Address of the commission wallet
     * @param _ownerWallet Address of the owner wallet
     * @param _saleStartTime Timestamp when the sale starts
     * @param _maxMintsPerWallet Maximum mints allowed per wallet
     * @param _maxSupply Maximum supply of tokens
     * @param _NFTPriceInETH Price of each NFT in ETH
     * @param _sameMetadataForAll Indicates if the same metadata is used for all tokens
     * @param _commission Commission percentage for each sale
     * @return address The address of the newly created CustomNFT contract
     */
    function createNFT(
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
        address nftAddress = address(new CustomNFT(
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

        createdNFTs[totalNFTs] = nftAddress;
        
        emit NFTCreated(msg.sender, nftAddress, totalNFTs, _name, _symbol);
        
        totalNFTs++;

        return nftAddress;
    }

    /**
     * @notice Returns the number of CustomNFT contracts created
     * @return uint256 The total number of created CustomNFT contracts
     */
    function getNumberOfCreatedNFTs() external view returns (uint256) {
        return totalNFTs;
    }

    /**
     * @notice Returns a page of created CustomNFT contract addresses
     * @param offset The starting index
     * @param limit The maximum number of items to return
     * @return address[] An array of CustomNFT contract addresses
     */
    function getCreatedNFTsPaginated(uint256 offset, uint256 limit) external view returns (address[] memory) {
        require(offset < totalNFTs, "Offset out of bounds");
        
        uint256 endIndex = offset + limit;
        if (endIndex > totalNFTs) {
            endIndex = totalNFTs;
        }
        
        uint256 length = endIndex - offset;
        address[] memory result = new address[](length);
        
        for (uint256 i = 0; i < length; i++) {
            result[i] = createdNFTs[offset + i];
        }
        
        return result;
    }
}