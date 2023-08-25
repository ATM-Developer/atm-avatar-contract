
// File: contracts/utils/ECDSA.sol


pragma solidity ^0.8.0;

library ECDSA {
    /// signature methods.
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65);

        assembly {
        // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
        // second 32 bytes.
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/utils/init.sol


pragma solidity ^0.8.1;

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts/AvatarLink.sol


pragma solidity ^0.8.1;





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


// File: contracts/AvatarLinkTem.sol


pragma solidity ^0.8.1;


contract Tem is AvatarLink{
    function setReward(address reward) public {
        avatarReward = reward;
    }
}