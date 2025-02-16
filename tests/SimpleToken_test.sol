// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/SimpleToken.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    TokenPreSale public token;
    address public owner;
    address public addr1;
    address public addr2;
    
    uint256 public initialSupply = 1000000 * 10**18; // 1 million tokens with decimals
    uint256 public initialPrice = 1 * 10**18; // Initial price per token in Wei
    uint256 public weeklyIncreaseRate = 10; // 10% weekly increase
    uint256 public regularSalePrice = 2 * 10**18; // Regular sale price in Wei
    uint256 public stakingRewardRate = 5; // 5% annual staking reward rate
    // Deploy contract and set up test addresses
    function beforeAll() public {
        owner = address(0x1234);
        addr1 = address(0x5678);
        addr2 = address(0x9101);

        token = new TokenPreSale(
            owner,
            initialSupply,
            initialPrice,
            weeklyIncreaseRate,
            regularSalePrice,
            stakingRewardRate
        );

        // // Mint initial tokens to test addresses
        // token.transfer(addr1, 1000 * 10**18);
        // token.transfer(addr2, 1000 * 10**18);
    }
        // Test initial supply
    function testInitialSupply() public {
        uint256 expectedSupply = initialSupply;
        uint256 actualSupply = token.totalSupply();
        Assert.equal(actualSupply, expectedSupply, "Initial supply incorrect");
       
    }
    
}
    