pragma solidity ^0.4.15;


/// @title SafeOwned
/// @dev The SafeOwned contract has an owner address, and provides basic authorization control functions, this simplifies
/// & the implementation of "user permissions".
contract SafeOwned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    function SafeOwned() {
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function transferOwnership(address _newOwnerCandidate) onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    function acceptOwnership() {
        require(msg.sender == newOwnerCandidate);
        OwnershipTransferred(owner, newOwnerCandidate);
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;
    }

    /// @dev Removes the ownership of the contract. Since this operation cannot be
    ///      undone in any way, 0xdead is requiered ad a confirmation parameter
    /// @param _dead The 0xdead address
    function removeOwnership(address _dead) onlyOwner {
        require(_dead == 0xdead);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        OwnershipRemoved();     
    }

} 
