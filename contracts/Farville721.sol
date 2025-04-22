// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.11;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title FarvilleOG NFT Contract
/// @notice This contract implements the FarvilleOG NFT collection with merkle proof verification
/// @dev Extends ERC721Royalty and Ownable for NFT functionality with royalties
/// @dev Implements MerkleProof for merkle proof verification of whitelisted addresses when minting
contract FarvilleOG is ERC721Royalty, Ownable, Pausable {
    /// @notice Error thrown when attempting to mint an already minted token
    error TokenAlreadyMinted();
    /// @notice Error thrown when attempting to mint an already minted address
    error AddressAlreadyMinted();
    /// @notice Error thrown when merkle root is not set
    error InvalidMerkleRoot();
    /// @notice Error thrown when merkle proof verification fails
    error InvalidMerkleProof();

    /// @notice The merkle root used for validating mint eligibility
    /// @dev Immutable value set during contract deployment
    bytes32 private merkleRoot;

    /// @notice The base URI for token metadata
    /// @dev Immutable value set during contract deployment
    string public baseURI;

    /// @notice Mapping to track which token IDs have been minted
    /// @dev Maps token ID to minting status
    mapping(uint256 => bool) public minted;

    /// @notice Mapping to track which addresses have minted
    /// @dev Maps address to minting status
    mapping(address => bool) public hasMinted;
    
    /// @notice Initializes the FarvilleOG NFT contract
    /// @dev Sets up the NFT collection with royalty information and merkle root
    /// @param initialOwner Address of the contract owner
    /// @param royaltyRecipient Address to receive royalty payments
    /// @param royaltyFee The royalty fee in basis points (e.g., 250 = 2.5%)
    /// @param _merkleRoot The merkle root for validating mint eligibility
    /// @param _baseUri The base URI for token metadata
    constructor(address initialOwner, address royaltyRecipient, uint96 royaltyFee, bytes32 _merkleRoot, string memory _baseUri)
        ERC721("FarvilleOG", "FOG")
        Ownable(initialOwner)
    {
        if (_merkleRoot == bytes32(0)) revert InvalidMerkleRoot();
        _setDefaultRoyalty(royaltyRecipient, royaltyFee);
        merkleRoot = _merkleRoot;
        baseURI = _baseUri;
    }

    /// @notice Sets the base URI for token metadata
    /// @dev Only the contract owner can set the URI
    /// @param newURI The new base URI to set
    function setURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
    }

    /// @notice Sets the merkle root for validating mint eligibility
    /// @dev Only the contract owner can set the merkle root
    /// @param newMerkleRoot The new merkle root to set
    function setMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        if (newMerkleRoot == bytes32(0)) revert InvalidMerkleRoot();
        merkleRoot = newMerkleRoot;
    }

    /// @notice Pauses all token minting
    /// @dev Only the contract owner can pause
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses all token minting
    /// @dev Only the contract owner can unpause
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Mints a new FarvilleOG NFT
    /// @dev Verifies merkle proof before minting
    /// @param tokenId The ID of the token to mint
    /// @param proof The merkle proof to verify eligibility
    function mint(uint256 tokenId, bytes32[] calldata proof) external whenNotPaused {
        if (minted[tokenId]) revert TokenAlreadyMinted();
        if (hasMinted[msg.sender]) revert AddressAlreadyMinted();
        // Compute the leaf node 
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, tokenId))));
        // Verify the proof
        if (!MerkleProof.verify(proof, merkleRoot, leaf)) revert InvalidMerkleProof();
        // Mark the token ID as minted
        minted[tokenId] = true;
        // Mark the address as minted
        hasMinted[msg.sender] = true;
        // Mint the NFT
        _safeMint(msg.sender, tokenId);
    }

    /// @notice Returns the base URI for token metadata
    /// @dev Override of the ERC721 _baseURI function
    /// @return Base URI string
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @notice Returns the token URI for a given token ID
    /// @dev Override of the ERC721 tokenURI function
    /// @param tokenId The ID of the token to get the URI for
    /// @return Token URI string
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return baseURI;
    }
}