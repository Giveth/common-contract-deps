module.exports = {
    testCommand: 'truffle test --network coverage',
    copyNodeModules: true,
    skipFiles: [
        'TokenEscapable.sol', 
        'SafeMath.sol',
        'ERC20.sol',
        'test/TestToken.sol',
        'test/TestPayableEscapable.sol',
        'helpers/Migrations.sol'
    ]
}