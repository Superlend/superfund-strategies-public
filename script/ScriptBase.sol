// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

abstract contract ScriptBase is Script {
    struct ChainIds {
        uint256 BASE;
        uint256 ETHEREUM;
        uint256 SONIC;
    }

    struct ChainNames {
        string BASE;
        string ETHEREUM;
        string SONIC;
    }

    ChainIds chainIds = ChainIds({BASE: 8453, ETHEREUM: 1, SONIC: 146});
    ChainNames chainNames =
        ChainNames({BASE: "base", ETHEREUM: "ethereum", SONIC: "sonic"});

    mapping(uint256 => address) eEarnFactoryContracts;
    mapping(uint256 => address) usdc;
    mapping(uint256 => address) pool;
    mapping(uint256 => address) usdcWhale;
    mapping(uint256 => address) eulerVault;
    mapping(uint256 => address) siloVault;

    function setUp() public virtual {
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

        eulerVault[146] = 0x3D9e5462A940684073EED7e4a13d19AE0Dcd13bc;
        // eulerVault[146] = 0x196F3C7443E940911EE2Bb88e019Fd71400349D9;

        siloVault[146] = 0x322e1d5384aa4ED66AeCa770B95686271de61dc3;
    }
}
