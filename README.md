# atm-avatar-contract

## introduction
**Avatar Link** is a new Link, different with ATM Link. the link is not a contract, and NFT don't have to deposit on
any contract. the link just a data struct to record which two Avatar NFT connected.  One Avatar NFT can connect to many
other Avatar NFT.  

## requirement 
  1. users buy an Avatar NFT need to pay 2k LUCA, one half of that LUCA will be destroyed, other half as reword return to the NFT holder
  2. link between two Avatar NFT, once link connected never disconnect
  3. link will not affect the NFT normal function(don't have to deposit)

## contract 

#### Avatar.sol 
Avatar NFT contract, base from [ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#IERC721) and add below functions.

`mint(address to, uint256 n)` Create NFT : `to` is NFT receiver, `n` is NFT amount, user before call this function to create NFT need to approve enough LUCA.

`setPrice(uint256 _price)` Set Price : `_price` is number of Avatar NFT price

`setLimit(uint256 _limit)` Set Limit :  `_limit` is limit of Avatar NFT 

`setRevealed(bool _state)` Set Revealed : `_state` stata of revealed tokenURI, false use the common URI, true use privet URI

`setBaseURI(string memory uri)` Set BaseURI

`setHiddenUri(string memory uri)` Set HiddenUri : common URI

`setUriSuffix(string memory fix)` Set UriSuffix

`withdraw(address token, address to)` Withdraw token from contract : `token` is token address, `to` is receiver address


#### AvatarLink.sol
Avatar Link contract, proved link invite, connect functions and some data query functions.

##### core data struct 
        //---- link struct
        struct LinkMSG{
            uint256 linkId;
            address userA;
            address userB;
            uint256 idA;      //userA token id
            uint256 idB;      //userB token id
            uint256 ivt_tamp; //invite time
            uint256 cnt_tamp; //connect time
            bool connect;     //is connect
        }

         //--- link created (invite but not connect)
        uint256 public supply;                                          //amount of links
        mapping(uint256 => LinkMSG) public link;                        //link: id => linkMSG
        mapping(uint256 => uint256[]) public pivt;                      //posted link invite: token ID => linkID set 
        mapping(address => uint256[]) public rivt;                      //receve link invite: address ID => linkID set 
    
        //--- link connected 
        mapping(uint256 => mapping(uint256 => uint256)) private linkMap;//Avatar linkMap: min TokenID => max TokenID => linkID
        mapping(uint256 => uint256[]) public linkSet;                   //Avatar linkSet: TokenID => tokenID set



##### write functions

`invite(uint256 idA, address userB)`  Invite others : `idA` is invite's NFT tokenId, `userB` is invitee's address.
when user call this function,the contract will record a pair of data `linkId` , `LinkMSG` and save to above data struct(`link`,`pivt`,`rivt`). 

`connect(uint256 linkId, uint256 idB)` Connect(finish link): `linkId` each linkId corresponds to a unique LinkMSG, 
`idB` is invitee's Avatar NFT tokenId, if this link's invitee don't holder Avatar NFT, will not finish connect.

##### read functions 
