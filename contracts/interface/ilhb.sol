// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
interface ILHB {
    function mint(uint256 _amount) external;
    function redeem(uint256 _amount) external ;
    function balanceOf(address _account) external view returns(uint256);
    function claimComp(address holder, address[] memory cTokens) external;
    function getAccountSnapshot(address _account) external view returns(uint256,uint256,uint256,uint256);
}