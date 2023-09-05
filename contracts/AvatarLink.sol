// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import  "./utils/init.sol";
import  "./utils/ECDSA.sol";

interface IuniSwapRouterV2{
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns(uint256[] memory amounts);
}

interface Iluca{
    function burn(uint256 amount) external;
}

interface IAVATAR {
    function mint(address to) external returns(uint256);
}

contract AvatarLink is Initialize{
    struct LinkMSG{
        uint256 linkId;
        address userA;
        address userB;
        uint256 idA;
        uint256 idB;
        uint256 tamp;
    }

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
    address public avatarReward;//Avatar NFT reward contract(ATM reward)
    address public avatarSign;  //Avatar NFT signer
    uint256 public avatarLimit; //Avatar NFT supply Limit
    uint256 public avatarValue; //Avatar NFT value(BUSD)
    address[] public path;      //PancakeSwap path

    event Connect(uint256 indexed linkId, address userA, address userB, uint256 idA, uint256 idB, uint256 rewardIn);

    function initialize(address _luca, address _busd, address _router, address _avatar, address _reward, address _sign, uint256 _limit, uint256 _value) init public {
        luca = _luca;
        busd = _busd;
        router = _router;
        avatar = _avatar;
        avatarReward = _reward;
        avatarSign = _sign;
        avatarLimit = _limit;
        avatarValue = _value; 
        path.push(luca);
        path.push(busd);
    }

    function isConnect(uint256 idA, uint256 idB) public view returns(bool){
        require(idA > 0 && idB > 0 && idA != idB, "AvatarLink: not-allow-id");
        (uint256 a, uint256 b) = idA < idB ? (idA, idB) : (idB, idA);
        uint256 id = linkMap[a][b];
        if (id > 0) return true;
        return false;
    }

    function getLinkMSG(uint256 idA, uint256 idB) public view returns(uint256 _linkId, address _userA, address _userB, uint256 _idA, uint256 _idB, uint256 _tamp){
        require(idA > 0 && idB > 0 && idA != idB, "AvatarLink: not-allow-id");
        (uint256 a, uint256 b) = idA < idB ? (idA, idB) : (idB, idA);
        uint256 id = linkMap[a][b];
        LinkMSG memory l = link[id];
        if(id > 0){
            _linkId= l.linkId;
            _userA = l.userA;
            _userB = l.userB;
            _idA   = l.idA;
            _idB   = l.idB;
            _tamp  = l.tamp;
        }
    }

    function getLinkAmount(uint256 tokenId) public view returns(uint256){
        return linkSet[tokenId].length;
    }

    function getPrice(uint256 vaule) public view returns(uint256) { 
         uint256[] memory amounts = IuniSwapRouterV2(router).getAmountsIn(vaule,  path);
         return amounts[0];
    }

    function verifySign(uint256 signId, address inviter, uint256 tokenId, address invitee, bytes memory signature) public view returns(bool){
        bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(signId, inviter, tokenId, invitee)));
        if (ECDSA.recoverSigner(message, signature) == avatarSign) return true;
        return false;
    }

    function connect(uint256 signId, address inviter, uint256 tokenId, bytes memory signature) external {
        require(signMap[signId] == 0, "AvatarLink: used-signature");
        require(IERC721(avatar).ownerOf(tokenId) == inviter, "AvatarLink: inviter-not-holder");
        require(verifySign(signId, inviter, tokenId, msg.sender, signature), "AvatarLink: invalid-signature");
        
        uint256 avatarPrice = getPrice(avatarValue);
        require(IERC20(luca).allowance(msg.sender, address(this)) >= avatarPrice, "AvatarLink: under-approve");

        //send LUCA to reward contract
        IERC20(luca).transferFrom(msg.sender, avatarReward, avatarPrice/2);
        //burn half price of LUCA
        IERC20(luca).transferFrom(msg.sender, address(this), avatarPrice/2);
        Iluca(luca).burn(avatarPrice/2);

        //create Avatar NFT
        uint256 idB = IAVATAR(avatar).mint(msg.sender);
        //record link information
        supply++;
        LinkMSG memory l;
        //load linkMSG
        l.linkId = supply;
        l.userA = inviter;
        l.userB = msg.sender;
        l.idA = tokenId;
        l.idB = idB;
        l.tamp = block.timestamp;
        link[supply] = l;

        //update signMap, linkMap and linkSet
        signMap[signId] = supply;

        (uint256 a, uint256 b) = l.idA < l.idB ? (l.idA, l.idB) : (l.idB, l.idA);
        linkMap[a][b] = supply;

        linkSet[a].push(b);
        linkSet[b].push(a);

        emit Connect(l.linkId, l.userA, l.userB, l.idA, l.idB, avatarPrice/2);
    }
}

