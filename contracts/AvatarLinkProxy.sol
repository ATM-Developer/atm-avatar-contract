// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import  "./utils/proxy.sol";

contract  AvatarLinkProxy is baseProxy {
    constructor(address avatarLink) {
        _setAdmin(msg.sender);
        _setLogic(avatarLink);
    }
}
