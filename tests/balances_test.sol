// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 
import "remix_accounts.sol";
// <import file to test>
import "../contracts/SimpleToken.sol";
// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TokenPreSale tknContract;
    address acc0;
    address acc1;
    uint256 initial_price = 1e15;
    uint256 presaleWeeks = 4;
    uint256 regular_price = 2e15;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        tknContract = new TokenPreSale(
            address(this), // initialOwner
            1000000,       // totalSupply
            initial_price,          // initialPrice (0.001 ETH)
            10,            // weeklyIncreaseRate (10%)
            regular_price,          // regularSalePrice (0.002 ETH)
            5              // stakingRewardRate (5%)
        );
        acc0= TestsAccounts.getAccount(0); //owner by default
        acc1 = TestsAccounts.getAccount(1);
    }

    function checkSuccess2() public {
        uint256 supply = tknContract.totalSupply();
        Assert.equal(supply, 1000000 * 10 ** tknContract.decimals(), "Total supply should match");
       
    }

    /// #value: 2000000000000000
    /// #sender: account-0
    function testAcct0Balance() public payable  {
        uint256 acc0_balance = msg.value;
        Assert.equal(acc0_balance, 2000000000000000, "Inital balance should be 2000000000000000");
       
    }


    /// #value: 2000000000000000
    function checkSalesInitialization() public  payable {
        uint256 current_time_stamp = block.timestamp;
        uint256 startTime = current_time_stamp - 1 days; // 1 day in the future
        uint256 durationWeeks = presaleWeeks;  // Presale duration of 4 weeks
        // Call the startPreSale function
        tknContract.startPreSale(startTime, durationWeeks);

        bool presaleStarted = tknContract.presaleIsActive();
        Assert.equal(true,presaleStarted, "Presale should be active");


        uint256 current_price = tknContract.calculatePrice();
        
        Assert.equal(current_price,initial_price,"Price should be inital price");

        uint256 quantityToBuy = msg.value/current_price;

        Assert.equal(quantityToBuy,2,"Quantity to buy should be 1000");

        uint256 currentTokenBalance = tknContract.getWalletBalance();

        Assert.equal(currentTokenBalance,0,"Quantity to buy should be 1000");

        


    }


    /// #value: 2000000000000000
    /// #sender: account-0
    function testBuyTokens22() public  payable {
        uint256 current_price = 1e15;
        uint256 quantityToBuy = msg.value / current_price;
        Assert.equal(quantityToBuy, 2, "Presale not active, purchase should fail");
        uint256 balanceBefore = tknContract.balanceOf(acc0);
        Assert.equal(balanceBefore, 0, "Presale not active, purchase should fail");
        // Attempt to buy before presale starts (should fail)
        (bool success, ) = address(tknContract).call{value: msg.value}(abi.encodeWithSignature("buyTokens()"));
        Assert.equal(success, true  , "BuyTokens should succeed");
        // uint256 balanceAfter = tknContract.balanceOf(acc0);
        uint256 balanceAfter = tknContract.getBalance();
        Assert.equal(balanceAfter, 2  , "New balance should be 2");
        // uint testing = 0;
        // Assert.equal(balanceAfter, 2," New balance should be 0");
        // uint256 balanceAfter = tokenPreSale.balanceOf(buyer);
        // Assert.equal(balanceBefore, balanceAfter, "Buyer balance should not change before presale starts");


    }
    // /// #sender: account-0
    // function testCheckBalanceAfterPurhcase() public  payable {
    //         uint256 balanceBefore = tknContract.getWalletBalance();
    //         Assert.equal(balanceBefore, 2, "New balance should be 2");
    // }
/// #sender: account-0
    // function testCheckBalanceAfterPurhcaseFromContract() public  payable {
    //         uint256 balanceBefore = tknContract.getBalanceFromContract();
    //         Assert.equal(balanceBefore, 2, "New balance should be 2");
    // }

}
    