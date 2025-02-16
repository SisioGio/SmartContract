// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenPreSale is ERC20, Ownable {
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public initialPrice;       // Initial price per token in Wei
    uint256 public regularSalePrice;
    uint256 public weeklyIncreaseRate; // Weekly price increase percentage (e.g., 10 means 10%)
    uint256 public tokensSold;

    uint256 public stakingRewardRate;  // Annual staking reward rate in percentage
    mapping(address => uint256) public stakedAmount;  // Amount of tokens staked by each user
    mapping(address => uint256) public stakingTimestamp;  // Timestamp when user staked
    mapping(address => uint256) public stakingRewards;  // Rewards accumulated by users
    
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event SaleStarted(uint256 startTime, uint256 endTime);
    event SaleEnded(uint256 endTime);
    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount, uint256 reward);

    constructor(address initialOwner, uint256 totalSupply, uint256 _initialPrice, uint256 _weeklyIncreaseRate, uint256 _regularSalePrice, uint256 _stakingRewardRate) 
    ERC20("NatureToken", "NTR") 
    Ownable(initialOwner) 
    {
        _mint(address(this), totalSupply * 10 ** decimals()); // Mint specified total supply to the contract
        initialPrice = _initialPrice;
        weeklyIncreaseRate = _weeklyIncreaseRate;
        regularSalePrice = _regularSalePrice;  // Set the regular sale price
        stakingRewardRate = _stakingRewardRate; // Set the weekly staking reward rate
    }

    // Other functions (startSale, getCurrentPrice, buyTokens, etc.) remain the same

    /**
     * @notice Stake tokens in the contract for rewards
     * @param amount Number of tokens to stake
     */
    function stakeTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero.");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to stake.");

        // Transfer the tokens from the user to the contract
        _transfer(msg.sender, address(this), amount);

        // Update staking information
        stakedAmount[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;

        emit TokensStaked(msg.sender, amount);
    }

    /**
 * @notice Unstake tokens and receive accumulated rewards. Users are only allowed to unstake after 4 weeks.
 */
    function unstakeTokens() external {
        uint256 stakedTokens = stakedAmount[msg.sender];
        require(stakedTokens > 0, "No tokens staked.");

        uint256 timeStaked = block.timestamp - stakingTimestamp[msg.sender];
        uint256 stakingDurationInWeeks = timeStaked / 1 weeks; // Calculate staking duration in weeks
        
        // Ensure the user has staked for at least 4 weeks
        require(stakingDurationInWeeks >= 4, "Tokens can only be unstaked after 4 weeks.");

        // Calculate staking rewards
        uint256 reward = calculateStakingReward(msg.sender);

        // Update staked amount to 0
        stakedAmount[msg.sender] = 0;
        stakingTimestamp[msg.sender] = 0;

        // Transfer staked tokens and rewards back to the user
        _transfer(address(this), msg.sender, stakedTokens + reward);

        emit TokensUnstaked(msg.sender, stakedTokens, reward);
    }

    /**
     * @notice Calculate the staking rewards for a user based on the staked amount and time staked (in weeks)
     * @param user Address of the user
     * @return The reward amount
     */
    function calculateStakingReward(address user) public view returns (uint256) {
        uint256 stakedTokens = stakedAmount[user];
        if (stakedTokens == 0) {
            return 0;
        }

        uint256 timeStaked = block.timestamp - stakingTimestamp[user];
        uint256 stakingDurationInWeeks = timeStaked / 1 weeks; // Calculate duration in weeks

        // Reward = staked amount * staking reward rate * time staked (in weeks)
        uint256 reward = (stakedTokens * stakingRewardRate * stakingDurationInWeeks) / 100;
        return reward;
    }

    /**
     * @notice Set the staking reward rate (only callable by the owner)
     * @param _rewardRate The new annual staking reward rate
     */
    function setStakingRewardRate(uint256 _rewardRate) external onlyOwner {
        stakingRewardRate = _rewardRate;
    }
    /**
 * @notice Get the staked balance of a user
 * @param user Address of the user
 * @return The amount of tokens staked by the user
 */
function getStakedBalance(address user) external view returns (uint256) {
    return stakedAmount[user];
}

/**
 * @notice Get the staking start date (timestamp) for a user
 * @param user Address of the user
 * @return The timestamp when the user started staking
 */
function getStakingStartDate(address user) external view returns (uint256) {
    return stakingTimestamp[user];
}

/**
 * @notice Get the accumulated rewards for a user based on the duration of staking
 * @param user Address of the user
 * @return The accumulated staking rewards
 */
function getAccumulatedRewards(address user) external view returns (uint256) {
    return calculateStakingReward(user);
}
    // Emergency functions (withdrawFunds, recoverERC20) remain the same
}
