//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Token is ERC20 {
    using SafeMath for uint256;
    address public admin;
    uint256 public maxSupply;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) ERC20(_name, _symbol) {
        admin = msg.sender;
        maxSupply = _maxSupply;
        // _mint(msg.sender, 1000);
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == admin, "only Admin");
        uint256 totalSupply = totalSupply();
        require(
            totalSupply.add(amount) <= maxSupply,
            "Max Token Supply Reached"
        );
        _mint(account, amount);
    }

    function updateAdmin(address newAdmin) external {
        require(admin == msg.sender, "only Admin");
        admin = newAdmin;
    }
}
