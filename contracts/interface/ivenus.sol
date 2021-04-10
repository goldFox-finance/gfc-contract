// https://app.venus.io/dashboard
interface IVenus {
    function mint(uint256 _amount) external;
    function redeem(uint256 redeemTokens) external ;
    function claim() external ;
    function balanceOf(address _account) external view returns(uint256);
}