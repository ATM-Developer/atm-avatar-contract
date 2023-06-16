// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract Avatar is Ownable, ERC721{
    using Strings for uint256;

    uint256 public supply;      //Avatar totalSupply
    string public baseURI;
    string public uriSuffix;
    string public hiddenUri;
    bool public revealed;
    address public minter;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol){}

    function mint(address to) public returns(uint256) {
        require(msg.sender == minter, "Avatar: only-minter");
        supply++;
        _mint(to, supply);
        return supply;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory){
        _requireMinted(_tokenId);

        if (revealed == false) { return hiddenUri;}

        string memory currentBaseURI = baseURI;
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix)) : "";
    }

    function setRevealed(bool _state) public onlyOwner{
        revealed = _state;
    }

    function setBaseURI(string memory uri) public onlyOwner{
        baseURI = uri;
    }

    function setHiddenUri(string memory uri) public onlyOwner{
        hiddenUri = uri;
    }

    function setUriSuffix(string memory fix) public onlyOwner{
        uriSuffix = fix;
    }

    function setMinter(address usr) public onlyOwner{
        minter = usr;
    }
}