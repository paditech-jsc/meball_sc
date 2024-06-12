// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeballNFT is ERC721, ERC721URIStorage, Ownable, EIP712 {
    struct MintRequest {
        address requester;
        string[] randomValues;
        bytes32 hashRandomValues;
        uint256 nonce;
    }
    // Events
    event NFTMinted(Team nftType, address owner);
    event Withdraw(address owner, uint256 amount);

    enum Team {
        Germany,
        Scotland,
        Hungary,
        Switzerland,
        Spain,
        Croatia,
        Italia,
        Albania,
        Slovenia,
        England,
        Denmark,
        Serbia,
        Poland,
        Nertherland,
        Australia,
        France,
        Belgium,
        Slovakia,
        Romani,
        Ukraine,
        Czechia,
        Turkey,
        Portugal,
        Georgia
    }

    mapping(uint256 => Team) public tokenIdToTeam;
    mapping(address => mapping(Team => uint256)) public addressToTypeCount;
    mapping(bytes => bool) public signaturesUsed;

    uint256 public nextTokenId;
    uint256 public mintFee;
    uint8 constant NUM_TYPES = 24;
    uint8[NUM_TYPES] public cumulativeProbabilities;
    string[NUM_TYPES] public ipfsLinks;
    bytes32 private _TYPEHASH;
    address private contractSigner;

    constructor(
        uint8[NUM_TYPES] memory _probabilities,
        string[NUM_TYPES] memory _ipfsLinks,
        uint256 _mintFee,
        address _adminAddress
    ) ERC721("MeballNFT", "MBNFT") EIP712("MeballNFT", "1") {
        require(
            _probabilities.length == NUM_TYPES,
            "Invalid probabilities length"
        );
        require(_ipfsLinks.length == NUM_TYPES, "Invalid IPFS links length");

        mintFee = _mintFee;
        ipfsLinks = _ipfsLinks;

        _TYPEHASH = keccak256(
            "params(address _requester,bytes32 _hashRandomValues,uint256 _nonce)"
        );
        contractSigner = _adminAddress;

        uint8 sum = 0;
        for (uint8 i = 0; i < NUM_TYPES; i++) {
            sum += _probabilities[i];
            cumulativeProbabilities[i] = sum;
        }
    }

    function mintNFTs(
        MintRequest calldata _req,
        bytes calldata _signature
    )
        public
        payable
        onlyContractSigner(getAddressWithSignature(_signature, _req))
    {
        require(_req.randomValues.length > 0, "Invalid request");
        require(
            msg.value >= mintFee * _req.randomValues.length,
            "Mint Fee not enough"
        );
        require(!signaturesUsed[_signature], "Signature already used");
        signaturesUsed[_signature] = true;

        for (uint8 i = 0; i < _req.randomValues.length; i++) {
            bytes32 messageHash = keccak256(
                abi.encodePacked(_req.randomValues[i])
            );

            uint256 randomNumber = uint256(messageHash) % 100;
            Team nftType = getRandomNFTType(randomNumber);

            string memory tokenUri = getRandomizedTokenUri(uint256(nftType));

            _safeMint(msg.sender, nextTokenId);
            _setTokenURI(nextTokenId, tokenUri);

            tokenIdToTeam[nextTokenId] = nftType;
            addressToTypeCount[msg.sender][nftType]++;
            nextTokenId++;

            emit NFTMinted(nftType, msg.sender);
        }
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
        emit Withdraw(msg.sender, balance);
    }

    function changeOwner(address newOwner) external onlyOwner {
        transferOwnership(newOwner);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        _requireMinted(tokenId);
        return super.tokenURI(tokenId);
    }

    function getAddressWithSignature(
        bytes calldata signature,
        MintRequest calldata req
    ) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    _TYPEHASH,
                    req.requester,
                    req.hashRandomValues,
                    req.nonce
                )
            )
        );

        address signer = ECDSA.recover(digest, signature);

        return signer;
    }

    function getRandomNFTType(
        uint256 randomNumber
    ) public view returns (Team team) {
        for (uint256 i = 0; i < NUM_TYPES; i++) {
            if (randomNumber < cumulativeProbabilities[i]) {
                return Team(i);
            }
        }
        return Team(NUM_TYPES - 1);
    }

    function getRandomizedTokenUri(
        uint256 randomNum
    ) internal view returns (string memory uri) {
        return ipfsLinks[randomNum];
    }

    function getNFTType(uint256 tokenId) public view returns (Team) {
        return tokenIdToTeam[tokenId];
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    modifier onlyContractSigner(address _signer) {
        require(contractSigner == _signer, "Not signer");
        _;
    }
}
