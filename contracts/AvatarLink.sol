// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import  "./utils/init.sol";


interface IAVATAR {
    function mint(address to) external returns(uint256);
}

contract AvatarLink is Initialize{
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

    //--- Avatar NFT config
    address public luca;
    address public avatar;      //Avatar NFT contarct
    address public avatarCFO;   //Avatar NFT financial manage
    uint256 public avatarLimit; //Avatar NFT supply Limit
    uint256 public avatarPrice; //Avatar NFT price

    //--- link created
    uint256 public supply;                      //amount of links
    mapping(uint256 => LinkMSG) public link;    //link: id => linkMSG
    mapping(uint256 => uint256[]) public pivt;  //published link invite: token ID => linkID set
    mapping(address => uint256[]) public rivt;  //received link invite: address ID => linkID set

    //--- link connected 
    mapping(uint256 => mapping(uint256 => uint256)) private linkMap;//Avatar linkMap: min TokenID => max TokenID => linkID
    mapping(uint256 => uint256[]) public linkSet;                   //Avatar linkSet: TokenID => tokenID set

    event Invite(uint256 indexed linkId, address userA, address userB, uint256 idA);
    event Connect(uint256 indexed linkId, address userA, address userB, uint256 idA, uint256 idB);
    event Withdraw(address indexed token, address to, uint256 amt);

    function initialize(address _luca, address _avatar, address _cfo, uint256 _limit, uint256 _price) init public {
        luca = _luca;
        avatar = _avatar;
        avatarCFO = _cfo;
        avatarLimit = _limit;
        avatarPrice = _price; 
    }

    function isConnect(uint256 idA, uint256 idB) public view returns(bool){
        require(idA > 0 && idB > 0 && idA != idB, "AvatarLink: not-allow-id");
        (uint256 a, uint256 b) = idA < idB ? (idA, idB) : (idB, idA);
        uint256 id = linkMap[a][b];
        return link[id].connect;
    }

    function getLinkMSG(uint256 idA, uint256 idB) public view returns(uint256 _linkId, address _userA, address _userB, uint256 _idA, uint256 _idB, uint256 _ivt_tamp, uint256 _cnt_tamp, bool _connect){
        require(idA > 0 && idB > 0 && idA != idB, "AvatarLink: not-allow-id");
        (uint256 a, uint256 b) = idA < idB ? (idA, idB) : (idB, idA);
        uint256 id = linkMap[a][b];
        if(id > 0){
            _linkId= link[id].linkId;
            _userA = link[id].userA;
            _userB = link[id].userB;
            _idA   = link[id].idA;
            _idB   = link[id].idB;
            _ivt_tamp = link[id].ivt_tamp;
            _cnt_tamp = link[id].cnt_tamp;
            _connect  = link[id].connect;
        }
    }

    function getLinkAmount(uint256 tokenId) public view returns(uint256){
        return linkSet[tokenId].length;
    }


    //users can use the same Avatar NFT to invite the same invitee(userB), but the invitee can't use the same NFT to connect. 
    function invite(uint256 idA, address userB) public {
        require(msg.sender == IERC721(avatar).ownerOf(idA), "AvatarLink: not-NFT-owner");
        require(userB != msg.sender && userB != address(0), "AvatarLink: not-allow-address");

        supply++;
        LinkMSG memory l = LinkMSG(
            supply,            //linkId
            msg.sender,        //userA
            userB,             //userB
            idA,               //idA
            0,                 //idB
            block.timestamp,   //ivt_tamp
            0,                 //cnt_tamp
            false              //connect
        );

        link[supply] = l;           //add to link
        pivt[idA].push(supply);     //add linkID to post ivt set
        rivt[userB].push(supply);   //add linkID to recive ivt set

        emit Invite(l.linkId, l.userA, l.userB, l.idA);
    }

    //users can't connect with the same token ID if this connect exist.
    function connect(uint256 linkId) public {
         //check link
        LinkMSG memory l = link[linkId];
        require(l.linkId > 0, "AvatarLink: link-not-exist");
        require(l.userB == msg.sender, "AvatarLink: not-invitee");

        //receive LUCA
        require(IERC20(luca).transferFrom(msg.sender, address(this), avatarPrice), "AvatarLink: receive-luca-fail");

        //create Avatar NFT
        uint256 idB = IAVATAR(avatar).mint(msg.sender);

        //update linkMSG
        l.idB = idB;
        l.cnt_tamp = block.timestamp;
        l.connect = true;
        link[linkId] = l;

        //update linkMap and linkSet
        (uint256 a, uint256 b) = l.idA < l.idB ? (l.idA, l.idB) : (l.idB, l.idA);
        linkMap[a][b] = linkId;

        linkSet[a].push(b);
        linkSet[b].push(a);

        emit Connect(l.linkId, l.userA, l.userB, l.idA, l.idB);
    }

    function withdraw(address token, address to) public {
        require(msg.sender == avatarCFO, "AvatarLink: only-avatar-CFO");
        uint256 amt = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, amt);

        emit Withdraw(token, to, amt);
    }
}


