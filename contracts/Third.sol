import "./Common.sol";

contract Third is Ownable {
    using SafeMath for uint256;
    uint256 public pause = 0;

    function setPause(uint256 _pause) public onlyOwner{
        pause = _pause;
    }
    // execute when major bug appears 
    // Prevent problems with third-party platforms
    // safe User assets
    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public onlyOwner {
        require(pause==1,'can not execute');
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call.value(value)(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");
    }

    // pid => allShares
    mapping (uint256 => uint256) public allShares;

    // pid => address => shares
    mapping (uint256 => mapping(address => uint256)) public userShares;

    function _burn(uint256 _pid,uint256 _shares,address _user) internal {
        require(allShares[_pid] >= _shares,'allShares not enough!');
        allShares[_pid] = allShares[_pid].sub(_shares);
        require(userShares[_pid][_user] >= _shares,'user shares not enough!');
        userShares[_pid][_user] = userShares[_pid][_user].sub(_shares);
    }
    
    // _allBalance is the third platform shares
    // _amount is the deposit new shares
    function _mint(uint256 _pid,uint256 _amount,address _user,uint256 _allBalance) internal {
        uint256 _shares = 0;
        if (allShares[_pid] == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(allShares[_pid])).div(_allBalance);
        }
        allShares[_pid] = allShares[_pid].add(_shares);
        userShares[_pid][_user] = userShares[_pid][_user].add(_shares);
    }
    
    function getWithdrawBalance(uint256 _pid,uint256 _shares,address _user,uint256 _allBalance) public view returns(uint256){
        return (_allBalance.mul(_shares)).div(allShares[_pid]);
    }
    
    function getWithdrawShares(uint256 _pid,uint256 _amount,address _user,uint256 _userBalance) public view returns(uint256){
        return _amount.mul(userShares[_pid][_user]).div(_userBalance);
    }
    
    function userSharesReward(uint256 _pid,address _user,uint256 _allReward) public view returns(uint256){
        return _allReward.mul(userShares[_pid][_user]).div(allShares[_pid]);
    }

}