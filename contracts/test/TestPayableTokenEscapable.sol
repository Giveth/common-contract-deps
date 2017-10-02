pragma solidity ^0.4.15;

import "../TokenEscapable.sol";


contract TestPayableTokenEscapable is TokenEscapable {
	
    function TestPayableTokenEscapable(address _token, address _escapeHatchCaller, address _escapeHatchDestination) TokenEscapable(_escapeHatchCaller,_escapeHatchDestination) {
        blacklistEscapeToken(_token);
    }

    function () payable {
    }
}