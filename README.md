# **atm-avatar-contract**

## Introduction

Avatar Link is a new Link, different with ATM Link. the link is not a contract, and NFT don't have to deposit on
any contract. the link just a data struct to record which two Avatar NFT connected.  One Avatar NFT can connect to many
other Avatar NFT.  



## Requirement 

1. users buy an Avatar NFT need to pay 2k LUCA, one half of that LUCA will be destroyed, other half as reword return to the NFT holder
2. link between two Avatar NFT, once link connected never disconnect
3. link will not affect the NFT normal function(don't have to deposit)

## Contracts API 

## 1. Avatar.sol 
Avatar NFT contract, base from [ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#IERC721) and add below functions.

### reade function
1. **Set Revealed** `setRevealed(bool _state)`: `_state` stata of revealed tokenURI, false use the common URI, true use unique URI

2. **Set BaseURI** `setBaseURI(string memory uri)` 

3. **Set HiddenUri** `setHiddenUri(string memory uri)`: common URI

4. **Set UriSuffix** `setUriSuffix(string memory fix)` 

5.  **Set Minter** `setMinter(string memory fix)`: only minter can mint NFT, after first NFT be created the Minter need set to AvatarLink contract

### event 
1. `Transfer(from, to, tokenId)`

## 2. AvatarLink.sol
Avatar Link contract, proved link invite, connect functions and some data query functions. [upgrade operation](./upgrade.md)

### core data struct 
```solidity
     //--- Avatar link information
    uint256 public supply;                                          //amount of links
    mapping(uint256 => LinkMSG) public link;                        //link: id => linkMSG
    mapping(uint256 => uint256) public signMap;                     //signMap: signId => linkId
    mapping(uint256 => mapping(uint256 => uint256)) private linkMap;//Avatar linkMap: min TokenID => max TokenID => linkID
    mapping(uint256 => uint256[]) public linkSet;                   //Avatar linkSet: TokenID => tokenID set

    //--- Avatar NFT config
    address public luca;        //LUCA 
    address public busd;        //BUSD  
    address public router;      //PancakeSwap router
    address public avatar;      //Avatar NFT contract
    address public avatarCFO;   //Avatar NFT financial manage
    address public avatarSign;  //Avatar NFT signer
    uint256 public avatarLimit; //Avatar NFT supply Limit
    uint256 public avatarValue; //Avatar NFT value(BUSD)
    address[] public path;      //PancakeSwap path

```

### write functions
1. **Connect** `connect(uint256 signId, address inviter, uint256 tokenId, bytes memory signature)`, 
create connect, before call this function need approve luca for AvatarLink contract, and need provide invite signature .

2. **Withdraw** `withdraw(address token, address to)` withdraw token from contract : `token` is token address, `to` is receiver address

### read functions 
1. **isConnect** `isConnect(uint256 idA, uint256 idB) public view returns(bool)` : check two Avatar NFT tokenId if connected.
2. **getLinkMSG** `getLinkMSG(uint256 idA, uint256 idB) public view returns(uint256 _linkId, address _userA, address _userB, uint256 _idA, uint256 _idB, uint256 _ivt_tamp, uint256 _cnt_tamp, bool _connect)` : get connect information by two Avatar NFT tokenId
3. **link** `link(uint256 linkId) public view returns(uint256 _linkId, address _userA, address _userB, uint256 _idA, uint256 _idB, uint256 _ivt_tamp, uint256 _cnt_tamp, bool _connect)` : get connect information by linkId
4. **supply** `supply() public view returns(uint256 amount)` : total amount of links
5. **linkSet** `linkSet(uint256 tokenId) public view returns(uint256[] linkIds)`: get all connect tokenId set
6. **getLinkAmount** `getLinkAmount(uint256 tokenId) public view returns(uint256)`: get connected link's amount
7. **getPrice** `function getPrice(uint256 vaule) public view returns(uint256)`: get Avatar NFT price(LUCA), `vaule` is amount of USD(BUSD)

### events
1. `Connect(uint256 indexed linkId, address userA, address userB, uint256 idA, uint256 idB);` only available before upgrade
2. `Connect(uint256 indexed linkId, address userA, address userB, uint256 idA, uint256 idB，uint256 rewardIn);`: `rewardIn` is amount of Luca that direct transfer to reward contract, only available after upgrade

### upgrade changes
1. reward direct transfer to ATM reward contract.
2. event of `Connect` add rewardIn.

## docking & debug

### blockchain environment

```js
   Network: BSC-Test
   PancakeSwap:     https://pcs.nhancv.com/#/swap    
   LUCA:            0xD7a1cA21D73ff98Cc64A81153eD8eF89C2a1EfEF
   BUSD:            0xe0dfffc2e01a7f051069649ad4eb3f518430b6a4
   PancakeRouter:   0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0
   PancakePair:     0x36b20fDB728771484bd7F9E5b124A19272c1FDC0
   Avatar_NFT:      0x90380308827ab3685B776588c7eB880014533506
   AvatarLink:      0x982f67Fde928CC1Bb630e84e7b75fE03032B6767
   Incentive:       0xA711ae1bdb635ACEC1Dd5E1a5d670dDb2858ae63    //ATM reward contract
   //AvatarLink deploy at block: 31066831
   //AvatarLink upgrade.md at block: 32716893 
   //Total reward before upgrade.md: 1335524336242067420820          //1,335.52433624206742082 LUCA
   
```

## workflow

### connect-workflow
`precondition`: Make sure you have enough TBNB and LUCA on your account(testnet NFT price 10LUCA)

1. **Authorize to AvatarLink contract**
```solidity
   //call LUCA's contratc "approve" function 
   function approve(address spender, uint256 amount) external returns (bool);
```
2. **Get invitation information**
  in production environment should get from a signature service, now can use [sign_tool](./test/sign.js)  to generate signatures

3. **Create connect**
```solidity
   //call  AvatarLink's "connect" function
   function connect(uint256 signId, address inviter, uint256 tokenId, bytes memory signature);
```

## third-party interfaces
1. [bscscan-api](https://docs.bscscan.com/)(Including asset statistics and NFT holding list)
2. [web3.js-doc](https://web3js.readthedocs.io/)


