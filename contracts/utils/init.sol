// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}
