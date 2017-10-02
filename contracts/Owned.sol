pragma solidity ^0.4.15;

/// @title Owned
/// @author Adria Massanet
/// @notice The Owned contract has an owner address, and provides basic 
///  authorization control functions, this simplifies & the implementation of
///  "user permissions"
contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    /// @dev The constructor sets the `msg.sender` as the`owner` of the contract
    function Owned() {
        owner = msg.sender;
    }

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner.
    function changeOwnership(address _newOwner) onlyOwner {
        require(_newOwner != 0x0);

        address oldOwner = owner;
        owner = _newOwner;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

    /// @notice `onlyOwner` Proposes to transfer control of the contract to a
    ///  new owner
    /// @param _newOwnerCandidate The address being proposed as the new owner
    function proposeOwnership(address _newOwnerCandidate) onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @notice Can only be called by the `newOwnerCandidate`, accepts the
    ///  transfer of ownership
        require(msg.sender == newOwnerCandidate);

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

    /// @notice Decentralizes the contract, this operation cannot be undone 
    /// @param _dece `0xdece` has to be entered for this function to work
    function removeOwnership(address _dece) onlyOwner {
        require(_dece == 0xdece);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        OwnershipRemoved();     
    }

} 
