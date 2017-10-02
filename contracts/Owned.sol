pragma solidity ^0.4.15;


/// @title SafeOwned
/// @dev The SafeOwned contract has an owner address, and provides basic authorization control functions, this simplifies
/// & the implementation of "user permissions".
contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    function Owned() {
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
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

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    function proposeOwnership(address _newOwnerCandidate) onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the perviously proposed owner.
    function acceptOwnership() {
        require(msg.sender == newOwnerCandidate);

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

    /// @dev Removes the ownership of the contract. Since this operation cannot be
    ///      undone in any way, 0xdece (ntralized) is requiered aa a confirmation
    ///      parameter
    /// @param _dece The 0xdece address
    function removeOwnership(address _dece) onlyOwner {
        require(_dece == 0xdece);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        OwnershipRemoved();     
    }

} 
