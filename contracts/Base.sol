// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 1. Token Contract
contract RandomToken is ERC20, Ownable {
    constructor(
        string memory name, 
        string memory symbol, 
        uint256 initialSupply, 
        address receiver
    ) ERC20(name, symbol) Ownable(receiver) {
        // Mint initial supply to the receiver
        _mint(receiver, initialSupply * 10 ** decimals());
    }
}

// 2. Generation Factory
contract TokenFactory {
    // Arrays of word parts for generation (ALL UPPERCASE)
    string[] private prefixes = ["AE", "BO", "CRI", "DRA", "EX", "FEN", "GOR", "HY", "IN", "JO", "KO", "LU", "MY", "NY", "OR", "PY", "QU", "RA", "SY", "TY", "VE", "XE", "ZE"];
    string[] private middles = ["LAN", "MAR", "NER", "PIX", "ROS", "SEN", "TOR", "VIS", "WEN", "XIR", "ZOR"];
    string[] private suffixes = ["A", "AX", "EX", "IX", "OX", "US", "UM", "IA", "ON", "IO", "OR"];

    event TokenCreated(address indexed tokenAddress, string name, string symbol, uint256 supply, address owner);

    // Function to create a token
    function createToken(uint256 initialSupply) public returns (address) {
        // Generate random name
        string memory randomName = generateRandomName();
        // Generate symbol (ticker) from the name
        string memory randomSymbol = generateSymbol(randomName);

        // Deploy new token
        RandomToken newToken = new RandomToken(randomName, randomSymbol, initialSupply, msg.sender);

        emit TokenCreated(address(newToken), randomName, randomSymbol, initialSupply, msg.sender);

        return address(newToken);
    }

    // Logic for pseudo-random name generation
    function generateRandomName() private view returns (string memory) {
        // Use block.prevrandao + timestamp for pseudo-randomness
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));
        
        string memory part1 = prefixes[seed % prefixes.length];
        string memory part2 = middles[(seed / 2) % middles.length];
        string memory part3 = suffixes[(seed / 3) % suffixes.length];

        // Randomly choose length (2 or 3 syllables)
        if ((seed % 10) > 5) {
            return string(abi.encodePacked(part1, part3)); // E.g.: ZEXUS
        } else {
            return string(abi.encodePacked(part1, part2, part3)); // E.g.: ZEMARUS
        }
    }

    function generateSymbol(string memory name) private pure returns (string memory) {
        bytes memory nameBytes = bytes(name);
        // Take first 3 letters
        if (nameBytes.length >= 3) {
             return string(abi.encodePacked(nameBytes[0], nameBytes[1], nameBytes[2]));
        }
        return "RND";
    }
}