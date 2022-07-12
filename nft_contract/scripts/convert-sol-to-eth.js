require("dotenv").config()
const { createAlchemyWeb3 } = require("@alch/alchemy-web3")
const BigNumber = require("bignumber.js")
const contract = require("../artifacts/contracts/NFTContract.sol/NFTContract.json")

const API_URL = process.env.API_URL
const CUSTODIAL_PUBLIC_KEY = process.env.ETH_CUSTODIAL_PUBLIC_KEY
const CUSTODIAL_PRIVATE_KEY = process.env.ETH_CUSTODIAL_PRIVATE_KEY
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS

const web3 = createAlchemyWeb3(API_URL)
const nftContract = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS)


async function convertSOLToEth(recipient, mint, tokenID) {
  //console.log("****Checking if token exists*******")
  let exists = await tokenExists(tokenID);
  //console.log("Exists is " + exists)

  if (exists == true) {
    //console.log("Token exists. Transferring to recipient")
    transferFromCustodian(recipient, mint, tokenID)
  }
  else {
    //console.log("Token does not exist. Minting new token")
    tokenMetadata = getMetadata(mint)
    mintNFT(recipient, tokenMetadata, mint, tokenID)
  }
}

async function getMetadata(mint) {

  const connection = new Connection('devnet');
  const tokenMint = mint;
  const metadataPDA = await Metadata.getPDA(new PublicKey(tokenMint));
  const tokenMetadata = await Metadata.load(connection, metadataPDA);
  let data = JSON.stringify(tokenMetadata.data, function (k, v) { return v === undefined ? null : v });
  return data
}

async function tokenExists(tokenID) {
  result = await nftContract.methods.ownerOf(tokenID).call().then(res => true).catch(error => false)
  //console.log(data)
  //the transaction

  //console.log(result);
  return result;
}

async function transferFromCustodian(recipient, mint, tokenID) {

  const nonce = await web3.eth.getTransactionCount(CUSTODIAL_PUBLIC_KEY, 'latest'); //get latest nonce

  const tx = {
    'from': CUSTODIAL_PUBLIC_KEY,
    'to': CONTRACT_ADDRESS,
    'nonce': nonce,
    'gas': 500000,
    'data': nftContract.methods.safeTransferFrom(CUSTODIAL_PUBLIC_KEY, recipient, new BigNumber(tokenID)).encodeABI()
  }

  const signPromise = web3.eth.accounts.signTransaction(tx, CUSTODIAL_PRIVATE_KEY)

  testhash = await signPromise.then((signedTx) => {
    web3.eth.sendSignedTransaction(
      signedTx.rawTransaction, function (err, hash) {
        if (!err) {
          // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
          console.log(
            '{"status": "ok", "hash": "' + hash + '", "mint": "' + mint + '"}'
          )
        } else {
          // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
          console.log(
            '{ "status": "error", "msg": "Something went wrong when submitting your transaction.",  "err": ' + err + '", "mint": "' + mint + '"}'
          )
        }
      }
    );
  })
    .catch((err) => {
      // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
      console.log('{ "status": "error", "msg": "Promise failed", "err": "' + err + '", "mint": "' + mint + '"}')
    })
}

async function mintNFT(recipient, tokenMetadata, mint, tokenID) {
  const nonce = await web3.eth.getTransactionCount(CUSTODIAL_PUBLIC_KEY, 'latest'); //get latest nonce

  //the transaction
  const tx = {
    'from': CUSTODIAL_PUBLIC_KEY,
    'to': CONTRACT_ADDRESS,
    'nonce': nonce,
    'gas': 500000,
    'data': nftContract.methods.mintNFT(recipient, tokenMetadata, new BigNumber(tokenID)).encodeABI()
  }

  const signPromise = web3.eth.accounts.signTransaction(tx, CUSTODIAL_PRIVATE_KEY)

  signPromise
    .then((signedTx) => {
      web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
          if (!err) {
            // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
            console.log(
              '{"status": "ok", "hash": "' + hash + '", "mint": "' + mint + '"}'
            )

            return hash;
          } else {
            // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
            console.log(
              '{ "status": "error", "msg": "Something went wrong when submitting your transaction.",  "err": ' + err + '", "mint": "' + mint + '"}'
            )
          }
        }
      )
    })
    .catch((err) => {
      // Do not delete, this log statement is how our Elixir Port picks up on the data. This function does not need to return
      console.log('{ "status": "error", "msg": "Promise failed", "err": "' + err + '", "mint": "' + mint + '"}')
    })

}

convertSOLToEth(process.argv[2], process.argv[3], process.argv[4]) 
