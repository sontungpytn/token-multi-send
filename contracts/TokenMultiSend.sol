// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenMultiSend is Ownable {
    using SafeERC20 for IERC20;
    uint256 public fee = 0.001 ether;

    function sendEther(address payable[] calldata users, uint256[] calldata amounts) external payable {
        uint256 total;
        for (uint256 i = 0; i < users.length; i++) {
            total += amounts[i];
        }
        require(msg.value == total + fee, "Invalid value");
        for (uint256 i = 0; i < users.length; i++) {
            users[i].transfer(amounts[i]);
        }
    }

    function sendToken(
        address token,
        address payable[] calldata users,
        uint256[] calldata amounts
    ) external payable {
        require(msg.value == fee, "Invalid value");
        for (uint256 i = 0; i < users.length; i++) {
            IERC20(token).transferFrom(msg.sender, users[i], amounts[i]);
        }
    }

    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function claimMoney(address _to, address _token) external onlyOwner {
        if (_token == address(0)) {
            (bool success, ) = _to.call{value: address(this).balance}("");
            require(success, "Withdraw-AVAX-failed");
        } else {
            IERC20(_token).safeTransfer(_to, IERC20(_token).balanceOf(address(this)));
        }
    }
}
