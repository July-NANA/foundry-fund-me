// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

// import {Base_Test} from "../Base_Test.t.sol";

contract InteractionsTest is StdCheats, Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    // uint256 public constant SEND_VALUE = 1e18;
    // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
    // uint256 public constant SEND_VALUE = 1000000000000000000;

    function setUp() external {
        // if (!isZkSyncChain()) {
        //     DeployFundMe deployer = new DeployFundMe();
        //     (fundMe, helperConfig) = deployer.deployFundMe();
        // } else {
        // helperConfig = new HelperConfig();
        // fundMe = new FundMe(helperConfig.activeNetworkConfig());
        // }
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;
        console.log("InteractionsTest address:", address(this));

        // console.log(preUserBalance / 1e18);
        // console.log(preOwnerBalance);

        // Using vm.prank to simulate funding from the USER address
        FundFundMe fundFundMe = new FundFundMe();
        vm.prank(USER);
        // fundFundMe.fundFundMe(address(fundMe));
        // vm.stopPrank();
        fundMe.fund{value: SEND_VALUE}();
        console.log("fundMe address:", address(fundMe));
        console.log("payable fundMe address:", payable(address(fundMe)));
        // console.log(address(fundMe).balance);
        console.log("Owner:", fundMe.i_owner());
        // console.log(fundMe.i_owner().balance);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // vm.prank(fundMe.i_owner());
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
