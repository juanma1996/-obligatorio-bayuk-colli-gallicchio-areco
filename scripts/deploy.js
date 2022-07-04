const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');
const { sign } = require("crypto");

//Contract to deploy

const tokenContractToDeploy = "TokenContract";
const vaultContractToDeploy = "Vault";
const farmContractToDeploy = "Farm";

async function main() {
    
    //Get provider
    //const provider = ethers.provider;

    //Get provider for testnet Ganache
    const accessPoint_URL = process.env.GANACHE_URL;
    const provider = new ethers.providers.JsonRpcProvider(accessPoint_URL);  
   
     //Get provider for testnet RINKEBY
     //const accessPoint_URL = process.env.RINKEBY_ACCESSPOINT_URL;
     //const provider = new ethers.providers.JsonRpcProvider(accessPoint_URL);
 

    //Get signer
    const[signer, signer2] = await ethers.getSigners();
    
    // Get Contracts to deploy
    const contractTokenPath = "contracts/" + tokenContractToDeploy + ".sol:" + tokenContractToDeploy;
    const contractVaultPath = "contracts/" + vaultContractToDeploy + ".sol:" + vaultContractToDeploy;
    const contractFarmPath = "contracts/" + farmContractToDeploy + ".sol:" + farmContractToDeploy;

    const confirmations_number                        = 1;

    const tokenContractFactory = await ethers.getContractFactory(contractTokenPath, signer);
    const deployedTokenContract = await tokenContractFactory.deploy(process.env.TOKEN_NAME, 
        process.env.TOKEN_SYMBOL,
        process.env.TOKEN_DECIMAL);
       
    tx_hash_TokenContract                             = deployedTokenContract.deployTransaction.hash;
    tx_result_TokenContract                           = await provider.waitForTransaction(tx_hash_TokenContract, confirmations_number);
    if(tx_result_TokenContract.confirmations_number < 0 || tx_result_TokenContract === undefined){
            throw new Error(tokenContractToDeploy || "Contract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    const vaultContractFactory = await ethers.getContractFactory(contractVaultPath, signer);
    const deployedVaultContract = await vaultContractFactory.deploy(
        {value: process.env.ETHERS_AMOUNT_VAULT_INITIAL
        //,gasLimit: 50000
    });
    // value is amount of ethers to transfer on the deploy
    tx_hash_VaultContract                             = deployedVaultContract.deployTransaction.hash;
    tx_result_VaultContract                           = await provider.waitForTransaction(tx_hash_VaultContract, confirmations_number);
    if(tx_result_VaultContract.confirmations_number < 0 || tx_result_VaultContract === undefined){
        throw new Error(vaultContractToDeploy || "Contract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    const farmContractFactory = await ethers.getContractFactory(contractFarmPath, signer);
    const deployedFarmContract = await farmContractFactory.deploy();
    
    tx_hash_FarmContract                              = deployedFarmContract.deployTransaction.hash;
    tx_result_FarmContract                           = await provider.waitForTransaction(tx_hash_FarmContract, confirmations_number);
    if(tx_result_FarmContract.confirmations_number < 0 || tx_result_FarmContract === undefined){
        throw new Error(farmContractToDeploy || "Contract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    //Get TOKEN CONTRACT contract read only instance
    const tokenContractABIPath          = path.resolve(process.cwd(), "artifacts/contracts/", tokenContractToDeploy) + ".sol/" + tokenContractToDeploy + ".json";
    const tokenContractArtifact         = JSON.parse(fs.readFileSync(tokenContractABIPath, 'utf8'));
    const deployedTokenContractInstance = new ethers.Contract(deployedTokenContract.address, tokenContractArtifact.abi, signer);  
    

     //Get VAULT contract read only instance
     const vaultContractABIPath          = path.resolve(process.cwd(), "artifacts/contracts/", vaultContractToDeploy) + ".sol/" + vaultContractToDeploy + ".json";
     const vaultContractArtifact         = JSON.parse(fs.readFileSync(vaultContractABIPath, 'utf8'));
     const deployedVaultContractInstance = new ethers.Contract(deployedVaultContract.address, vaultContractArtifact.abi, signer);  

      //Get FARM contract read only instance
      const farmContractABIPath          = path.resolve(process.cwd(), "artifacts/contracts/", farmContractToDeploy) + ".sol/" + farmContractToDeploy + ".json";
      const farmContractArtifact         = JSON.parse(fs.readFileSync(farmContractABIPath, 'utf8'));
      const deployedFarmContractInstance = new ethers.Contract(deployedFarmContract.address, farmContractArtifact.abi, signer);  
    
     const signerBalance                 = ethers.utils.formatEther(await signer.getBalance());

    const contractVersion = await deployedTokenContractInstance.VERSION();
    const tokenName = await deployedTokenContractInstance.name();
    const tokenSymbol= await deployedTokenContractInstance.symbol();
    const tokenDecimal= await deployedTokenContractInstance.decimals();

    // MINT FIRST TIME by VAULT CONTRACT

    //SET TOKEN CONTRACT ADDRESS ON VAULT CONTRACT
    const tx1 = await deployedVaultContractInstance.setTransferAccount(deployedTokenContractInstance.address);
    const tx_result_SetTransferAccount                           = await provider.waitForTransaction(tx1.hash, confirmations_number);
    if(tx_result_SetTransferAccount.confirmations_number < 0 || tx_result_SetTransferAccount === undefined){
        throw new Error("SetTransferAccount ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    //SET VAULT CONTRACT ADDRESS ON TOKEN CONTRACT
    const tx2 = await deployedTokenContractInstance.setAccountVault(deployedVaultContractInstance.address);
    const tx_result_SetAccountVault                           = await provider.waitForTransaction(tx2.hash, confirmations_number);
    if(tx_result_SetAccountVault.confirmations_number < 0 || tx_result_SetAccountVault === undefined){
        throw new Error("SetAccountVault ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }
 
    //CALL MINT METHOD ON VAULT CONTRACT. THIS METHOD CALL MINT METHOD OF TOKEN CONTRACT
    const tx3 = await deployedVaultContractInstance.mint(process.env.DEPLOY_MINT_AMOUNT);
   const account2 = await deployedVaultContractInstance.connect(signer2);

    const tx_result_Mint                           = await provider.waitForTransaction(tx3.hash, confirmations_number);
    if(tx_result_Mint.confirmations_number < 0 || tx_result_Mint === undefined){
        throw new Error("Mint ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    const tx4 = await account2.mint(process.env.DEPLOY_MINT_AMOUNT);
    const tx_result_Mint2                           = await provider.waitForTransaction(tx4.hash, confirmations_number);
    if(tx_result_Mint2.confirmations_number < 0 || tx_result_Mint2 === undefined){
        throw new Error("Mint 2 ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }
     //CALL totalSupply METHOD OF TOKEN CONTRACT
     const totalSupply = await deployedTokenContractInstance.totalSupply();
   

    //SET TOKEN CONTRACT ADDRESS ON FARM CONTRACT
    const tx5 = await deployedFarmContractInstance.setTokenContract(deployedTokenContractInstance.address);
    const tx_result_SetTokenContract                           = await provider.waitForTransaction(tx5.hash, confirmations_number);
    if(tx_result_SetTokenContract.confirmations_number < 0 || tx_result_SetTokenContract === undefined){
        throw new Error("SetTokenContract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }
    //SET TOKEN CONTRACT ADDRESS ON FARM CONTRACT
    const tx6 = await deployedFarmContractInstance.setVaultContract(deployedVaultContractInstance.address);
    const tx_result_SetVaultContract                           = await provider.waitForTransaction(tx6.hash, confirmations_number);
    if(tx_result_SetVaultContract.confirmations_number < 0 || tx_result_SetVaultContract === undefined){
        throw new Error("SetVaultContract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    if(contractVersion != 100){
        throw new Error(`-- ${tokenContractToDeploy} contract ERROR: Version check fail`);
    }else{
        console.log("");
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Deployed contract:\t", tokenContractToDeploy);
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Token Contract address:\t", deployedTokenContractInstance.address);
        console.log("-- Token Contract version:\t", parseInt(contractVersion));
        console.log("-- Token Name:\t", tokenName);
        console.log("-- Token Symbol:\t", tokenSymbol);
        console.log("-- Token decimals:\t", parseInt(tokenDecimal));
      
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Deployed contract:\t", vaultContractToDeploy);
        console.log("-- Vault Contract address:\t", deployedVaultContractInstance.address);
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Deployed contract:\t", farmContractToDeploy);
        console.log("-- Farm Contract address:\t", deployedFarmContractInstance.address);
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Total Supply:\t", parseInt(totalSupply));


        console.log("-----------------------------------------------------------------------------");
        console.log("-- Signer address:\t", signer.address);
        console.log("-- Signer balance:\t", signerBalance);
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Deploy successfully");
        console.log("-----------------------------------------------------------------------------");
    }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });