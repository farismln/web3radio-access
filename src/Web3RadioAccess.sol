// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IUSDT} from "./interface/IUSDT.sol";

contract Web3RadioAccess {
    // constant variable
    uint256 public constant EPOCH_LENGTH = 7 days;

    // state variable
    address public owner;
    address public web3RadioNFT;
    address public usdt;
    
    uint256 public usdtAmount;

    // modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _web3RadioNFT, address _usdt) {
        owner = msg.sender;
        web3RadioNFT = _web3RadioNFT;
        usdt = _usdt;

        usdtAmount = 10 * 10 ** IUSDT(usdt).decimals();
    }

    // user function
    function getNFT() external returns (uint256 tokenId) {

    } 

    // admin function
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function changeUSDTAmount(uint256 _usdtAmount) external onlyOwner {
        usdtAmount = _usdtAmount;
    }
}
