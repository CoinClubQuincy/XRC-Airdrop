pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

contract Aridrop{
    address private owner;
    uint public airdropCount=0;
    address XRC_Contract;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
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

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    function getOwner() external view returns (address) {
        return owner;
    }

    function AddUser(address _User,uint _ammount)public isOwner returns(bool){
        userAirdrop[airdropCount] = AirDropDB(_User,_ammount,true);
        airdropCount++;
        return true;
    }
    function EditUser(uint _userCount,address _User,uint _ammount,bool _exist)public isOwner returns(bool){
        userAirdrop[_userCount] = AirDropDB(_User,_ammount,_exist);
        return true;
    }
    function ViewUsers(uint _userCount) public view returns(address,uint,bool){
        return (userAirdrop[_userCount].User,userAirdrop[_userCount].ammount,userAirdrop[_userCount].exist);
    }
    function Set_XRC_Contract(address _Contract) public isOwner returns(address){
        XRC_Contract = _Contract;
        return XRC_Contract;
    }
    function DeployAirDrop()public isOwner returns(bool){}

}



//------ test token contracts -------------------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalSupply=100;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
