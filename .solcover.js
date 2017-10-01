module.exports = {
    testCommand: 'truffle test --network coverage',
    copyNodeModules: true,
    skipFiles: [
        'test/TestPayableEscapable.sol',
        'helpers/Migrations.sol'
    ]
}