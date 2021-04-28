// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./interface/ilhb.sol";
import "./Third.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// MasterChef is the master of RIT. He can make RIT and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once RIT is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract HecoSinglePool is Third {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IUniswapV2Router02 public router;
    // Info of each uRIT.
    struct URITInfo {
        uint256 amount;     // How many LP tokens the uRIT has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLpDebt; // 已经分的lp利息.
        //
        // We do some fancy math here. Basically, any point in time, the amount of RITs
        // entitled to a uRIT but is pending to be distributed is:
        //
        //   pending reward = (uRIT.amount * pool.accRITPerShare) - uRIT.rewardDebt
        //
        // Whenever a uRIT deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRITPerShare` (and `lastRewardBlock`) gets updated.
        //   2. URIT receives the pending reward sent to his/her address.
        //   3. URIT's `amount` gets updated.
        //   4. URIT's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        ILHB thirdPool;           // Address of LP token contract.
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. RITs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that RITs distribution occurs.
        uint256 accRITPerShare; // Accumulated RITs per share, times 1e12. See below.
        uint256 minAMount;
        uint256 maxAMount;
        IERC20 rewardToken;
        uint256 lpSupply;
        uint256 deposit_fee; // 1/10000
        uint256 withdraw_fee; // 1/10000
        uint256 allWithdrawReward;
    }
    uint256 public baseReward = 0;
    // The RIT TOKEN!
    Common public rit;
    // Dev address.
    address public devaddr;
    // Fee address.
    address public feeaddr;
    // RIT tokens created per block.
    uint256 public RITPerBlock;
    // Bonus muliplier for early RIT makers.
    uint256 public constant BONUS_MULTIPLIER = 10;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each uRIT that stakes LP tokens.
    mapping (uint256 => mapping (address => URITInfo)) public uRITInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    uint256 public fee = 30; // 30% of profit
    uint256 public feeBase = 100; // 1% of profit

    event Deposit(address indexed uRIT, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed uRIT, uint256 indexed pid, uint256 amount);
    event ReInvest(uint256 indexed pid);
    event SetDev(address indexed devAddress);
    event SetFee(address indexed feeAddress);
    event SetRITPerBlock(uint256 _RITPerBlock);
    event SetPool(uint256 pid ,address lpaddr,uint256 point,uint256 min,uint256 max);
    constructor(
        Common _rit,
        address _feeaddr,
        address _devaddr,
        uint256 _RITPerBlock,
        IUniswapV2Router02 _router
    ) public {
        rit = _rit;
        devaddr = _devaddr;
        feeaddr = _feeaddr;
        RITPerBlock = _RITPerBlock;
        router = _router;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setBaseReward(uint256 _base) public onlyOwner {
        baseReward = _base;
    }

    function setRITPerBlock(uint256 _RITPerBlock) public onlyOwner {
        RITPerBlock = _RITPerBlock;
        emit SetRITPerBlock(_RITPerBlock);
    }

    function setFeebase(uint256 _feeBase) public onlyOwner {
        feeBase = _feeBase;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function GetPoolInfo(uint256 id) external view returns (PoolInfo memory) {
        return poolInfo[id];
    }

    function GetURITInfo(uint256 id,address addr) external view returns (URITInfo memory) {
        return uRITInfo[id][addr];
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(ILHB _kswap,uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate,uint256 _min,uint256 _max,uint256 _deposit_fee,uint256 _withdraw_fee,IERC20 _rewardToken) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            thirdPool: _kswap,
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accRITPerShare: 0,
            minAMount:_min,
            maxAMount:_max,
            rewardToken:_rewardToken,
            lpSupply:0,
            deposit_fee:_deposit_fee,
            withdraw_fee:_withdraw_fee,
            allWithdrawReward:0
        }));
        approve(poolInfo[poolInfo.length-1]);
        emit SetPool(poolInfo.length-1 , address(_lpToken), _allocPoint, _min, _max);
    }

    // Update the given pool's RIT allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate,uint256 _min,uint256 _max,uint256 _deposit_fee,uint256 _withdraw_fee,IERC20 _rewardToken) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].minAMount = _min;
        poolInfo[_pid].maxAMount = _max;
        poolInfo[_pid].rewardToken = _rewardToken;
        poolInfo[_pid].deposit_fee = _deposit_fee;
        poolInfo[_pid].withdraw_fee = _withdraw_fee;
        emit SetPool(_pid , address(poolInfo[_pid].lpToken), _allocPoint, _min, _max);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // View function to see pending RITs on frontend.
    function pending(uint256 _pid, address _uRIT) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        URITInfo storage uRIT = uRITInfo[_pid][_uRIT];
        uint256 accRITPerShare = pool.accRITPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply > 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 RITReward = multiplier.mul(RITPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRITPerShare = accRITPerShare.add(RITReward.mul(1e12).div(lpSupply));
        }
        return uRIT.amount.mul(accRITPerShare).div(1e12).sub(uRIT.rewardDebt);
    }

    function balanceOfUnderlying(PoolInfo memory pool) public view returns (uint256){
        (,uint256 ba,,uint256 exchangerate) = pool.thirdPool.getAccountSnapshot(address(this));
        if(ba <=0){
            return 0;
        }
        return ba.mul(exchangerate).div(1e18);
    }

    // View function to see pending RITs on frontend.
    function rewardLp(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        URITInfo storage uRIT = uRITInfo[_pid][_user];
        uint256 thirdAllBalance = balanceOfUnderlying(pool);
        if(thirdAllBalance <= 0){
            return 0;
        }
        uint256 ba = getWithdrawBalance(_pid, userShares[_pid][_user], thirdAllBalance);
        if(ba > uRIT.amount){
            return ba.sub(uRIT.amount);
        }
        return 0;
    }

    // View function to see pending RITs on frontend.
    function allRewardLp(uint256 _pid) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 thirdAllBalance = balanceOfUnderlying(pool);
        if(thirdAllBalance <= pool.lpSupply){
            return 0;
        }
        return pool.allWithdrawReward.add(thirdAllBalance.sub(pool.lpSupply));
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid,0,true);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid,uint256 _amount,bool isAdd) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        pool.lpSupply = isAdd ? pool.lpSupply.add(_amount) : pool.lpSupply.sub(_amount);
        if (pool.lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 RITReward = multiplier.mul(RITPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        rit.mint(address(this), RITReward); // Liquidity reward
        pool.accRITPerShare = pool.accRITPerShare.add(RITReward.mul(1e12).div(pool.lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function approve(PoolInfo memory pool) private {
        pool.rewardToken.approve(address(router),uint256(-1));
        pool.rewardToken.approve(address(pool.thirdPool),uint256(-1));
        pool.lpToken.approve(address(pool.thirdPool), uint256(-1));
    }

    // Deposit LP tokens to MasterChef for RIT allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(pause==0,'can not execute');
        PoolInfo storage pool = poolInfo[_pid];
        URITInfo storage uRIT = uRITInfo[_pid][msg.sender];
        updatePool(_pid, 0, true); 
        uint256 pendingT = uRIT.amount.mul(pool.accRITPerShare).div(1e12).sub(uRIT.rewardDebt);
        if(pendingT > 0) {
            safeRITTransfer(msg.sender, pendingT);
        }
        harvest(_pid);
        if(_amount > 0) { // 
            //
            if(pool.deposit_fee > 0){
                uint256 feeR = _amount.mul(pool.deposit_fee).div(10000);
                pool.lpToken.safeTransferFrom(address(msg.sender), devaddr, feeR);
                _amount = _amount.sub(feeR);
            }
            uint256 _before = pool.thirdPool.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            pool.thirdPool.mint(_amount);
            uRIT.amount = uRIT.amount.add(_amount);

            if (pool.minAMount > 0 && uRIT.amount < pool.minAMount){
                revert("amount is too low");
            }
            if (pool.maxAMount > 0 && uRIT.amount > pool.maxAMount){
                revert("amount is too high");
            }
            uint256 _after = pool.thirdPool.balanceOf(address(this));
            pool.lpSupply = pool.lpSupply.add(_amount);
            _mint(_pid, _after.sub(_before), msg.sender, _before);
        }
        uRIT.rewardDebt = uRIT.amount.mul(pool.accRITPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // execute when only bug occur
    function safeWithdraw(uint256 _pid) public onlyOwner{
        require(pause==1,'can not execute');
        PoolInfo storage pool = poolInfo[_pid];
        pool.thirdPool.redeem(pool.thirdPool.balanceOf(address(this)));
        pool.lpToken.safeTransfer(address(msg.sender), pool.lpToken.balanceOf(address(this)));
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(pause==0,'can not execute');
        PoolInfo storage pool = poolInfo[_pid];
        URITInfo storage uRIT = uRITInfo[_pid][msg.sender];
        require(uRIT.amount >= _amount, "withdraw: not good");
        updatePool(_pid, 0, false);
        uint256 pendingT = uRIT.amount.mul(pool.accRITPerShare).div(1e12).sub(uRIT.rewardDebt);
        if(pendingT > 0) {
            safeRITTransfer(msg.sender, pendingT);
        }
        if(_amount > 0) {
            uint256 fene = pool.thirdPool.balanceOf(address(this));
            uint256 _shares = getWithdrawShares(_pid, _amount, msg.sender, uRIT.amount);
            uint256 should_withdraw = getWithdrawBalance(_pid, _shares, fene);
            pool.lpSupply = pool.lpSupply.sub(_amount);
            uRIT.amount = uRIT.amount.sub(_amount);
            // 
            pool.thirdPool.redeem(should_withdraw);
            if(pool.withdraw_fee>0){
                uint256 needFee = _amount.mul(pool.withdraw_fee).div(10000);      
                _amount = _amount.sub(needFee);
                pool.lpToken.safeTransfer(devaddr, needFee);
            }
            safeLpTransfer(_pid,address(msg.sender),_amount);
            _burn(_pid, _shares, msg.sender);
        }
        harvest(_pid);
        uRIT.rewardDebt = uRIT.amount.mul(pool.accRITPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function safeLpTransfer(uint256 _pid,address _to, uint256 _min) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 RITBal = pool.lpToken.balanceOf(address(this));
        // require(RITBal>=_min,"wait other platform!!!");
        if(RITBal>_min){
            pool.allWithdrawReward = pool.allWithdrawReward.add(RITBal.sub(_min));
        }
        pool.lpToken.transfer(_to, RITBal);
    }

    // 
    function calcProfit(uint256 _pid) private{
        PoolInfo storage pool = poolInfo[_pid];
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(pool.thirdPool);
        ILHB(0x6537d6307ca40231939985BCF7D83096Dd1B4C09).claimComp(address(this), cTokens); // 提出利息
        // 
        pool.thirdPool.redeem(0);
        uint256 ba = pool.rewardToken.balanceOf(address(this));
      
        if(ba > baseReward){
            // pool.rewardToken.transfer(devaddr,ba);
            uint256 profitFee = ba.mul(fee).div(feeBase);
            pool.rewardToken.safeTransfer(feeaddr,profitFee);
            ba = ba.sub(profitFee);
            swap(router, address(pool.rewardToken),address(pool.lpToken), ba);
        }
        futou(pool);
    }

    function futou(PoolInfo memory pool) private {
        uint256 ba = pool.lpToken.balanceOf(address(this));
        if(ba<=0){
            return;
        }
        if(pool.lpSupply<=0){
            pool.lpToken.transfer(feeaddr,ba);
            return;
        }
        pool.thirdPool.mint(ba);
    }

    // auto reinvest
    function harvest(uint256 _pid) public {
        calcProfit(_pid); 
        emit ReInvest(_pid);
    }

    // Safe RIT transfer function, just in case if rounding error causes pool to not have enough RITs.
    function safeRITTransfer(address _to, uint256 _amount) internal {
        uint256 RITBal = rit.balanceOf(address(this));
        if (_amount > RITBal) {
            rit.transfer(_to, RITBal);
        } else {
            rit.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        require(_devaddr != address(0), "_devaddr is address(0)");
        devaddr = _devaddr;
        emit SetDev(_devaddr);
    }

    // Update fee address by the previous dev.
    function setFeeAddr(address _feeaddr) public {
        require(msg.sender == feeaddr, "fee: wut?");
        require(_feeaddr != address(0), "_feeaddr is address(0)");
        feeaddr = _feeaddr;
        emit SetFee(_feeaddr);
    }
}