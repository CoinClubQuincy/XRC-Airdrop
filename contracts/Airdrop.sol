pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
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
    using SafeERC20 for IERC20;

    //contract variables
    uint public airdropCount=0;
    uint256 public constant airdropKey = 0;

    uint public TotalAlocated=0;
    bool public AirDropStatus = false;
    uint public leftToBeAllocated;
    IERC20 public XRC_Contract;
    
    event OwnerSet(address indexed _Owner, address _tokenContract);
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
        require(XRC_Token_Address != address(0), "Token address is required");
        _mint(msg.sender, airdropKey, 1, "");
        XRC_Contract = IERC20(XRC_Token_Address);
        emit OwnerSet(msg.sender,address(XRC_Contract));
    }

    //Add User to contract
    function AddUser(address _User,uint _amount)public isOwner preAirdrop returns(bool){
        require(_User != address(0), "User address is required");
        require(_amount > 0, "Amount is required");
        leftToBeAllocated = viewBalanceInContract() - TotalAlocated;
        if(_amount <= leftToBeAllocated){
            userAirdrop[airdropCount] = AirDropDB(_User,_amount,true);
            airdropCount++;
            TotalAlocated = TotalAlocated + _amount;
            leftToBeAllocated = leftToBeAllocated - _amount;
            return true;
        } else {
            return false;
        }
    }
    //Edit Airdrop users
    function RemoveUser(uint _userCount,bool _exist)public isOwner preAirdrop returns(string memory){
        require(_userCount < airdropCount, "User does not exist");
        if(_exist == false){
            userAirdrop[_userCount].exist = false;
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
    //Deploy Airdrop: opens redemption and returns only the unallocated tokens to the owner.
    //Passing false does nothing, so the owner can keep editing the list.
    function DeployAirDrop(bool _status)public isOwner preAirdrop returns(bool){
        if(_status == false){
            return false;
        }
        AirDropStatus = true;
        uint remainder = viewBalanceInContract() - TotalAlocated;
        leftToBeAllocated =0;
        if(remainder > 0){
            XRC_Contract.safeTransfer(msg.sender,remainder);
        }
        return AirDropStatus;
    }
    //Users who were air dropped tokens can have them redeemed.
    //Pays every entry the caller has from index i onwards, so use 0 for a full query.
    function RedeemAirdrop(uint i)public postAirdrop returns(bool){
        uint send = 0;
        for(i;i<airdropCount;i++){
            if(userAirdrop[i].User == msg.sender && userAirdrop[i].amount > 0){
                send = send + userAirdrop[i].amount;
                userAirdrop[i].amount =0;
            }
        }
        if(send == 0){
            return false;
        }
        XRC_Contract.safeTransfer(msg.sender,send);
        return true;
    }
    //view Total tokens to be airdropped
    function viewBalanceInContract()public view isOwner returns(uint){
        uint tokensInContract = XRC_Contract.balanceOf(address(this)); // this shows the balance of the XRC20 token in the Airdrop contract
        return tokensInContract;
    }
}


