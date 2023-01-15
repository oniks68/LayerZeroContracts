// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Harmony is NonblockingLzApp, ERC20 {
    uint16 destChainId;

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) ERC20("Cross Chain Token", "CCT") {
        if (_lzEndpoint == 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4) destChainId = 109;
        if (_lzEndpoint == 0x3c2269811836af69497E5F486A85D7316753cf62) destChainId = 116;
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory _payload) internal override {
       (address toAddress, uint amount) = abi.decode(_payload, (address,uint));
       _mint(toAddress, amount);
    }

    function bridge(uint _amount) public payable {
        _burn(msg.sender, _amount);
        bytes memory payload = abi.encode(msg.sender, _amount);
        _lzSend(destChainId, payload, payable(msg.sender), address(0x0), bytes(""), msg.value);
    }

    function trustAddress(address _otherContract) public onlyOwner {
        trustedRemoteLookup[destChainId] = abi.encodePacked(_otherContract, address(this));   
    }
}