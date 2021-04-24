pragma experimental ABIEncoderV2;

interface ICake {
    // Info of each user.
    struct CakeUserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
    function deposit(uint256 _pid, uint256 _amount) external ;
    function withdraw(uint256 _pid, uint256 _amount) external ;
    function userInfo(uint256 _pid,address _user) external view returns (CakeUserInfo memory);
}