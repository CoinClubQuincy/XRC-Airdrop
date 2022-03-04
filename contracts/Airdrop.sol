pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "./XRC20.sol";
contract Aridrop{
    //contract variables
    address private owner;
    uint public airdropCount=0;
    address XRC_Contract;
    uint public TotalAlocated=0;
    bool AirDropStatus;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    // check owner of airdrop contract
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    //executes after airdrop
    modifier preAirdrop{
        require(AirDropStatus == false);
        _;
    }
    //executes before airdrop
    modifier postAirdrop{
        require(AirDropStatus == true);
        _;
    }
    mapping(uint => AirDropDB) userAirdrop;
    struct AirDropDB{
        address User;
        uint ammount;
        bool exist;
    }
    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }
    //change owner
    function changeOwner(address newOwner) public isOwner preAirdrop {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    //Set owner
    function getOwner() external view returns(address) {
        return owner;
    }
    //Add User to contract
    function AddUser(address _User,uint _ammount)public isOwner preAirdrop returns(bool){
        uint leftToBeAllocated = viewTokenInContract() - TotalAlocated;
        if(leftToBeAllocated >0 && _ammount <= leftToBeAllocated){
            userAirdrop[airdropCount] = AirDropDB(_User,_ammount,true);
            airdropCount++;
            TotalAlocated = TotalAlocated + _ammount;            
            return true;
        } else {
            return false;
        }
    }
    //Edit Airdrop users
    function EditUser(uint _userCount,address _User,uint _ammount,bool _exist)public isOwner preAirdrop returns(bool){
        userAirdrop[_userCount] = AirDropDB(_User,_ammount,_exist);
        return true;
    }
    //view accounts with pledged amounts
    function ViewUsers(uint _userCount) public view returns(address,uint,bool){
        return (userAirdrop[_userCount].User,userAirdrop[_userCount].ammount,userAirdrop[_userCount].exist);
    }
    //Set contract
    function Set_XRC_Contract(address _Contract) public isOwner preAirdrop returns(address){
        XRC_Contract = _Contract;
        return XRC_Contract;
    }
    //Deploy Airdrop
    function DeployAirDrop(bool _status)public isOwner preAirdrop returns(bool){
        AirDropStatus = _status;
        return AirDropStatus;
    }
    //Users who were air dropped tokens can have them redeemed
    function RedeemAirdrop(uint _countID)public postAirdrop returns(uint){
        if(userAirdrop[_countID].User == msg.sender){
            IERC20(XRC_Contract).transferFrom(address(this),msg.sender,userAirdrop[_countID].ammount);
            userAirdrop[_countID].ammount = 0;
            return true;
        }
    }
    //view Total totens to be airdropped
    function viewBalanceInContract()public view isOwner returns(uint){
        uint tokensInContract = IERC20(XRC_Contract).balanceOf(address(this)); // this shows the balance of the XRC20 token in the Airdrop contract
        return tokensInContract;
    }
}


