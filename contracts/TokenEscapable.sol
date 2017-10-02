pragma solidity ^0.4.15;

import "./Escapable.sol";
import "./ERC20.sol";


contract TokenEscapable is Escapable {

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
    /// @param _token the be bloacklisted for escape
    function blacklistEscapeToken(address _token) internal {
        escapeBlacklist[_token] = true;
        EscapeHatchBlackistedToken(_token);
    }

    function isTokenEscapable(address _token) constant public returns (bool) {
        return escapeBlacklist[_token];
    }

    /// @notice The `escapeHatch()` should only be called as a last resort if a
    /// security issue is uncovered or something unexpected happened
    /// @param _token to transfer, use 0x0 for ethers
    function escapeHatchToken(address _token) public onlyEscapeHatchCallerOrOwner {   
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
    function escapeHatch() public onlyEscapeHatchCallerOrOwner {
        escapeHatchToken(0x0);
    } 

    event EscapeHatchBlackistedToken(address token);
    event EscapeHatchCalled(address token, uint amount);
}
