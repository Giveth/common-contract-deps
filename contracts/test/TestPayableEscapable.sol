pragma solidity ^0.4.22;

import "../Escapable.sol";

contract TestPayableEscapable is Escapable {

    constructor(address _blackListToken, address _escapeHatchCaller, address _escapeHatchDestination) public 
    Escapable(_escapeHatchCaller,_escapeHatchDestination) {
        blacklistEscapeToken(_blackListToken);
    }

    function () public payable {
    }
}
