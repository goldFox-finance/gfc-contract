// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ERC677.sol";

//
contract Common is ERC677("GFC.Finance", "GFC"),Ownable {
    mapping(address =>uint256) public miners;
    bool private _mutex;
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) external returns (bool) {
        require(miners[msg.sender]>0,"not have permission!");
        _mint(account, amount);
        return true;
    }
    function addMiner(address account) public onlyOwner external (bool) {
        miners[account] = 1;
        return true;
    }
    function removeMiner(address account) public onlyOwner external (bool) {
        require(miners[account]>0,"account is not miner!");
        miners[account] = 0;
        return true;
    }
    
    modifier _lock_() { 
       require(!_mutex, 'reentry'); 
       _mutex = true; 
       _; 
       _mutex = false; 
    }
}
