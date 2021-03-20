// https://wepiggy.com/
interface IWepiggy {
    function mint(uint256 _amount) external;
    function redeem(uint256 redeemTokens) external ;
    function claim() external ;
    function balanceOfUnderlying(address _account) external view returns(uint256);
    function balanceOf(address _account) external view returns(uint256);
}