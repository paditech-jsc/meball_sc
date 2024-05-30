// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract ProbabilityBasedNFT is
    ERC721,
    ERC721URIStorage,
    Ownable,
    RrpRequesterV0
{
    // Events
    event RequestedRandomNumber(
        address indexed sender,
        bytes32 indexed requestId,
        uint256 numberOfNFTs
    );
    event NFTMinted(uint256 indexed tokenId, Team nftType, address owner);

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
        Netherlands,
        Australia,
        France,
        Belgium,
        Slovakia,
        Romania,
        Ukraine,
        Czechia,
        Turkey,
        Portugal,
        Georgia
    }

    address public airnode; /// The address of the QRNG Airnode
    bytes32 public endpointIdUint256Array; /// The endpoint ID for requesting an array of random numbers
    address public sponsorWallet; /// The wallet that will cover the gas costs of the request

    uint256 public nextTokenId;
    uint256 public mintFee = 1 * 10 ** 18;
    uint8 constant NUM_TYPES = 24;

    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;
    mapping(bytes32 => address) public requestToSender;
    mapping(bytes32 => uint256) public requestToNFTCount;
    mapping(uint256 => Team) public tokenIdToTeam;
    mapping(address => mapping(Team => uint256)) public addressToTypeCount;

    uint8[NUM_TYPES] public probabilities;
    string[NUM_TYPES] public ipfsLinks;

    constructor(
        uint8[NUM_TYPES] memory _probabilities,
        string[NUM_TYPES] memory _ipfsLinks,
        address _airnodeRrp
    ) ERC721("ProbabilityBasedNFT", "PBNFT") RrpRequesterV0(_airnodeRrp) {
        require(
            _probabilities.length == NUM_TYPES,
            "Invalid probabilities length"
        );
        require(_ipfsLinks.length == NUM_TYPES, "Invalid IPFS links length");

        probabilities = _probabilities;
        ipfsLinks = _ipfsLinks;
    }

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256Array,
        address _sponsorWallet
    ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256Array = _endpointIdUint256Array;
        sponsorWallet = _sponsorWallet;
    }

    function requestRandomNFTs(
        uint256 numberOfNFTs
    ) public payable returns (bytes32) {
        require(msg.value == mintFee * numberOfNFTs, "Mint Fee not enough");

        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256Array,
            address(this),
            sponsorWallet,
            address(this),
            this.generateNFTs.selector,
            abi.encode(bytes32("1u"), bytes32("size"), numberOfNFTs)
        );

        expectingRequestWithIdToBeFulfilled[requestId] = true;
        requestToSender[requestId] = msg.sender;
        requestToNFTCount[requestId] = numberOfNFTs;

        emit RequestedRandomNumber(msg.sender, requestId, numberOfNFTs);
        return requestId;
    }

    function generateNFTs(
        bytes32 requestId,
        bytes calldata data
    ) public onlyAirnodeRrp {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );

        expectingRequestWithIdToBeFulfilled[requestId] = false;
        address nftOwner = requestToSender[requestId];
        uint256 numberOfNFTs = requestToNFTCount[requestId];

        uint256[] memory randomNumbers = abi.decode(data, (uint256[]));

        for (uint256 i = 0; i < numberOfNFTs; i++) {
            uint256 newItemId = nextTokenId;
            uint256 qrngUint256 = randomNumbers[i];

            Team nftType = getRandomNFTType(qrngUint256);
            string memory tokenUri = getRandomizedTokenUri(uint256(nftType));

            _safeMint(nftOwner, newItemId);
            _setTokenURI(newItemId, tokenUri);

            tokenIdToTeam[newItemId] = nftType;
            addressToTypeCount[nftOwner][nftType]++;
            nextTokenId++;

            emit NFTMinted(newItemId, nftType, nftOwner);
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
}
