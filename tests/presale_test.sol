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
    uint256 initialPrice = 1e15;
    uint256 finalPrice = 2e15;

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

   
    
  function checkPreSaleActivation() public {
        uint256 startTime = currentTimestamp; // 1 day in the future
        uint256 endTime = currentTimestamp + 4 days;
        uint256 steps = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime,endTime,steps);

        bool presaleStarted = tokenPreSale.presaleIsActive();
        Assert.equal(true,presaleStarted, "Presale should be active");
        
    }

       function checkPreSaleParams() public {
        uint256 startTime = currentTimestamp; // 1 day in the future
        uint256 endTime = currentTimestamp + 1 hours;
        uint256 steps = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime,endTime,steps);
        uint256 contractStartTime = tokenPreSale.preSaleStartTime();
        Assert.equal(contractStartTime,startTime, "Start time should match");
        
        
        uint256 contractEndTime = tokenPreSale.preSaleEndTime();
        Assert.equal(contractEndTime,endTime, "Presale end time should match");

        uint256 preSaleSteps = tokenPreSale.preSaleSteps();
        Assert.equal(preSaleSteps,steps, "Process steps should match");

        uint256 stepsDuration = (endTime-startTime)/steps;
        Assert.equal(stepsDuration,60*15, "Single step duration should be dynamically calculated");


        uint256 stepsElapsed = (startTime+ 10 minutes - startTime) / stepsDuration;
        Assert.equal(stepsElapsed,0, "Step should be 0 after 10 minutes");

        stepsElapsed = (startTime+ 15 minutes - startTime) / stepsDuration;
        Assert.equal(stepsElapsed,1, "Step should be 1 after 15 min");

        stepsElapsed = (startTime+ 30 minutes - startTime) / stepsDuration;

        Assert.equal(stepsElapsed,2, "Step should be 2 after 30 min");
        stepsElapsed = (startTime+ 45 minutes - startTime) / stepsDuration;

        Assert.equal(stepsElapsed,3, "Step should be 3 after 45 minutes");
        stepsElapsed = (startTime+ 60 minutes - startTime) / stepsDuration;
        Assert.equal(stepsElapsed,4, "Step should be 4 after 60 minutes");


    }

     function checkPreSaleSteps() public {
        uint256 startTime = currentTimestamp; // 1 day in the future
        uint256 endTime = currentTimestamp + 1 hours;
        uint256 steps = 4;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime,endTime,steps);
        uint256 calcStep = tokenPreSale.getCurrentStep();
        Assert.equal(calcStep,0, "Step should be 0 after 0 minutes");

        tokenPreSale.startPreSale(startTime- 15 minutes,endTime-15 minutes,steps);
        calcStep = tokenPreSale.getCurrentStep();
        Assert.equal(calcStep,1, "Step should be 1 after 15 minutes");

        tokenPreSale.startPreSale(startTime- 30 minutes,endTime-30 minutes,steps);
        calcStep = tokenPreSale.getCurrentStep();
        Assert.equal(calcStep,2, "Step should be 2 after 30 minutes");

        tokenPreSale.startPreSale(startTime- 45 minutes,endTime-45 minutes,steps);
        calcStep = tokenPreSale.getCurrentStep();
        Assert.equal(calcStep,3, "Step should be 3 after 45 minutes");

        tokenPreSale.startPreSale(startTime- 60 minutes,endTime-60 minutes,steps);
        calcStep = tokenPreSale.getCurrentStep();
        Assert.equal(calcStep,4, "Step should be 4 after 60 minutes");
    }



    function checkPreSaleStepsPrices() public {
        uint256 startTime = currentTimestamp; // 1 day in the future
        uint256 endTime = currentTimestamp + 1 hours;
        uint256 steps = 4;  // Presale duration of 4 weeks
        uint256 priceIncrease = (finalPrice - initialPrice)/steps;
        // Call the startPreSale function
        tokenPreSale.startPreSale(startTime,endTime,steps);
        uint256 calcPrice = tokenPreSale.calculatePrice();
        uint256 expectedPrice = initialPrice;
        Assert.equal(calcPrice,expectedPrice, "At step 0 price should be equal to initial price");
        tokenPreSale.startPreSale(startTime - 16 minutes,endTime- 16 minutes,steps);
        calcPrice = tokenPreSale.calculatePrice();
        expectedPrice = initialPrice + priceIncrease;
        Assert.equal(calcPrice,expectedPrice, "At step 1 price should be equal to initial price + 1/4");

        tokenPreSale.startPreSale(startTime - 30 minutes,endTime- 30 minutes,steps);
        calcPrice = tokenPreSale.calculatePrice();
        expectedPrice = initialPrice + priceIncrease *2;
        Assert.equal(calcPrice,expectedPrice, "At step 2 price should be equal to initial price + 1/2");

        tokenPreSale.startPreSale(startTime - 45 minutes,endTime- 45 minutes,steps);
        calcPrice = tokenPreSale.calculatePrice();
        expectedPrice = initialPrice + priceIncrease *3;
        Assert.equal(calcPrice,expectedPrice, "At step 3 price should be equal to initial price + 3/4");

        tokenPreSale.startPreSale(startTime - 60 minutes,endTime- 60 minutes,steps);
        calcPrice = tokenPreSale.calculatePrice();
        expectedPrice = initialPrice + priceIncrease *4;
        Assert.equal(calcPrice,expectedPrice, "At step 4 price should be equal to initial price + 1/1");

        tokenPreSale.startPreSale(startTime - 80 minutes,endTime- 80 minutes,steps);
        calcPrice = tokenPreSale.calculatePrice();
        expectedPrice = finalPrice;
        Assert.equal(calcPrice,expectedPrice, "After presale price should be final price.");
    }
//     // Test: Ensure calculateWeeks returns the correct number of weeks
//     function testCalculateSteps() public {
//         uint256 startTime = currentTimestamp; // 100 days ago
//         uint256 endTime = currentTimestamp+ 1 hours; // 100 days ago
//         // Calculate the number of weeks that have passed since startTime
//         uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);

//         // Since 100 days is roughly 14 weeks (100 / 7 = 14), we expect weeksElapsed to be 14
//         uint256 expectedSteps = 1; // 100 days = 14 weeks

//         // Assert that the number of weeks is correctly calculated
//         Assert.equal(stepsElapsed, expectedSteps, "The calculated weeks should be 1.");
//     }

// // Test: Ensure calculateWeeks returns the correct number of weeks
//     function testCalculateSteps2() public {
//         uint256 startTime = currentTimestamp - 2 days;
//         uint256 endTime = currentTimestamp; 
//         uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
//         uint256 expectedSteps = 2; 
//         Assert.equal(stepsElapsed, expectedSteps, "The calculated steps should be 2.");
//     }

//     // Test: Ensure calculateWeeks returns the correct number of weeks
//     function testCalculateSteps0() public {
//         uint256 startTime = currentTimestamp - 3 days; 
//         uint256 endTime = currentTimestamp;
//         uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
//         uint256 expectedSteps = 0;

//         // Assert that the number of weeks is correctly calculated
//         Assert.equal(stepsElapsed, expectedSteps, "The calculated steps should be 2.");
//     }

//     // Test: Ensure calculateWeeks returns the correct number of weeks
//     function testCalculateSteps3() public {
//         uint256 startTime = currentTimestamp - 4 days;
//         uint256 endTime = currentTimestamp; 
//         uint256 stepsElapsed = tokenPreSale.calculateStepsElapsed(startTime,endTime);
//         uint256 expectedSteps = 4;
//         Assert.equal(stepsElapsed, expectedSteps, "The calculated steps should be 2.");
//     }

// // Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
//     function testCalculatedPriceIncreaseAtWeek0() public {
//         uint256 startTime = currentTimestamp - 5 days;
//         uint256 endTime = currentTimestamp -1;
//         uint256 durationWeeks = 4;  // Presale duration of 4 weeks
        
//         tokenPreSale.startPreSale(startTime, endTime);
//         uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
//         uint256 expectedPriceIncrease = 0;

//         Assert.equal(expectedPriceIncrease, calculatedPriceIncrease, "Price increase during first week should be 0");
//     }

//     // Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
//     function testCalculatedPriceIncreaseAtWeek2() public {
//         uint256 startTime = currentTimestamp - 16 days;   // 10 days in the past, presale should have ended
//         uint256 durationWeeks = 4;  // Presale duration of 4 weeks
//         uint256 endTime = startTime + (durationWeeks * 1 weeks);
//         tokenPreSale.startPreSale(startTime, durationWeeks);
//         uint256 preSalePrice = tokenPreSale.initialPrice();
//         uint256 regularPrice  =tokenPreSale.regularSalePrice();
//         uint256 contractPreSaleStart  = tokenPreSale.preSaleStartTime();
//         uint256 contractPreSaleEnd = tokenPreSale.preSaleEndTime();
//         uint256 preSaleWeeks = tokenPreSale.preSaleWeeksInWeeks();

//         Assert.equal(startTime,contractPreSaleStart,"contractPreSaleStart should match");
//         Assert.equal(endTime,contractPreSaleEnd,"contractPreSaleEnd should match");
//         Assert.equal(preSalePrice,1e15,"preSalePrice should match");
//         Assert.equal(regularPrice,2e15,"regularPrice should match");
//         Assert.equal(preSaleWeeks,durationWeeks,"preSaleWeeks should match");


//         uint256 weeksElapsed = tokenPreSale.calculateWeeksElapsed(startTime,currentTimestamp);
//         Assert.equal(weeksElapsed,2,"weeksElapsed should be 2");

//         uint256 priceIncrease = (regularPrice-preSalePrice)/durationWeeks*weeksElapsed;
//         uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
//         Assert.equal(priceIncrease,calculatedPriceIncrease,"price increase should be 0.5e15");
//         uint256 calculatedPrice = tokenPreSale.calculatePrice();
//         // uint256 calculatedPrice = 1.5e15;
//         uint256 expectedPrice = preSalePrice + priceIncrease;
//         Assert.equal(expectedPrice,calculatedPrice,"price  should be 1.5e15");

//     }


//      // Test: Ensure calculatePrice returns regularSalePrice if pre-sale has ended
//     function testCalculatedPriceIncreaseAtWeek3() public {
//         uint256 startTime = currentTimestamp - 24 days;   // 10 days in the past, presale should have ended
//         uint256 durationWeeks = 4;  // Presale duration of 4 weeks
//         uint256 endTime = startTime + (durationWeeks * 1 weeks);
//         tokenPreSale.startPreSale(startTime, durationWeeks);
//         uint256 preSalePrice = tokenPreSale.initialPrice();
//         uint256 regularPrice  =tokenPreSale.regularSalePrice();
//         uint256 contractPreSaleStart  = tokenPreSale.preSaleStartTime();
//         uint256 contractPreSaleEnd = tokenPreSale.preSaleEndTime();
//         uint256 preSaleWeeks = tokenPreSale.preSaleWeeksInWeeks();

//         Assert.equal(startTime,contractPreSaleStart,"contractPreSaleStart should match");
//         Assert.equal(endTime,contractPreSaleEnd,"contractPreSaleEnd should match");
//         Assert.equal(preSalePrice,1e15,"preSalePrice should match");
//         Assert.equal(regularPrice,2e15,"regularPrice should match");
//         Assert.equal(preSaleWeeks,durationWeeks,"preSaleWeeks should match");


//         uint256 weeksElapsed = tokenPreSale.calculateWeeksElapsed(startTime,currentTimestamp);
//         Assert.equal(weeksElapsed,3,"weeksElapsed should be 2");

//         uint256 priceIncrease = (regularPrice-preSalePrice)/durationWeeks*weeksElapsed;
//         uint256 calculatedPriceIncrease = tokenPreSale.calculatePriceIncrease();
//         Assert.equal(priceIncrease,calculatedPriceIncrease,"price increase should be 0.5e15");
//         uint256 calculatedPrice = tokenPreSale.calculatePrice();
//         // uint256 calculatedPrice = 1.5e15;
//         uint256 expectedPrice = preSalePrice + priceIncrease;
//         Assert.equal(expectedPrice,calculatedPrice,"price  should be 1.5e15");

//     }
//     event LogBalance(uint256 balance);
//     /// @notice Test successful token purchase
//     function testAccountBalances() public {

      
//         address acc0 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
//         // address acc1 = address(0xdef);
        
//         emit LogBalance(30000);
//         uint256 acc0_balance =200;

//         uint256 expectedBalance = 200;
//         Assert.equal(expectedBalance,acc0_balance,"Balances should be 10");
      
        



//     }

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
    