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
            60*60*24*1          //_stakingRewardFrequency

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

       
//   // Test: Ensure calculatePrice reverts if pre-sale has not started
//     function testCalculatePricePreSaleNotStarted() public {
//         // Set a future start time
//         uint256 startTime = currentTimestamp + 1 days;  // 1 day in the future
//         uint256 durationWeeks = 4;  // Presale duration of 4 weeks
//         tokenPreSale.startPreSale(startTime, durationWeeks);


//         uint256 contractPreSale = tokenPreSale.preSaleStartTime();
//         Assert.equal(contractPreSale,startTime,"Start time should match");


//         // Set the current time before the presale starts
//         uint256 price;
//         bool success;
//         bytes memory result;
        
//         (success, result) = address(tokenPreSale).call(abi.encodeWithSignature("calculatePrice()"));

//         Assert.equal(success, false, "Pre-sale has not started yet, should revert.");
//     }
// Test: Ensure calculateWeeks returns the correct number of weeks
    function testCalculateWeeks() public {
        uint256 startTime = currentTimestamp; // 100 days ago
        uint256 endTime = currentTimestamp+ 1 hours; // 100 days ago
        // Calculate the number of weeks that have passed since startTime
        uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);

        // Since 100 days is roughly 14 weeks (100 / 7 = 14), we expect weeksElapsed to be 14
        uint256 expectedSteps = 1; // 100 days = 14 weeks

        // Assert that the number of weeks is correctly calculated
        Assert.equal(stepsElapsed, expectedSteps, "The calculated weeks should be 1.");
    }

// Test: Ensure calculateWeeks returns the correct number of weeks
    function testCalculateWeeks2() public {
        uint256 startTime = currentTimestamp - 2 days;
        uint256 endTime = currentTimestamp; 
        uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
        uint256 expectedSteps = 2; 
        Assert.equal(stepsElapsed, expectedSteps, "The calculated steps should be 2.");
    }

    // Test: Ensure calculateWeeks returns the correct number of weeks
    function testCalculateWeeks0() public {
        uint256 startTime = currentTimestamp - 3 days; 
        uint256 endTime = currentTimestamp;
        uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
        uint256 expectedSteps = 0;

        // Assert that the number of weeks is correctly calculated
        Assert.equal(stepsElapsed, expectedSteps, "The calculated weeks should be 2.");
    }

    // Test: Ensure calculateWeeks returns the correct number of weeks
    function testCalculateWeeks3() public {
        uint256 startTime = currentTimestamp - 4 days;
        uint256 endTime = currentTimestamp; 
        uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
        uint256 expectedSteps = 4;
        Assert.equal(stepsElapsed, expectedSteps, "The calculated weeks should be 2.");
    }

// Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
    function testCalculatedPriceIncreaseAtWeek0() public {
        uint256 startTime = currentTimestamp - 5 days;
        uint256 endTime = currentTimestamp -1;
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        
        tokenPreSale.startPreSale(startTime, endTime);
        uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
        uint256 expectedPriceIncrease = 0;

        Assert.equal(expectedPriceIncrease, calculatedPriceIncrease, "Price increase during first week should be 0");
    }

    // Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
    function testCalculatedPriceIncreaseAtWeek2() public {
        uint256 startTime = currentTimestamp - 16 days;   // 10 days in the past, presale should have ended
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        uint256 endTime = startTime + (durationWeeks * 1 weeks);
        tokenPreSale.startPreSale(startTime, durationWeeks);
        uint256 preSalePrice = tokenPreSale.initialPrice();
        uint256 regularPrice  =tokenPreSale.regularSalePrice();
        uint256 contractPreSaleStart  = tokenPreSale.preSaleStartTime();
        uint256 contractPreSaleEnd = tokenPreSale.preSaleEndTime();
        uint256 preSaleWeeks = tokenPreSale.preSaleWeeksInWeeks();

        Assert.equal(startTime,contractPreSaleStart,"contractPreSaleStart should match");
        Assert.equal(endTime,contractPreSaleEnd,"contractPreSaleEnd should match");
        Assert.equal(preSalePrice,1e15,"preSalePrice should match");
        Assert.equal(regularPrice,2e15,"regularPrice should match");
        Assert.equal(preSaleWeeks,durationWeeks,"preSaleWeeks should match");


        uint256 weeksElapsed = tokenPreSale.calculateWeeksElapsed(startTime,currentTimestamp);
        Assert.equal(weeksElapsed,2,"weeksElapsed should be 2");

        uint256 priceIncrease = (regularPrice-preSalePrice)/durationWeeks*weeksElapsed;
        uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
        Assert.equal(priceIncrease,calculatedPriceIncrease,"price increase should be 0.5e15");
        uint256 calculatedPrice = tokenPreSale.calculatePrice();
        // uint256 calculatedPrice = 1.5e15;
        uint256 expectedPrice = preSalePrice + priceIncrease;
        Assert.equal(expectedPrice,calculatedPrice,"price  should be 1.5e15");

    }


     // Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
    function testCalculatedPriceIncreaseAtWeek3() public {
        uint256 startTime = currentTimestamp - 24 days;   // 10 days in the past, presale should have ended
        uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        uint256 endTime = startTime + (durationWeeks * 1 weeks);
        tokenPreSale.startPreSale(startTime, durationWeeks);
        uint256 preSalePrice = tokenPreSale.initialPrice();
        uint256 regularPrice  =tokenPreSale.regularSalePrice();
        uint256 contractPreSaleStart  = tokenPreSale.preSaleStartTime();
        uint256 contractPreSaleEnd = tokenPreSale.preSaleEndTime();
        uint256 preSaleWeeks = tokenPreSale.preSaleWeeksInWeeks();

        Assert.equal(startTime,contractPreSaleStart,"contractPreSaleStart should match");
        Assert.equal(endTime,contractPreSaleEnd,"contractPreSaleEnd should match");
        Assert.equal(preSalePrice,1e15,"preSalePrice should match");
        Assert.equal(regularPrice,2e15,"regularPrice should match");
        Assert.equal(preSaleWeeks,durationWeeks,"preSaleWeeks should match");


        uint256 weeksElapsed = tokenPreSale.calculateWeeksElapsed(startTime,currentTimestamp);
        Assert.equal(weeksElapsed,3,"weeksElapsed should be 2");

        uint256 priceIncrease = (regularPrice-preSalePrice)/durationWeeks*weeksElapsed;
        uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
        Assert.equal(priceIncrease,calculatedPriceIncrease,"price increase should be 0.5e15");
        uint256 calculatedPrice = tokenPreSale.calculatePrice();
        // uint256 calculatedPrice = 1.5e15;
        uint256 expectedPrice = preSalePrice + priceIncrease;
        Assert.equal(expectedPrice,calculatedPrice,"price  should be 1.5e15");

    }
    event LogBalance(uint256 balance);
    /// @notice Test successful token purchase
    function testAccountBalances() public {

      
        address acc0 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        // address acc1 = address(0xdef);
        
        emit LogBalance(30000);
        uint256 acc0_balance =200;

        uint256 expectedBalance = 200;
        Assert.equal(expectedBalance,acc0_balance,"Balances should be 10");
      
        



    }

    //  /// @notice Test successful token purchase
    // function testBuyTokensSuccess() public {
    //     address acc0;
    //     address acc1;
    //     acc0 = TestsAccounts.getAccount(0);
    //     acc1 = TestsAccounts.getAccount(1);

        
    //     uint256 ethAmount = 1 ether;

    //     // Fund contract with tokens for sale
    //     payable(address(tokenPreSale)).transfer(10 ether);
    //     uint256 initialBuyerBalance = tokenPreSale.balanceOf(acc1);
    //     uint256 initialContractBalance = tokenPreSale.balanceOf(address(tokenPreSale));
    //     Assert.equal(initialContractBalance,10,"Balances should match");


    // }

        // tokenPreSale.startPreSale(startTime, durationWeeks);

        // Set the current time to after the presale
        
        // uint256 price = 2e15;
        // uint256 price;
        // bool success;
        // bytes memory result;
        // (success, result) = address(tokenPreSale).call(abi.encodeWithSignature("calculatePrice()"));
        // Ensure the call was successful
        // Assert.equal(success, true, "Call to calculatePrice should be successful.");

        // Decode the result (uint256 price)
        // price = abi.decode(result, (uint256));
        // Set the current time to 3 days after the presale started
        // uint256 elapsedWeeks = tokenPreSale.calculateWeeksElapsed(startTime,block.timestamp);
        
        // uint256 expectedPrice = tokenPreSale.initialPrice() + ((tokenPreSale.regularSalePrice() - tokenPreSale.initialPrice()) * elapsedWeeks) / durationWeeks;

        // // Assert that the calculated price is correct
        // Assert.equal(price, expectedPrice, "Price during presale should be correctly calculated.");
    // }
}
    