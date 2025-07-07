// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

/**
 * @title SimpleERC20Token using OpenZeppelin
 * @dev ERC-20 Token using OpenZeppelin
 * @notice This is a ERC20 Token created for SimpleDEX exercise 

 * Inherits from OpenZeppelin ERC20 standard 
 * Inherits from OpenZeppelin Ownable control access
 */
contract TokenB is ERC20, Ownable {
    // ============================
    // EVENTS

    /**
     * @dev Event emitted when a new token is created
     * @param to Address that receives the minted tokens
     * @param amount Number of tokens created
     */
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @dev Event emitted when tokens are burned
     * @param from Address where the tokens were burned from
     * @param amount Amount of tokens burned
     */
    event TokensBurned(address indexed from, uint256 amount);

    // ============================
    // CONSTRUCTOR

    /**
     * @dev Constructor that initializes the token with OpenZeppelin
     * @param initialSupply Initial supply of tokens (wei)
     * @param initialOwner Address of the initial contract owner
     *
     * USAGE EXAMPLE:
     * initialSupply: 1000000000000000000000000 wei (1M tokens)
     * initialOwner: your address (on MetaMask)
     */
    constructor(uint256 initialSupply, address initialOwner)
        ERC20("TokenB", "TKB")
    {
        // Setting the owner manually
        _transferOwnership(initialOwner);
        // _mint automatically:
        // 1. Checks initialOwner != address(0)
        // 2. Update totalSupply
        // 3. Update balance of the owner
        // 4. Emits Transfer(address(0), initialOwner, initialSupply)
        _mint(initialOwner, initialSupply);
    }

    // ============================
    // EXTENDED FUNCTIONS

    /**
     * @dev Function to create new tokens (owner only)
     * @param to Address that will receive the tokens
     * @param amount Number of tokens to create
     *
     * SECURITY FEATURES:
     * - onlyOwner: Only the owner can execute it
     * - Validates to != address(0) (double validation)
     * - _mint already internally validates address(0)
     * - Automatically updates totalSupply
     * - Automatically emits Transfer event
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to 'zero' or not valid address");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
    * @dev Function to burn your own tokens
    * @param amount Amount of tokens to burn
    *
    * SECURITY FEATURES:
    * - Validates that msg.sender has enough tokens
    * - Automatically reduces totalSupply
    * - Emit Transfer(msg.sender, address(0), amount)
    */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    /**
    * @dev Function to burn tokens from another address (requires approval)
    * @param from Address to burn tokens from
    * @param amount Amount of tokens to burn
    *
    * HOW IT WORKS:
    * 1. Check allowance manually
    * 2. Reduce allowance with _approve
    * 3. _burn burns the tokens and reduces totalSupply
    * 4. Emit Transfer(from, address(0), amount)
    */
    function burnFrom(address from, uint256 amount) public {
        // Setting allowance manually
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Burn amount exceeds allowance");

        // Reduce allowance before burn
        _approve(from, msg.sender, currentAllowance - amount);
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }

    /**
    * @dev Internal function override to add custom validations
    * @param from Source address (address(0) for mint)
    * @param to Destination address (address(0) for burn)
    * @param amount Amount to transfer
    *
    * This function is called BEFORE all transfers, mints, and burns
    * It is the central point for adding custom logic
    *
    * EXTRA VALIDATION:
    * Prevents transfers to the contract itself (for possible token locking)
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Custom validation: avoid transfers to the contract itself
        require(
            to != address(this),
            "It cannot be transferred to the contract itself"
        );

        // Call the parent function to execute the original logic
        super._beforeTokenTransfer(from, to, amount);
    }
}
