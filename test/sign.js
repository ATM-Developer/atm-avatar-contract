const web3 = require("web3");
const privatekey = `0xc4754f5e162c9cdbeb7e35489ed59d1ac17bdc3ef44824ced51c07b2140698ff`
//const address = `0xC4b39A329cf14BB634e8BBf1F8a98074Fb3DaF9D`

/// invitation information
{
    //present signId = 2
    signId = 40,                                                //signId: auto-increment, can't use some signId to invite others
    //inviter = `0x0dCC8b2240c7406100B9544Bd4e2a7Db5E0219A6`,    //userA: inviter
    inviter = `0x5c980E6CdAE758d0C68e86064c1c06B1eA19A6a9`,
    tokenId = 6,                                               //idA: one of connect token, the owner of this token must be userA
    invitee = `0x0dCC8b2240c7406100B9544Bd4e2a7Db5E0219A6`     //userB: invitee, this address can't be userA and zero
}

/// encode msg
const msg = web3.utils.soliditySha3(signId, inviter, tokenId, invitee);

/// signature with private key
const sig = web3.eth.accounts.sign(msg, privatekey);

console.log("\n>>>>>> Msg:", msg, "\n>>>>>> Signature:", sig);


