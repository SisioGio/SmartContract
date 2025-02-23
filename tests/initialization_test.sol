// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

import "remix_accounts.sol";
// <import file to test>
import "../contracts/SimpleToken.sol";
// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TokenPreSale tokenPreSale;
    address buyer = address(0x123);
    uint256 currentTimestamp;


    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        tokenPreSale = new TokenPreSale(
            address(this), // initialOwner
            1000000,       // totalSupply
            1e15,          // initialPrice (0.001 ETH)
            2e15,          // regularSalePrice (0.002 ETH)
            5,             // stakingRewardRate (5%)
            60*60*24*30,            // _minUnstakingPeriod
            60*60*24*1,          //_stakingRewardFrequency
            1000, // White list capacity
            5, // whiteListDiscount
            500, //_minTokensToBuy
            10000 //_minStakingAmount


        );
        currentTimestamp = block.timestamp;
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }

    function checkSuccess() public {
        uint256 supply = tokenPreSale.totalSupply();
        Assert.equal(supply, 1000000, "Total supply should match");
       
    }
    function checkPresaleStartedIsFalse() public {

        bool presaleStarted = tokenPreSale.presaleIsActive();
        Assert.equal(false,presaleStarted, "Presale should be active");
        
    }

    // Test: Ensure user can't buy before presale starts
    function checkIfUserCanBuyBeforePreSale() public {
        uint256 balanceBefore = tokenPreSale.balanceOf(buyer);

        // Attempt to buy before presale starts (should fail)
        (bool success, ) = address(tokenPreSale).call{value: 1 ether}(abi.encodeWithSignature("buyTokens()"));
        Assert.equal(success, false, "Presale not active, purchase should fail");

        uint256 balanceAfter = tokenPreSale.balanceOf(buyer);
        Assert.equal(balanceBefore, balanceAfter, "Buyer balance should not change before presale starts");
    }

    
  function checkPreSaleActivation() public {
        uint256 startTime = currentTimestamp; // 1 day in the future
        uint256 endTime = currentTimestamp + 4 days;
        uint256 steps = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime,endTime,steps);

        bool presaleStarted = tokenPreSale.presaleIsActive();
        Assert.equal(true,presaleStarted, "Presale should be active");
        
    }


}
    