// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "./AvatarLink.sol";

contract Tem is AvatarLink{
    function setReward(address reward) public {
        avatarReward = reward;
    }
}