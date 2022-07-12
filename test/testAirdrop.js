const Airdrop = artifacts.require("Airdrop");
const SimpleToken = artifacts.require("SimpleToken");

contract(Airdrop, (accounts) => {
    let contract = null;

    before( async() => {
        contract = await Airdrop.deployed("AirDrop: Namelol",{from: accounts[0]});
        XRC_Token = await SimpleToken.deployed("Test Token","TST",100,{from: accounts[0]});
    });

    it("Launch Contract", async() =>  {
        assert(await contract.address !== '');
    })
    it("Load XRC funds into Contract ", async() =>  {
        result = await XRC_Token.transfer(contract.address, 80,{from: accounts[0]});
        Balance = await XRC_Token.balanceOf(contract.address);
        assert(Balance.toNumber() == 80);
    })
    it("add 4 Users", async() =>  {
        //user1 = await contract.AddUser(accounts[1],10,{from: accounts[0]});
        //user2 = await contract.AddUser(accounts[2],10,{from: accounts[0]});
        //user3 = await contract.AddUser(accounts[3],10,{from: accounts[0]});
        //user4 = await contract.AddUser(accounts[4],10,{from: accounts[0]});

        //const viewUser1 =  await contract.ViewUsers(0);

        //console.log(user1);
        assert(await contract.address !== '');
    })
    it("check Users", async() =>  {
        assert(await contract.address !== '');
    })   
    it("remove 1 User", async() =>  {
        assert(await contract.address !== '');
    })
    it("Redeem Airdrops", async() =>  {
        assert(await contract.address !== '');
    })

    it("Deploy Airdrop", async() =>  {
        assert(await contract.address !== '');
    })
})