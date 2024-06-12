// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MeballStake is
    Initializable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    IERC20Metadata stakingToken;
    IERC20Metadata rewardToken;

    struct Stake {
        uint256 amount;
        uint256 stakedAt;
    }

    // Mapping from user to season to Stake
    mapping(address => mapping(uint256 => Stake)) public stakeInfos;
    mapping(address => mapping(uint256 => uint256)) public rewardAmounts;

    // ******** //
    //  EVENTS  //
    // ******** //

    event TokensStaked(
        address indexed owner,
        uint256 amount,
        uint256 timestamp,
        uint256 season
    );
    event TokensUnstaked(
        address indexed owner,
        uint256 amount,
        uint256 timestamp,
        uint256 season
    );
    event Claimed(address indexed owner, uint256 reward);
    event Retrieved(address indexed owner, uint256 claimable, uint256 season);
    event RewardCreated(
        address indexed recipient,
        uint256 reward,
        uint256 season
    );
    event EmergencyWithdraw(address indexed owner, uint256 amount);

    // ******** //
    //  ERRORS  //
    // ******** //

    error InsufficientBalance();
    error NothingStaked();
    error NothingToUnstake();
    error NothingToClaim();
    error InvalidSeason();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _stakingToken,
        address _rewardToken
    ) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        stakingToken = IERC20Metadata(_stakingToken);
        rewardToken = IERC20Metadata(_rewardToken);
    }

    function stake(uint256 amount, uint256 _season) external {
        if (amount == 0) revert InsufficientBalance();
        if (stakingToken.balanceOf(msg.sender) < amount)
            revert InsufficientBalance();

        Stake storage userStake = stakeInfos[msg.sender][_season];
        userStake.amount += amount;
        userStake.stakedAt = block.timestamp;

        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit TokensStaked(msg.sender, amount, block.timestamp, _season);
    }

    function createReward(
        address[] calldata stakers,
        uint256[] calldata rewards,
        uint256 _season
    ) external onlyOwner {
        require(stakers.length == rewards.length, "Length mismatch");

        for (uint256 i = 0; i < rewards.length; i++) {
            address who = stakers[i];
            _setReward(who, rewards[i], _season);
        }
    }

    function addReward(
        address[] calldata stakers,
        uint256[] calldata rewards,
        uint256 _season
    ) external onlyOwner {
        require(stakers.length == rewards.length, "Length mismatch");

        for (uint256 i = 0; i < rewards.length; i++) {
            address who = stakers[i];
            _addReward(who, rewards[i], _season);
        }
    }

    function claim(uint256 _season) external nonReentrant {
        Stake storage userStake = stakeInfos[msg.sender][_season];
        if (userStake.amount == 0) revert NothingStaked();

        uint256 claimable = rewardAmounts[msg.sender][_season];
        if (claimable == 0) revert NothingToClaim();

        _processPayment(msg.sender, claimable);
        rewardAmounts[msg.sender][_season] = 0;
        emit Retrieved(msg.sender, claimable, _season);
    }

    function setRewardToken(IERC20Metadata _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
    }

    function _setReward(
        address staker,
        uint256 reward,
        uint256 _season
    ) private {
        require(staker != address(0), "Staker cannot be zero address");
        require(staker != address(this), "Cannot reward for self");
        require(reward != 0, "Reward cannot be zero");

        rewardAmounts[staker][_season] = reward * 10 ** rewardToken.decimals();
        emit RewardCreated(staker, reward, _season);
    }

    function _addReward(
        address staker,
        uint256 reward,
        uint256 _season
    ) private {
        require(staker != address(0), "Staker cannot be zero address");
        require(staker != address(this), "Cannot reward for self");
        require(reward != 0, "Reward cannot be zero");

        rewardAmounts[staker][_season] += reward * 10 ** rewardToken.decimals();
        emit RewardCreated(staker, reward, _season);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance > 0, "No reward tokens to withdraw");

        bool success = rewardToken.transfer(msg.sender, balance);
        require(success, "Transfer failed");

        emit EmergencyWithdraw(msg.sender, balance);
    }

    function _processPayment(address to, uint256 amount) internal {
        if (amount == 0) return;
        bool success = rewardToken.transfer(to, amount);
        require(success, "Transfer failed");
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
