const Airdrop = artifacts.require("Airdrop");
const XRC20 = artifacts.require("SimpleToken");

contract('Airdrop',() => {
    it('Deploy Login Contract', async () => {
        const instance = await Airdrop.deployed();
        console.log(LoginContract.address);
        assert(LoginContract.address !== '');
    });
});

contract('XRC20',() => {
    it('Deploy Login Contract', async () => {
        const instance = await XRC20.deployed();
        console.log(LoginContract.address);
        assert(LoginContract.address !== '');
    });
});