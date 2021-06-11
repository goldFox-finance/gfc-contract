// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./Common.sol";

contract Third is Ownable {
    using SafeMath for uint256;
    uint256 public pause = 0;

    mapping (address => address) public routers;
    address public constant WHT = 0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F;
    address public constant LHB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public constant MDX = 0x25D2e80cB6B86881Fd7e07dd263Fb79f4AbE033c;
    address public constant HUSD = 0x0298c2b32eaE4da002a15f36fdf7615BEa3DA047;
    address public constant USDT = 0xa71EdC38d189767582C38A3145b5873052c3e47a;
    address public constant ETH = 0x64FF637fB478863B7468bc97D30a5bF3A428a1fD;
    address public constant HFIL = 0xae3a768f9aB104c69A7CD6041fE16fFa235d1810;

    function setPause(uint256 _pause) public onlyOwner{
        pause = _pause;
    }
    // execute when major bug appears 
    // Prevent problems with third-party platforms
    // safe User assets
    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public onlyOwner {
        require(target!=address(0),"target can not be zero address!")
        require(pause==1,'can not execute');
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // solium-disable-next-line security/no-call-value
        (bool success, ) = target.call{value:value}(callData);
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
    
    function getWithdrawBalance(uint256 _pid,uint256 _shares,uint256 _allBalance) public view returns(uint256){
        return (_allBalance.mul(_shares)).div(allShares[_pid]);
    }
    
    function getWithdrawShares(uint256 _pid,uint256 _amount,address _user,uint256 _userBalance) public view returns(uint256){
        return _amount.mul(userShares[_pid][_user]).div(_userBalance);
    }
    
    function userSharesReward(uint256 _pid,address _user,uint256 _allReward) public view returns(uint256){
        return _allReward.mul(userShares[_pid][_user]).div(allShares[_pid]);
    }

    function addRouter(address a,address b) public onlyOwner{
        routers[a] = b;
    }

    function removeRouter(address a) public onlyOwner{
        routers[a] = address(0);
    }

    function swap(IUniswapV2Router02 router,address token0,address token1,uint256 input) internal {
        if(routers[token1]==address(0)){
            address[] memory path = new address[](2);
            path[0] = token0;        
            path[1] = token1;
            router.swapExactTokensForTokens(input, uint256(0), path, address(this), block.timestamp.add(1800));
        } else{
            address[] memory path = new address[](3);
            path[0] = token0;        
            path[1] = routers[token1];
            path[2] = token1;
            router.swapExactTokensForTokens(input, uint256(0), path, address(this), block.timestamp.add(1800));
        }
    }

    function initRouters() internal{
        routers[USDT] = WHT;
        routers[HUSD] = WHT;
        routers[ETH] = WHT;
        routers[HFIL] = WHT;
    }

}
