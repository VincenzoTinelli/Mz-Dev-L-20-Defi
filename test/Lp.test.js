const { expect } = require("chai");
const { BigNumber, constants, utils } = require("ethers");
require("@nomicfoundation/hardhat-chai-matchers");

// Token addresses
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// Addresses of users who hold WETH and USDC
const wethHolder = "0x2093b4281990A568C9D5B8bBC3EBFD7a1557Ebdd";
const daiHolder = "0x616eFd3E811163F8fC186011580D72DB42EA7D07";

const fromWei = (x) => ethers.formatEther(x);
const toWei = (x) => ethers.parseEther(x.toString());
const fromWei6Dec = (x) => Number(x) / Math.pow(10, 6);
const toWei6Dec = (x) => Number(x) * Math.pow(10, 6);
const fromWei18Dec = (x) => Number(x) / Math.pow(10, 18);
const toWei18Dec = (x) => Number(x) * Math.pow(10, 18);
const hundredEth = toWei(100);
const tenThousandDai = toWei6Dec(10000);
const thousandDai = toWei(1000);

const sendWeth = async (address, amount) => {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [wethHolder],
  });

  const wethImpersonatedSigner = await ethers.getSigner(wethHolder);

  let weth = await ethers.getContractAt(
    "IERC20",
    WETH_ADDRESS,
    wethImpersonatedSigner
  );
  const transferWeth = await weth
    .connect(wethImpersonatedSigner)
    .transfer(address, amount);

  await transferWeth.wait();
};

const sendDai = async (address, amount) => {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [daiHolder],
  });

  const daiImpersonatedSigner = await ethers.getSigner(daiHolder);

  let dai = await ethers.getContractAt(
    "IERC20",
    DAI_ADDRESS,
    daiImpersonatedSigner
  );

  const transferDai = await dai
    .connect(daiImpersonatedSigner)
    .transfer(address, amount);

  await transferDai.wait();
};
