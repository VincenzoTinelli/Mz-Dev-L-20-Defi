//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPool {
    // ERC20 token state variables
    IERC20 public immutable token1;
    IERC20 public immutable token2;

    // token reserves
    uint256 public reserve1;
    uint256 public reserve2;

    // liquidity pool shares
    uint256 public totalLiquidity;
    mapping(address => uint256) public userLiquidity;

    // Events
    event MintLpToken(
        address indexed _liquidityProvider,
        uint256 _sharesMinted
    );

    event BurnLpToken(
        address indexed _liquidityProvider,
        uint256 _sharesBurned
    );

    constructor(address _token1, address _token2) {
    token1 = IERC20(_token1);
    token2 = IERC20(_token2);
}

// Internal function to square root a value from Uniswap V2 (Babylonian method)
function sqrt(uint256 y) internal pure returns (uint256 z) {
    if (y > 3) {
        z = y;
        uint256 x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}

// Internal function to find minimum value from Uniswap V2
function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = x < y ? x : y;
}

// Function to get reserves
function getReserves() public view returns (uint256 _reserve1, uint256 _reserve2) {
    _reserve1 = reserve1;
    _reserve2 = reserve2;
}

// Internal function to mint liquidity shares
function _mint(address _to, uint256 _amount) private {
    userLiquidity[_to] += _amount;
    totalLiquidity += _amount;
}

// Internal function to burn liquidity shares
function _burn(address _from, uint256 _amount) private {
    userLiquidity[_from] -= _amount;
    totalLiquidity -= _amount;
}

// Internal function to update liquidity pool reserves
function _update(uint256 _reserve1, uint256 _reserve2) private {
    reserve1 = _reserve1;
    reserve2 = _reserve2;
}

//Function for user to swap tokens
// NOTE: Could possibly make this into 2 functions for gas efficiency
function swapTokens(address _tokenIn, uint256 _amountIn) external returns (uint256 _amountOut) {
    require(_tokenIn == address(token1) || _tokenIn == address(token2), "Invalid token address");

    //Retrive the "token in" 
    bool isToken1 = _tokenIn == address(token1);

    (uint256 _reserve1, uint256 _reserve2) = getReserves();

    (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken1 ? (token1, token2, _reserve1, _reserve2) : (token2, token1, _reserve2, _reserve1);


    // Transfer tokenIn to the liquidity pool
    require(_amountIn > 0, "Insufficient input amount");
    tokenIn.transferFrom(msg.sender, address(this), _amountIn);

    //Calculate tokenIn with fee of 0.2%
    uint256 _amountInWithFee = (_amountIn * 998) / 1000;



    /*Calculate tokenOut amount
    */

   _amountOut = (reserveOut * _amountInWithFee) / (reserveIn + _amountInWithFee);

   require(_amountOut < reserveOut, "Insufficient Liquidity");

   //Transfer tokenOut to the user
    tokenOut.transfer(msg.sender, _amountOut);

    //Update the reserves
    _update(token1.balanceOf(address(this)), token2.balanceOf(address(this)));

}
    //Function for user to add liquidity
    function addLiquidity(uint256 _amountToken1, uint256 _amountToken2) external returns (uint256 _liquidityShares) {
        require(token1.transferFrom(msg.sender, address(this), _amountToken1), "Token Transfer Failed");
        require(token2.transferFrom(msg.sender, address(this), _amountToken2), "Token Transfer Failed");

        /*
        Check if the ratio of tokens supplied is proportional
        to reserve ratio satisfy x * y = k for price to not
        change if both reservees are greater than 0
        */
       (uint256 _reserve1, uint256 _reserve2) = getReserves();

       if (_reserve1 > 0 || _reserve2 > 0) {
           require(_amountToken1 * _reserve2 >= _amountToken2 * _reserve1, "Unbalanced Liquidity Provided");
        }

        uint256 _totalLiquidity = totalLiquidity;

        if (_totalLiquidity == 0) {
            _liquidityShares = sqrt(_amountToken1 * _amountToken2);
        } else {
            _liquidityShares = min((_amountToken1 * _totalLiquidity) / _reserve1, (_amountToken2 * _totalLiquidity) / _reserve2);
        }

        require(_liquidityShares > 0, "Insufficient Liquidity Shares");
        // Mint shares to user
        _mint(msg.sender, _liquidityShares);

        // Update reserves
        _update(token1.balanceOf(address(this)), token2.balanceOf(address(this)));

        emit MintLpToken(msg.sender, _liquidityShares);
    }

    /* Function for user to remove liquidity
         > dx = (S /TL) * x
         > dy = (S / TL) * y
    */
    function removeLiquidity(uint256 _liquidityShares) external returns (uint256 _amountToken1, uint256 _amountToken2) {
        require(userLiquidity[msg.sender] >= _liquidityShares, "Insufficient Liquidity Shares");
        //Get balance of both tokens
        uint256 token1Balance = token1.balanceOf(address(this));
        uint256 token2Balance = token2.balanceOf(address(this));

        uint256 _totalLiquidity = totalLiquidity;

        _amountToken1 = (_liquidityShares * token1Balance) / _totalLiquidity;
        _amountToken2 = (_liquidityShares * token2Balance) / _totalLiquidity;

        require(_amountToken1 > 0 && _amountToken2 > 0, "Insufficient transfer Amounts");

        //Burn user liquidity shares
        _burn(msg.sender, _liquidityShares);

        //Update reserves
        _update(token1Balance - _amountToken1, token2Balance - _amountToken2);

        //Transfer tokens to user
        token1.transfer(msg.sender, _amountToken1);
        token2.transfer(msg.sender, _amountToken2);

        emit BurnLpToken(msg.sender, _liquidityShares);
    }

}