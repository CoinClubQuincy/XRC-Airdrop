In the crypto space, it is becoming increasingly popular to airdrop tokens for new projects. This is done for a collection of reasons. Some focus on decentralization and widening the maximum distribution of holders. Others want to reward early supporters of the project and continually issue rewards to holders. Sometimes shareholders who listed their stock on the blockchain simply want an easy automated way to issue their token to the correct holders. Whatever the reasoning, airdropping allows for newly created assets to be issued to many parties without a need for a custodian for issuance.
I recently built a new AirDrop contract (XRC-Airdrop)to give creators of new tokens as well as DAOs the ability to add a "redeem" button to their website and mobile applications as a native means to distribute tokens. While a handful of third-party apps offer to assist developers in airdropping their tokens, this contract allows for projects to Airdrop Tokens themselves. Users launch this contract alongside their project then load the appropriate amount of tokens to airdrop in the XRC-Airdrop contract and list the RedeemAirdrop() function as a button on the project website for users to redeem when airdrop is deployed.When the airdrop is deployed users can simply redeem their token on the project site.It's an easy way to deliver assets to digital wallets.Due to XDC's Low fees and fast performance tokens can be redeemed instantly for a fraction of a penny.

Here are the basic steps:
1.Launch Token
2.Launch Airdrop Contract - https://github.com/QCloud-DevOps/XRC-Airdrop
3.Register_XRC_Contract()
4.Load AirDrop Contract with appropriate funds
5.Load UserData() with user address & token amount into airdrop contract
6.Deploy Airdrop
7.Users Redeem() Airdrop

![XRC Airdrop (1)](https://user-images.githubusercontent.com/16103963/157558351-f95a71ea-fa8d-49c5-9988-5e9f7fcead84.png)

