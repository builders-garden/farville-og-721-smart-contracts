# FarvilleOG NFT Contract

This project is FarvilleOG NFT collection, a smart contract built on the ERC721 standard with additional features for security and functionality.

## Features

- ERC721 NFT implementation
- Royalty support through ERC721Royalty
- Merkle proof verification for minting eligibility
- One mint per address limit

## Merkle Proof Whitelist

The FarvilleOG NFT uses a Merkle tree for efficient and secure whitelisting of eligible minters. Each leaf in the Merkle tree is created by hashing the combination of a user's address and their designated token ID. This ensures that specific addresses can only mint specific tokens.

### How it works:

1. A Merkle tree is generated off-chain with leaves containing `keccak256(abi.encode(address, tokenId))`
2. The Merkle root is stored in the contract during deployment
3. During minting, users must provide:
   - The desired token ID
   - A valid Merkle proof

The contract verifies the proof by:

- Computing the leaf node from the sender's address and token ID
- Validating the provided proof against the stored Merkle root
- Only allowing the mint if the proof is valid

This system provides:

- Gas-efficient verification of whitelist eligibility
- Cryptographic proof of mint eligibility
- Ability to whitelist specific token IDs for specific addresses
- Protection against unauthorized minting

## Development

This project uses Hardhat for development and testing. Here are the available commands:

```shell
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Run local node
npx hardhat node

# Deploy contract
npx hardhat run scripts/deploy.js --network <network-name>
```

## Contract Deployment

The contract requires the following parameters for deployment:

- `initialOwner`: Address of the contract owner
- `royaltyRecipient`: Address to receive royalty payments
- `royaltyFee`: Royalty fee in basis points (e.g., 250 = 2.5%)
- `merkleRoot`: Merkle root for validating mint eligibility
- `baseUri`: Base URI for token metadata

## Security Features

- Pausable functionality for emergency situations
- Merkle proof verification for controlled minting
- Owner-only administrative functions
- Prevention of double minting
- Standardized access control

## License

This project is licensed under the MIT License.
