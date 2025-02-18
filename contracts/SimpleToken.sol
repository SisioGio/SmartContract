// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenPreSale is ERC20, Ownable {
    bool public presaleIsActive;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public initialPrice;
    uint256 public regularSalePrice;
    
    uint256 public tokensSold;
    uint256 public preSaleSteps;
    uint256 public stakingRewardRate;
    uint256 public minUnstakingPeriod;
    uint256 public stakingRewardFrequency;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingTimestamp;
    mapping(address => bool) public whitelist;
    mapping(address => address) public referrals;
    mapping(address => uint256) public referralCounts;
    mapping(address => uint256) public balances;

    event UserWhitelisted(address indexed user, address indexed referral);
    event ReferralRewardMinted(address indexed referrer, uint256 rewardAmount);


    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount, uint256 reward);
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event PreSaleStarted(uint256 startTime, uint256 endTime);
    event PreSaleEnded(uint256 endTime);

    
    constructor(address initialOwner, uint256 totalSupply, uint256 _initialPrice, uint256 _regularSalePrice, uint256 _stakingRewardRate,uint256 _minUnstakingPeriod,uint256 _stakingRewardFrequency ) 
        ERC20("NatureToken", "NTR") 
        Ownable(initialOwner) 
    {
        _mint(address(this), totalSupply * 10 ** decimals());
        initialPrice = _initialPrice;
        regularSalePrice = _regularSalePrice;
        stakingRewardRate = _stakingRewardRate;
        presaleIsActive = false;
        minUnstakingPeriod  = _minUnstakingPeriod;
        stakingRewardFrequency = _stakingRewardFrequency;
    }

    

     function signUpForWhitelist(address referral) external {
        require(!whitelist[msg.sender], "Already whitelisted");
        require(msg.sender != referral, "Cannot refer yourself");
        
        whitelist[msg.sender] = true;
        
        if (referral != address(0) && whitelist[referral]) {
            referrals[msg.sender] = referral;
            referralCounts[referral] += 1;
        }
        
        emit UserWhitelisted(msg.sender, referral);
    }
    
    function calculateReferralReward() public view returns (uint256) {

        return referralCounts[msg.sender] * 500 * 10 ** decimals();
    }

    function mintReferralReward() external {
            require(presaleIsActive==true,"Presale not started yet");
            uint256 rewardAmount = calculateReferralReward();
            require(rewardAmount > 0, "No rewards available");
            _mint(msg.sender, rewardAmount);
            referralCounts[msg.sender] = 0;
            emit ReferralRewardMinted(msg.sender, rewardAmount);
        }

    /**
     * @notice Start the pre-sale
     */
    function startPreSale(uint256 _startTime, uint256 _endTime, uint256 steps) external onlyOwner {
        // require(_startTime >= block.timestamp, "Start time must be in the future");
        preSaleStartTime = _startTime;
        preSaleEndTime = _endTime;
        preSaleSteps = steps;
        
        presaleIsActive = true;
        emit PreSaleStarted(preSaleStartTime, preSaleEndTime);
    } 
    function calculateStepsElapsed(uint256 startTime, uint256 endTime) public view returns (uint256) {
            require(endTime >= startTime, "End time must be after start time");
            uint256 stepsElapsed = (endTime - startTime) / (preSaleEndTime-preSaleStartTime)/preSaleSteps; 
            return stepsElapsed;
        }
    function getCurrentStep() public view returns (uint256){
        require(block.timestamp >= preSaleStartTime, "End time must be after start time");
            uint256 stepsElapsed = (block.timestamp - preSaleStartTime) / (preSaleEndTime-preSaleStartTime)/preSaleSteps;
            return stepsElapsed;
    }
    function calculatePriceIncrease() public view returns (uint256){
        uint256 stepsElapsed =calculateStepsElapsed(preSaleStartTime, block.timestamp);
        uint256 priceIncrease = ((regularSalePrice - initialPrice) * stepsElapsed) / preSaleSteps;
        return priceIncrease;
    }


    
    function calculatePrice() public view returns (uint256) {
        require(presaleIsActive,"Pre-sale not started yet");
        if ( block.timestamp > preSaleEndTime) {
            return regularSalePrice;
        }

        uint256 priceIncrease = calculatePriceIncrease();
        uint256 currentPrice = initialPrice+priceIncrease;
        return currentPrice;
    }

    /**
    * @notice Buy tokens during the presale or regular sale.
    */
    function buyTokens() external payable {
        require(presaleIsActive, "Sale not active.");
        require(msg.value > 0, "Must send ETH to buy tokens.");

        uint256 currentPrice = calculatePrice(); // Call the calculatePrice function

        uint256 tokensToBuy = (msg.value) / currentPrice;
        require(balanceOf(address(this)) >= tokensToBuy, "Not enough tokens available.");
        balances[msg.sender] += tokensToBuy;
        _transfer(address(this), msg.sender, tokensToBuy);
        tokensSold += tokensToBuy;

        emit Transfer(address(this), msg.sender, tokensToBuy); // Emit transfer event
    }


    function getBalance() public view returns (uint256){
        return balanceOf(msg.sender);

    }

    function stakeTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero.");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance.");

        _transfer(msg.sender, address(this), amount);
        stakedAmount[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;
        emit TokensStaked(msg.sender, amount);
    }

    function unstakeTokens() external {
        uint256 amount = stakedAmount[msg.sender];
        require(amount > 0, "No tokens staked.");
        require(block.timestamp >= stakingTimestamp[msg.sender] + minUnstakingPeriod, "Unstake only after 4 weeks.");
        
        uint256 reward = calculateStakingReward();
        stakedAmount[msg.sender] = 0;
        stakingTimestamp[msg.sender] = 0;

        _transfer(address(this), msg.sender, amount + reward);
        emit TokensUnstaked(msg.sender, amount, reward);
    }

    function calculateStakingReward() public view returns (uint256) {
        uint256 periodsStaked = (block.timestamp - stakingTimestamp[msg.sender]) / stakingRewardFrequency;
        return (stakedAmount[msg.sender] * stakingRewardRate * periodsStaked) / 100;
    }

    function getStackedTokens() public view returns (uint256) {
            
            return stakedAmount[msg.sender];
    }

    function getStackingPeriod() public view returns (uint256) {
            
            return stakingTimestamp[msg.sender] + minUnstakingPeriod;
    }
}
