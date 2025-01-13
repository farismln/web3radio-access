// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IWeb3RadioNFT} from "./interface/IWeb3RadioNFT.sol";
import {IUSDT} from "./interface/IUSDT.sol";

contract Web3RadioAccess {
    // constant variable
    uint256 public constant EPOCH_LENGTH = 7 days;

    // state variable
    address public owner;
    address public web3RadioNFT;
    address public usdt;

    uint256 public usdtAmount;
    uint32 public lastEpoch;
    uint32 public maxStakedNFTPerEpoch = 7;
    uint32 public tokenIdCounter;
    uint32 public lastUpdatedTimestamp;

    // mapping
    mapping(address => uint256) public addressToIdNFTStaked;
    mapping(uint256 => mapping(address => bool)) public epochEligibleAddress;
    mapping(uint256 => uint256) public stakedNFTInEpoch;
    mapping(address => uint256) public usdtStaked;

    // modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier performUpkeep() {
        upkeep();
        _;
    }

    // error
    error NotOwner();
    error MaxAmountReached();
    error NotNFTOwner();
    error AlreadyHaveNFT();
    error NotEnoughUSDT();

    // event
    event NFTClaimed(address indexed user, uint256 tokenId);

    constructor(address _web3RadioNFT, address _usdt) {
        owner = msg.sender;
        web3RadioNFT = _web3RadioNFT;
        usdt = _usdt;
        lastUpdatedTimestamp = uint32(block.timestamp);

        usdtAmount = 10 * 10 ** IUSDT(usdt).decimals();
    }

    // user function
    function claimNFT() external performUpkeep returns (uint256 tokenId) {
        if (IUSDT(usdt).balanceOf(msg.sender) < usdtAmount) {
            revert NotEnoughUSDT();
        }

        if (addressToIdNFTStaked[msg.sender] != 0) {
            revert NotNFTOwner();
        }

        if (IERC721(web3RadioNFT).balanceOf(msg.sender) > 0) {
            revert AlreadyHaveNFT();
        }

        uint256 id = tokenIdCounter;
        _claimNFT(msg.sender);

        emit NFTClaimed(msg.sender, id);

        return id;
    }

    function stakeNFT(uint256 _tokenId) external performUpkeep {
        _stakeNFT(msg.sender, _tokenId);
    }

    function unstakeNFT() external performUpkeep {
        _unstakeNFT(msg.sender, addressToIdNFTStaked[msg.sender]);
    }

    function withdrawAndBurnNFT() external performUpkeep {
        uint256 id = addressToIdNFTStaked[msg.sender];
        _unstakeNFT(msg.sender, id);
        IWeb3RadioNFT(web3RadioNFT).burn(id);
        IUSDT(usdt).transfer(msg.sender, usdtAmount);
    }

    function upkeep() public {
        uint256 epoch = (block.timestamp - lastUpdatedTimestamp) / EPOCH_LENGTH;
        if (epoch > 0) {
            lastEpoch += uint32(epoch * EPOCH_LENGTH);
        }
    }

    // internal function
    function _claimNFT(address _user) internal {
        IUSDT(usdt).transferFrom(_user, address(this), usdtAmount);
        IWeb3RadioNFT(web3RadioNFT).mint(_user, tokenIdCounter);
        tokenIdCounter++;
    }

    function _stakeNFT(address _user, uint256 _tokenId) internal {
        IERC721(web3RadioNFT).safeTransferFrom(_user, address(this), _tokenId);
        addressToIdNFTStaked[_user] = _tokenId;
    }

    function _unstakeNFT(address _user, uint256 _tokenId) internal {
        IERC721(web3RadioNFT).safeTransferFrom(address(this), _user, _tokenId);
        addressToIdNFTStaked[_user] = 0;
    }

    // admin function
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function changeUSDTAmount(uint256 _usdtAmount) external onlyOwner {
        usdtAmount = _usdtAmount;
    }

    function changeMaxStakedNFTPerEpoch(
        uint32 _maxStakedNFTPerEpoch
    ) external onlyOwner {
        maxStakedNFTPerEpoch = _maxStakedNFTPerEpoch;
    }

    // view function
    function isEligible(address _user) external view returns (bool) {
        return epochEligibleAddress[lastEpoch][_user];
    }

    function getEpoch() external view returns (uint256) {
        return (block.timestamp - lastEpoch) / EPOCH_LENGTH;
    }
}
