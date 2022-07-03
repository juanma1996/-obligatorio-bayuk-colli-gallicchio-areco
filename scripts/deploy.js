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
    const provider = ethers.provider;

    //Get provider for testnet
    //const accessPoint_URL = process.env.GANACHE_URL;
    //const provider = new ethers.providers.JsonRpcProvider(accessPoint_URL);

    //Get signer
    const[signer] = await ethers.getSigners();

    // Get Contracts to deploy
    const contractTokenPath = "contracts/" + tokenContractToDeploy + ".sol:" + tokenContractToDeploy;
    const contractVaultPath = "contracts/" + vaultContractToDeploy + ".sol:" + vaultContractToDeploy;
    const contractFarmPath = "contracts/" + farmContractToDeploy + ".sol:" + farmContractToDeploy;


    const tokenContractFactory = await ethers.getContractFactory(contractTokenPath, signer);
    const deployedTokenContract = await tokenContractFactory.deploy(process.env.TOKEN_NAME, 
        process.env.TOKEN_SYMBOL,
        process.env.TOKEN_DECIMAL);

    const vaultContractFactory = await ethers.getContractFactory(contractVaultPath, signer);
    const deployedVaultContract = await vaultContractFactory.deploy(
        {value: process.env.ETHERS_AMOUNT_VAULT_INITIAL
        //,gasLimit: 50000
    });
    // value is amount of ethers to transfer on the deploy

    //const farmContractFactory = await ethers.getContractFactory(contractFarmPath, signer);
    //const deployedFarmContract = await farmContractFactory.deploy();


    const confirmations_number                        = 1;
    tx_hash_TokenContract                             = deployedTokenContract.deployTransaction.hash;
    tx_result_TokenContract                           = await provider.waitForTransaction(tx_hash_TokenContract, confirmations_number);
    if(tx_result_TokenContract.confirmations_number < 0 || tx_result_TokenContract === undefined){
        throw new Error(tokenContractToDeploy || "Contract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    tx_hash_VaultContract                             = deployedVaultContract.deployTransaction.hash;
    tx_result_VaultContract                           = await provider.waitForTransaction(tx_hash_VaultContract, confirmations_number);
    if(tx_result_VaultContract.confirmations_number < 0 || tx_result_VaultContract === undefined){
        throw new Error(vaultContractToDeploy || "Contract ERROR: Deploy transaaction is undefined or has 0 confirmations.");
    }

    //Get contract read only instance
    const tokenContractABIPath          = path.resolve(process.cwd(), "artifacts/contracts/", tokenContractToDeploy) + ".sol/" + tokenContractToDeploy + ".json";
    const tokenContractArtifact         = JSON.parse(fs.readFileSync(tokenContractABIPath, 'utf8'));
    const deployedTokenContractInstance = new ethers.Contract(deployedTokenContract.address, tokenContractArtifact.abi, signer);  
    

     //Get contract read only instance
     const vaultContractABIPath          = path.resolve(process.cwd(), "artifacts/contracts/", vaultContractToDeploy) + ".sol/" + vaultContractToDeploy + ".json";
     const vaultContractArtifact         = JSON.parse(fs.readFileSync(vaultContractABIPath, 'utf8'));
     const deployedVaultContractInstance = new ethers.Contract(deployedVaultContract.address, vaultContractArtifact.abi, signer);  
    
     const signerBalance                 = ethers.utils.formatEther(await signer.getBalance());

    const contractVersion = await deployedTokenContractInstance.VERSION();
    const tokenName = await deployedTokenContractInstance.name();
    const tokenSymbol= await deployedTokenContractInstance.symbol();
    const tokenDecimal= await deployedTokenContractInstance.decimals();

    // MINT FIRST TIME by VAULT CONTRACT
    await deployedVaultContractInstance.setTransferAccount(deployedTokenContractInstance.address);
    await deployedVaultContractInstance.mint(process.env.DEPLOY_MINT_AMOUNT);
    const totalSupply = await deployedTokenContractInstance.totalSupply();

    // MINT FIRST TIME by VAULT CONTRACT
    //const newToken = await token.connect(walletFrom);
    //await deployedTokenContractInstance.setAccountVault();
   
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


        console.log("-----------------------------------------------------------------------------");
        console.log("-- Deployed contract:\t", vaultContractToDeploy);
        console.log("-----------------------------------------------------------------------------");
        console.log("-- Token Contract address:\t", deployedVaultContractInstance.address);
        
        console.log("-- Total Supply:\t", parseInt(totalSupply));



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