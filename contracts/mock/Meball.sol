// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Meball is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint256 _totalSupply,
        address treasury
    ) ERC20(name, symbol) {
        _mint(treasury, _totalSupply);
        _transferOwnership(treasury);
    }
}
