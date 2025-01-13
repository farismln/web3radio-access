// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Web3RadioNFT is ERC721, Ownable(msg.sender) {
    address public web3RadioAccess;

    modifier onlyWeb3RadioAccess() {
        require(msg.sender == web3RadioAccess, "Only Web3RadioAccess can call this function");
        _;
    }

    constructor() ERC721("Web3RadioNFT", "W3RNFT") {}

    function setWeb3RadioAccess(address _web3RadioAccess) external onlyOwner {
        web3RadioAccess = _web3RadioAccess;
    }

    function mint(address to, uint256 tokenId) external onlyWeb3RadioAccess {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external onlyWeb3RadioAccess {
        _burn(tokenId);
    }

}

