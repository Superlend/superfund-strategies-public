// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

abstract contract TestBase is Test {
    struct ChainIds {
        uint256 BASE;
        uint256 ETHEREUM;
        uint256 SONIC;
    }

    ChainIds chainIds = ChainIds({BASE: 8453, ETHEREUM: 1, SONIC: 146});

    mapping(uint256 => string) rpcUrls;
    mapping(uint256 => address) eEarnFactoryContracts;
    mapping(uint256 => address) usdc;
    mapping(uint256 => address) pool;
    mapping(uint256 => address) eulerVault;
    mapping(uint256 => address) siloVault;
    mapping(uint256 => address) usdcWhale;

    function setUp() public virtual {
        rpcUrls[
            8453
        ] = "https://base-mainnet.g.alchemy.com/v2/bOcFQnRsa7SQZkg7z9pAuhFOKbcB5mYh";
        rpcUrls[
            1
        ] = "https://eth-mainnet.g.alchemy.com/v2/bOcFQnRsa7SQZkg7z9pAuhFOKbcB5mYh";
        rpcUrls[
            146
        ] = "https://sonic-mainnet.g.alchemy.com/v2/bOcFQnRsa7SQZkg7z9pAuhFOKbcB5mYh";

        eEarnFactoryContracts[
            8453
        ] = 0x72bbDB652F2AEC9056115644EfCcDd1986F51f15;
        eEarnFactoryContracts[1] = 0x9a20d3C0c283646e9701a049a2f8C152Bc1e3427;
        eEarnFactoryContracts[146] = 0xc8EB6dD027C4Ab1754245F6FdE91B39090C12aDd;

        usdc[8453] = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        usdc[1] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        usdc[146] = 0x29219dd400f2Bf60E5a23d13Be72B486D4038894;

        pool[1] = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
        pool[8453] = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
        pool[146] = 0x5362dBb1e601abF3a4c14c22ffEdA64042E5eAA3;

        usdcWhale[8453] = 0x21bD501F86A0B5cE0907651Df3368DA905B300A9;
        usdcWhale[1] = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;
        usdcWhale[146] = 0xA272fFe20cFfe769CdFc4b63088DCD2C82a2D8F9;

        eulerVault[8453] = 0x0A1a3b5f2041F33522C4efc754a7D096f880eE16;
        siloVault[146] = 0x322e1d5384aa4ED66AeCa770B95686271de61dc3;
    }
}
