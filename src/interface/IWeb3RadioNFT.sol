// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

interface IWeb3RadioNFT {
    function mint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}
