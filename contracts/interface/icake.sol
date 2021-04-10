pragma experimental ABIEncoderV2;
interface ICake {
    function deposit(uint256 _pid, uint256 _amount) external ;
    function withdraw(uint256 _pid, uint256 _amount) external ;
}