import "./Common.sol";
contract Third {
    uint256 public pause = 0;

    function setPause(uint256 _pause) public Ownable{
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

}