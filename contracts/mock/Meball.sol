// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Meball is ERC20 {
    constructor() ERC20("MEBALL", "MEBALL") {
        _mint(msg.sender, 100000 * 1e18);
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount * 1e18);
    }
}
