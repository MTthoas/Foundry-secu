// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;
import {Script, console} from "forge-std/Script.sol";

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract HackMeIfYouCan {
    uint256 FACTOR =
        6275657625726723324896521676682367236752985978263786257989175917;
    address public owner;
    uint256 lastHash;
    bytes32 private password;
    bytes32[15] private data;

    mapping(address => uint256) public userFloor;
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public marks;
    mapping(address => uint256) public consecutiveWins;
    mapping(address => uint256) balances;
    mapping(address => mapping(string => bool)) alreadyCalled;
    mapping(address => bool) public top;

    bool public unlocked = true;

    constructor(bytes32 _password, bytes32[15] memory _data) {
        owner = msg.sender;
        password = _password;
        data = _data;
    }

    modifier whenUnlocked() {
        require(unlocked, "Contract Locked");
        _;
    }

    function lock() public {
        require(msg.sender == owner, "Not Owner");
        unlocked = !unlocked;
    }

    function contribute() public payable whenUnlocked {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function getConsecutiveWins(address _addr) public view returns (uint256) {
        return consecutiveWins[_addr];
    }

    function getMarks(address _addr) public view returns (uint256) {
        return marks[_addr];
    }

    function flip(bool _guess) public whenUnlocked returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        if (side == _guess) {
            consecutiveWins[tx.origin]++;
            if (consecutiveWins[tx.origin] == 10) {
                if (!alreadyCalled[tx.origin]["flip"]) {
                    marks[tx.origin] += 4;
                    alreadyCalled[tx.origin]["flip"] = true;
                }
            }

            return true;
        } else {
            consecutiveWins[msg.sender] = 0;
            return false;
        }
    }

    function addPoint() public whenUnlocked {
        if (tx.origin != msg.sender) {
            if (!alreadyCalled[tx.origin]["addPoint"]) {
                marks[tx.origin] += 1;
                alreadyCalled[tx.origin]["addPoint"] = true;
            }
        }
    }

    function transfer(
        address _to,
        uint256 _value
    ) public whenUnlocked returns (bool) {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        if (balances[msg.sender] > 1000000) {
            if (!alreadyCalled[msg.sender]["transfer"]) {
                marks[msg.sender] += 1;
                alreadyCalled[msg.sender]["transfer"] = true;
            }
        }
        return true;
    }

    function goTo(uint256 _floor) public whenUnlocked {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            userFloor[tx.origin] = _floor;
            top[tx.origin] = building.isLastFloor(_floor);
            if (top[tx.origin]) {
                if (!alreadyCalled[tx.origin]["goTo"]) {
                    marks[tx.origin] += 4;
                    alreadyCalled[tx.origin]["goTo"] = true;
                }
            }
        }
    }

    function sendKey(bytes16 _key) public whenUnlocked {
        require(_key == bytes16(data[12]));
        if (!alreadyCalled[msg.sender]["sendKey"]) {
            marks[msg.sender] += 4;
            alreadyCalled[msg.sender]["sendKey"] = true;
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function sendPassword(bytes32 _password) public whenUnlocked {
        require(password == _password, "Wrong password");
            if (!alreadyCalled[msg.sender]["sendPassword"]) {
                marks[msg.sender] += 3;
                alreadyCalled[msg.sender]["sendPassword"] = true;
            }
        
    }

    receive() external payable whenUnlocked {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        if (!alreadyCalled[msg.sender]["receive"]) {
            marks[msg.sender] += 3;
            alreadyCalled[msg.sender]["receive"] = true;
        }
    }
}