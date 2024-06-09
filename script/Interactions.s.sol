// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        console.log("fundFundMe address:", address(this));
        console.log("fund by:", msg.sender);
        console.log("funder balance:", msg.sender.balance);
        // console.log(SEND_VALUE);
        // require(msg.sender.balance >= SEND_VALUE);

        if (msg.sender.balance >= SEND_VALUE) {
            console.log("enough balance to fund FundMe");
            vm.startBroadcast();
            FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
            vm.stopBroadcast();
        } else {
            console.log("Not enough balance to fund FundMe");
        }

        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        console.log("WithdrawFundMe address:", address(this));
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        // vm.stopBroadcast();
    }
}
