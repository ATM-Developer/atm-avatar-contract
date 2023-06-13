// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Avatar is Ownable, ERC721{
    using Math for uint256;
    using Strings for uint256;

    address public luca;        //ATM token 
    uint256 public price;       //Avatar price
    uint256 public limit;       //Avatar mint limit
    uint256 public supply;      //Avatar totalSupply
    string public baseURI;
    string public uriSuffix;
    string public hiddenUri;
    bool public revealed;

    // --- math 
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "Avatar: math-mul-overflow");
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "Avatar: math-add-overflow");
    }


    constructor(string memory _name, string memory _symbol, address _luca, uint256 _price, uint256 _limit) ERC721(_name, _symbol) {
        (luca, price, limit) = (_luca, _price, _limit);
    }

    function mint(address to, uint256 n) public {
        require(add(supply, n) <= limit, "Avatar: out-of-limit");

        uint256 amt = mul(n, price);

        IERC20(luca).transferFrom(msg.sender, address(this), amt);

        IERC20(luca).transfer(address(0), amt / 2);

        for (uint256 i=0; i< n; i++){
            supply++;
            _mint(to, supply);
        }
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory){
        _requireMinted(_tokenId);

        if (revealed == false) {
            return hiddenUri;
        }

        string memory currentBaseURI = baseURI;
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix)) : "";
    }

    function setPrice(uint256 _price) public onlyOwner{
        price = _price;
    }

    function setLimit(uint256 _limit) public onlyOwner{
        limit = _limit;
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

    function withdraw(address token, address to) public onlyOwner{
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, amount);
    }
}