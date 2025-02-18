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
            10,            // weeklyIncreaseRate (10%)
            2e15,          // regularSalePrice (0.002 ETH)
            5              // stakingRewardRate (5%)
        );
        currentTimestamp = block.timestamp;
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }

    function checkSuccess() public {
        uint256 supply = tokenPreSale.totalSupply();
        Assert.equal(supply, 1000000 * 10 ** tokenPreSale.decimals(), "Total supply should match");
       
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
        uint256 startTime = currentTimestamp + 1 days; // 1 day in the future
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime, durationWeeks);

        bool presaleStarted = tokenPreSale.presaleIsActive();
        Assert.equal(true,presaleStarted, "Presale should be active");
        
    }

       
  // Test: Ensure calculatePrice reverts if pre-sale has not started
    function testCalculatePricePreSaleNotStarted() public {
        // Set a future start time
        uint256 startTime = currentTimestamp + 1 days;  // 1 day in the future
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        tokenPreSale.startPreSale(startTime, durationWeeks);

        // Set the current time before the presale starts
        uint256 price;
        bool success;
        bytes memory result;
        
        (success, result) = address(tokenPreSale).call(abi.encodeWithSignature("calculatePrice()"));

        Assert.equal(success, false, "Pre-sale has not started yet, should revert.");
    }
// Test: Ensure calculateWeeks returns the correct number of weeks
    function testCalculateWeeks() public {
        uint256 startTime = currentTimestamp - 100 days; // 100 days ago

        // Calculate the number of weeks that have passed since startTime
        uint256 weeksElapsed = (currentTimestamp - startTime) / 1 weeks;

        // Since 100 days is roughly 14 weeks (100 / 7 = 14), we expect weeksElapsed to be 14
        uint256 expectedWeeks = 14; // 100 days = 14 weeks

        // Assert that the number of weeks is correctly calculated
        Assert.equal(weeksElapsed, expectedWeeks, "The calculated weeks should be 14.");
    }


// Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
    function testCalculatePricePreSaleEnded() public {
        uint256 startTime = currentTimestamp - 100 days;   // 10 days in the past, presale should have ended
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        tokenPreSale.startPreSale(startTime, durationWeeks);

        // Set the current time to after the presale
        
        // uint256 price = 2e15;
        uint256 price;
        bool success;
        bytes memory result;
        (success, result) = address(tokenPreSale).call(abi.encodeWithSignature("calculatePrice()"));
        // Ensure the call was successful
        Assert.equal(success, true, "Call to calculatePrice should be successful.");

        // Decode the result (uint256 price)
        price = abi.decode(result, (uint256));
        // Set the current time to 3 days after the presale started
        uint256 elapsedWeeks = (block.timestamp - startTime) / 1 weeks;
        uint256 expectedPrice = tokenPreSale.initialPrice() + ((tokenPreSale.regularSalePrice() - tokenPreSale.initialPrice()) * elapsedWeeks) / durationWeeks;

        // Assert that the calculated price is correct
        Assert.equal(price, expectedPrice, "Price during presale should be correctly calculated.");
    }
}
    