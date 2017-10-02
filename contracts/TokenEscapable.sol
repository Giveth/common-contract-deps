pragma solidity ^0.4.15;

import "./Escapable.sol";
import "./ERC20.sol";

contract TokenEscapable is Escapable {

    bool private escapeBlacklistInitialized;
    mapping (address=>bool) private escapeBlacklist;

    /// @notice The Constructor assigns the `escapeHatchDestination` and the
    ///  `escapeHatchCaller`
    /// @param _escapeHatchDestination The address of a safe location (usu a
    ///  Multisig) to send the ether held in this contract
    /// @param _escapeHatchCaller The address of a trusted account or contract to
    ///  call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller` cannot move
    ///  funds out of `escapeHatchDestination`
    function TokenEscapable(address _escapeHatchCaller, address _escapeHatchDestination)
        Escapable(_escapeHatchCaller,_escapeHatchDestination)
    {
    }

    /// @notice The `blacklistEscapeTokens()` marks a token in a whitelist to be
    ///   escaped. The proupose is to be done at construction time.
    /// @param _tokens the 
    function blacklistEscapeTokens(address[] _tokens) internal {
        for (uint i=0;i<_tokens.length;i++) {
            escapeBlacklist[_tokens[i]] = true;
        }
        EscapeHatchBlackistedTokens(_tokens);
    }

    /// @notice The `escapeHatch()` should only be called as a last resort if a
    /// security issue is uncovered or something unexpected happened
    /// @param _token to transfer, use 0x0 for ethers
    function escapeHatch(address _token) public onlyEscapeHatchCaller {   
       require(escapeBlacklist[_token]==false);

       uint256 balance;

       if (_token == 0x0) {
            balance = this.balance;
            escapeHatchDestination.transfer(balance);
            EscapeHatchCalled(_token, balance);
            return;
        }

        ERC20 token = ERC20(_token);
        balance = token.balanceOf(this);
        token.transfer(escapeHatchDestination, balance);
        EscapeHatchCalled(_token, balance);
    }

    /// @notice The `escapeHatch()` should only be called as a last resort if a
    /// security issue is uncovered or something unexpected happened
    function escapeHatch() public onlyEscapeHatchCaller {
        escapeHatch(0x0);
    } 

    event EscapeHatchBlackistedTokens(address[] tokens);
    event EscapeHatchCalled(address token, uint amount);
}
