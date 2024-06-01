// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

contract Dex {
    // Ownwer's address of Dex
    address public immutable owner;
    //Array of liquidity pool addresses
    address[] public liquidityPools;

    //Mapping to get the address of liquidity pool with token addresses
    mapping(address => mapping(address => address)) public getLiquidityPool;

    //Event 
    event LiquidityPoolCreated(address indexed _addressToken1, address indexed _addressToken2, address _addressLiquidityPool);

    //Constructor to set the owner of Dex
    constructor() {
        owner = msg.sender;
    }

    function createLiquidityPool(address _tokenA, address _tokenB) external returns (address _liquidityPool) {
        (address _token1, address _token2) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        require(_token1 != _token2, "Identical tokens");
        require(_token1 != address(0) && _token2 != address(0), "Zero address");
        require(getLiquidityPool[_token1][_token2]  == address(0), "Liquidity pool already exists");

        //Create a new liquidity pool
        _liquidityPool = address(new LiquidityPool(_token1, _token2));
        getLiquidityPool[_token1][_token2] = _liquidityPool;    

        //Add new liquidity pool to the array
        liquidityPools.push(_liquidityPool);

        //Emit event
        emit LiquidityPoolCreated(_token1, _token2, _liquidityPool);
    }
}