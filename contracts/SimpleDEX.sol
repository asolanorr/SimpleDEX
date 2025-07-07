// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

/**
 * @title SimpleDEX
 * @dev A simple decentralized exchange.
 * @notice This contract allows the owner to add or remove liquidity and users to swap TokenA for TokenB and vice-versa.
 * 
 * Uses OpenZeppelin's ERC20 and Ownable contracts for token interaction and access control.
 */
contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;

    // @notice The amount of TokenA that is currently in the pool
    uint256 public reserveForTokenA;
    uint256 public reserveForTokenB;

    /// @notice Emitted when liquidity is added to the pool
    event LiquidityAdded(uint256 amountOnTokenA, uint256 amountOnTokenB);
    
    /// @notice Emitted when liquidity is removed from the pool
    event LiquidityRemoved(uint256 amountOnTokenA, uint256 amountOnTokenB);
    
    /// @notice Emitted when a token swap is performed
    event Swap(
        address indexed user,
        string direction,
        uint256 inputAmount,
        uint256 outputAmount
    );

    /**
     * @notice Initializes the exchange with two ERC20 tokens
     * @dev Token addresses are immutable once set
     * @param _tokenA Address of TokenA contract
     * @param _tokenB Address of TokenB contract
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /**
     * @notice Allows the owner to add liquidity to the pool
     * @dev Transfers TokenA and TokenB from the owner to the contract and updates reserves
     * @param amountOnTokenA Amount of TokenA to add
     * @param amountOnTokenB Amount of TokenB to add
     */
    function addLiquidity(uint256 amountOnTokenA, uint256 amountOnTokenB)
        external
        onlyOwner
    {
        require(
            tokenA.transferFrom(msg.sender, address(this), amountOnTokenA),
            "Transfer of TokenA failed"
        );
        require(
            tokenB.transferFrom(msg.sender, address(this), amountOnTokenB),
            "Transfer of TokenB failed"
        );

        reserveForTokenA += amountOnTokenA;
        reserveForTokenB += amountOnTokenB;

        emit LiquidityAdded(amountOnTokenA, amountOnTokenB);
    }

    /**
     * @notice Allows the owner to remove liquidity from the pool
     * @dev Transfers specified amounts of TokenA and/or TokenB back to the owner and updates reserves
     * @param amountOnTokenA Amount of TokenA to remove
     * @param amountOnTokenB Amount of TokenB to remove
     */
    function removeLiquidity(uint256 amountOnTokenA, uint256 amountOnTokenB)
        external
        onlyOwner
    {
        if (amountOnTokenA > 0) {
            require(
                reserveForTokenA >= amountOnTokenA,
                "Not enough TokenA liquidity"
            );
            reserveForTokenA -= amountOnTokenA;
            require(
                tokenA.transfer(msg.sender, amountOnTokenA),
                "Transfer of TokenA failed"
            );
        }

        if (amountOnTokenB > 0) {
            require(
                reserveForTokenB >= amountOnTokenB,
                "Not enough TokenB liquidity"
            );
            reserveForTokenB -= amountOnTokenB;
            require(
                tokenB.transfer(msg.sender, amountOnTokenB),
                "Transfer of TokenB failed"
            );
        }

        emit LiquidityRemoved(amountOnTokenA, amountOnTokenB);
    }

    /**
     * @notice Swaps a given amount of TokenA for TokenB
     * @dev Uses constant product formula to calculate TokenB output and updates reserves
     * @param amountOnTokenAIn Amount of TokenA provided by the user
     */
    function swapAforB(uint256 amountOnTokenAIn) external {
        require(amountOnTokenAIn > 0, "Amount must be greater than 0");
        require(
            tokenA.transferFrom(msg.sender, address(this), amountOnTokenAIn),
            "Transfer of TokenA failed"
        );

        uint256 amountOnTokenBOut = getAmountOut(
            amountOnTokenAIn,
            reserveForTokenA,
            reserveForTokenB
        );

        reserveForTokenA += amountOnTokenAIn;
        reserveForTokenB -= amountOnTokenBOut;

        require(
            tokenB.transfer(msg.sender, amountOnTokenBOut),
            "Transfer of TokenB failed"
        );

        emit Swap(msg.sender, "A->B", amountOnTokenAIn, amountOnTokenBOut);
    }

    /**
     * @notice Swaps a given amount of TokenB for TokenA
     * @dev Uses constant product formula to calculate TokenA output and updates reserves
     * @param amountOnTokenBIn Amount of TokenB provided by the user
     */
    function swapBforA(uint256 amountOnTokenBIn) external {
        require(amountOnTokenBIn > 0, "Amount must be greater than 0");
        require(
            tokenB.transferFrom(msg.sender, address(this), amountOnTokenBIn),
            "Transfer of TokenB failed"
        );

        uint256 amountOnTokenAOut = getAmountOut(
            amountOnTokenBIn,
            reserveForTokenB,
            reserveForTokenA
        );

        reserveForTokenB += amountOnTokenBIn;
        reserveForTokenA -= amountOnTokenAOut;

        require(
            tokenA.transfer(msg.sender, amountOnTokenAOut),
            "Transfer of TokenA failed"
        );

        emit Swap(msg.sender, "B->A", amountOnTokenBIn, amountOnTokenAOut);
    }

    /**
     * @notice Returns the price of a token in terms of the other token
     * @dev This is a simple price calculation based on current reserves, not a swap quote
     * @param _token The address of the token for which to get the price
     * @return price The price in the other token, scaled by 1e18
     */
    function getPrice(address _token) external view returns (uint256) {
        if (_token == address(tokenA)) {
            return (reserveForTokenB * 1e18) / reserveForTokenA;
        } else if (_token == address(tokenB)) {
            return (reserveForTokenA * 1e18) / reserveForTokenB;
        } else {
            revert("Invalid token address");
        }
    }

    /**
     * @dev Calculates the output amount for a swap using the constant product formula (no fees applied)
     * @param amountIn Amount of input token being swapped
     * @param reserveIn Current reserve of the input token
     * @param reserveOut Current reserve of the output token
     * @return amountOut Amount of output token the user will receive
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256) {
        // (reserveIn + amountIn) * (reserveOut - amountOut) = reserveIn * reserveOut
        // Solving for amountOut
        uint256 amountInWithReserves = reserveIn + amountIn;
        uint256 newReserveOut = (reserveIn * reserveOut) / amountInWithReserves;
        return reserveOut - newReserveOut;
    }
}