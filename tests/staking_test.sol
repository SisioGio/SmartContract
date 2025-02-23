// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

import "remix_accounts.sol";
// <import file to test>
import "../contracts/SimpleToken.sol";
// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TokenPreSale token;
    address acc1;
    address acc2;
    uint256 minStakingAmount = 100; // Adjust based on your contract
    
    


    function beforeAll() public {
        acc1 = TestsAccounts.getAccount(1); // Get test account-1
        acc2 = TestsAccounts.getAccount(2); // Get test account-2


        token = new TokenPreSale(
            address(this), // initialOwner
            1000000,       // totalSupply
            1e15,          // initialPrice (0.001 ETH)
            2e15,          // regularSalePrice (0.002 ETH)
            5,             // stakingRewardRate (5%)
            60*60*24*30,            // _minUnstakingPeriod
            60*60*24*1,          //_stakingRewardFrequency
            1000, // White list capacity
            5, // whiteListDiscount
            1, //_minTokensToBuy
            minStakingAmount //_minStakingAmount

        );

        
    
    }

   
    
  function stakingNotPossibleWithoutTokens() public {
        bytes memory methodSign = abi.encodeWithSignature("stakeTokens(uint256)", 200);
        (bool success, bytes memory data) = address(token).call(methodSign);

        Assert.equal(success, false, "Staking should fail when rewards are empty");

    }

    function preSaleActivation() public {
        uint256 startTime = block.timestamp ;
        uint256 endTime = block.timestamp +60 minutes;
        uint256 steps = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        token.startPreSale(startTime,endTime,steps);

        bool presaleStarted = token.presaleIsActive();
        Assert.equal(true,presaleStarted, "Presale should be active");

    }
    /// #sender: account-1
    /// #value: 5000000000000000
    function preSaleBuyTokens() public payable {
        Assert.equal(msg.value,5000000000000000,"Msg value should match");

        uint256 tokensToBuy = token.getTokensToBuy(msg.value);

        Assert.equal(tokensToBuy,5,"Tokens to buy sould be 5");
        token.buyTokens();

        
        uint256 currBalance = token.getBalance();
        uint256 expBalance = 5;
        Assert.equal(expBalance, currBalance, "Buy action should be possible");

    }


   


}
    