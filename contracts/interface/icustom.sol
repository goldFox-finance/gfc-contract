// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
interface ICustom {
    function mint(uint256 _amount) external;
    function redeem(uint256 _amount) external ;
    function balanceOf(address _account) external view returns(uint256);
}