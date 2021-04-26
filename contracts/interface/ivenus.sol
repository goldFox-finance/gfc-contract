// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
// https://app.venus.io/dashboard
pragma experimental ABIEncoderV2;
interface IVenus {
    function mint(uint256 _amount) external;
    function redeem(uint256 redeemTokens) external ;
    function balanceOf(address _account) external view returns(uint256);
    function balanceOfUnderlying(address _account) external returns(uint256);
    function getCash() external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function totalBorrows() external view returns(uint256);
    function getAccountSnapshot(address _account) external view returns(uint256,uint256,uint256,uint256);
}