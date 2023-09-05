# Upgrade workflow

## What will be changed?
1. change payment receiver to ATM 'reward' contract, after upgrade Luca will be direct send to ATM 'reward' contract.
2. add a variable to record payment amount for "Connect" event.


## Upgrade operational flow
### 1. withdraw Luca to ATM reward contract
```solidity
//use CFO address call AvatarLinkProxy contract's "withdrew" function
function withdraw(address token, address to);
```

### 2. set payment receiver 
1. deploy `AvatarLinkTem.sol` contract that use to set payment receiver
2. upgrade `AvatarLinkProxy` contract 
```solidity
//use deployer address call AvatarLinkProxy contract's "upgrad" function
function upgrad(address newLogic) external;
```
3. set new payment receiver as ATM `reward` contract 
```solidity
//use deployer address call AvatarLinkProxy contract's "setReward" function
function setReward(address reward);
```

### 3. upgrade AvatarLinkProxy as new logic
1. deploy 'AvatarLink.sol' contract that has changed logic to implement above change.
2. upgrade `AvatarLinkProxy` contract 
```solidity
//use deployer address call AvatarLinkProxy contract's "upgrad" function
function upgrad(address newLogic) external;
```