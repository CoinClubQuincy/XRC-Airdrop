pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./XRC20.sol";
//interface for external contracts to execute
interface Airdrop_interface{
    function DeployAirDrop(bool _status)external returns(bool);
    function AddUser(address _User,uint _amount)external returns(bool);
    function RemoveUser(uint _userCount,bool _exist)external returns(string memory);
    function ViewUsers(uint _userCount) external view returns(address,uint,bool);
    function RedeemAirdrop(uint i)external returns(bool);
    function viewBalanceInContract()external view returns(uint);
}

contract Airdrop is ERC1155,Airdrop_interface{
    //contract variables
    uint public airdropCount=0;
    uint256 public constant airdropKey = 0;

    uint public TotalAlocated=0;
    bool public AirDropStatus = false;
    uint public leftToBeAllocated;
    IERC20 public XRC_Contract;
    
    event OwnerSet(address indexed Owner);
    // check _owner of airdrop contract
    modifier isOwner{
        require(balanceOf(msg.sender,airdropKey) == 1, "Caller is not owner");
        _;
    }
    //executes after airdrop
    modifier preAirdrop{
        require(AirDropStatus == false, "Airdrop status must be false");
        _;
    }
    //executes before airdrop
    modifier postAirdrop{
        require(AirDropStatus == true,"Airdrop status must be true");
        _;
    }
    //struct mapping int
    mapping(uint => AirDropDB) userAirdrop;
    struct AirDropDB{
        address User;
        uint amount;
        bool exist;
    }
    constructor(string memory _URI,address XRC_Token_Address) ERC1155(_URI){
        _mint(msg.sender, airdropKey, 1, "");
        XRC_Contract = IERC20(XRC_Token_Address);
        emit OwnerSet(msg.sender);
    }

    //Add User to contract
    function AddUser(address _User,uint _amount)public isOwner preAirdrop returns(bool){
        leftToBeAllocated = viewBalanceInContract() - TotalAlocated;
        if(leftToBeAllocated >0 && _amount <= leftToBeAllocated){
            userAirdrop[airdropCount] = AirDropDB(_User,_amount,true);
            airdropCount++;
            TotalAlocated = TotalAlocated + _amount;         
            return true;
        } else {
            return false;
        }
    }
    //Edit Airdrop users
    function RemoveUser(uint _userCount,bool _exist)public isOwner preAirdrop returns(string memory){
        userAirdrop[_userCount].exist = _exist;
        if(_exist == false){
            TotalAlocated = TotalAlocated - userAirdrop[_userCount].amount;
            leftToBeAllocated = viewBalanceInContract() - TotalAlocated;
            userAirdrop[_userCount].amount=0;
            return "User removed";
        } else{
            return "User not removed";
        }
    }
    //view accounts with pledged amounts
    function ViewUsers(uint _userCount) public view returns(address,uint,bool){
        return (userAirdrop[_userCount].User,userAirdrop[_userCount].amount,userAirdrop[_userCount].exist);
    }
    //Deploy Airdrop
    function DeployAirDrop(bool _status)public isOwner preAirdrop returns(bool){
        AirDropStatus = _status;
        XRC_Contract.transfer(msg.sender,leftToBeAllocated);
        leftToBeAllocated =0;
        return AirDropStatus;
    }
    //Users who were air dropped tokens can have them redeemed
    // i has to be 0 for a full query
    function RedeemAirdrop(uint i)public postAirdrop returns(bool){
        //add continuous execution for loop
        for(i;i<=airdropCount;i++){
            if(userAirdrop[i].User == msg.sender){
                //make sure reentracy isnt possible
                uint send = userAirdrop[i].amount;
                userAirdrop[i].amount =0;
                XRC_Contract.transfer(msg.sender,send);
                return true;                
            }
        }
        return false;
    }
    //view Total tokens to be airdropped
    function viewBalanceInContract()public view isOwner returns(uint){
        uint tokensInContract = XRC_Contract.balanceOf(address(this)); // this shows the balance of the XRC20 token in the Airdrop contract
        return tokensInContract;
    }
}


