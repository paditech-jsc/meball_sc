// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MeballNFT is ERC721, ERC721URIStorage, Ownable, EIP712 {
    struct MintRequest {
        address requester;
        string[] randomValues;
        uint256 nonce;
    }
    // Events
    event NFTMinted(Team nftType, address owner);

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
    uint256 public mintFee = 1 * 10 ** 18;
    uint8 constant NUM_TYPES = 24;
    uint8[NUM_TYPES] public probabilities;
    string[NUM_TYPES] public ipfsLinks;
    bytes32 private _TYPEHASH;
    address private contractSigner;

    constructor(
        uint8[NUM_TYPES] memory _probabilities,
        string[NUM_TYPES] memory _ipfsLinks
    ) ERC721("MeballNFT", "PBNFT") EIP712("MeballNFT", "1") {
        require(
            _probabilities.length == NUM_TYPES,
            "Invalid probabilities length"
        );
        require(_ipfsLinks.length == NUM_TYPES, "Invalid IPFS links length");

        probabilities = _probabilities;
        ipfsLinks = _ipfsLinks;
        _TYPEHASH = keccak256(
            "params(address _requester,string[] _randomValues,uint256 _nonce)"
        );
        contractSigner = msg.sender;
    }

    function mintNFTs(
        MintRequest calldata _req,
        bytes calldata _signature
    ) public payable onlySigner(getAddressWithSignature(_signature, _req)) {
        require(msg.value == mintFee, "Mint Fee not enough");
        require(!signaturesUsed[_signature], "Signature already used");
        signaturesUsed[_signature] = true;

        for (uint256 i = 0; i < _req.randomValues.length; i++) {
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
                    req.randomValues,
                    req.nonce
                )
            )
        );

        address signer = ECDSA.recover(digest, signature);
        console.log(signer);

        return signer;
    }

    function getRandomNFTType(
        uint256 randomNumber
    ) public view returns (Team team) {
        uint256 sum = 0;

        for (uint256 i = 0; i < NUM_TYPES; i++) {
            sum += probabilities[i];

            if (randomNumber < sum) {
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

    modifier onlySigner(address _signer) {
        require(contractSigner == _signer, "Not signer");
        _;
    }
}
