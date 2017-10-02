/* global artifacts */
/* global contract */
/* global web3 */
/* global assert */

const assertFail = require("./helpers/assertFail.js");

const TestPayableTokenEscapable = artifacts.require("../contracts/test/TestPayableTokenEscapable.sol");
const TestToken = artifacts.require("../contracts/test/TestToken.sol");

contract("TokenEscapable", (accounts) => {
    const ONEWEI = web3.toBigNumber("1");
    const {
        0: owner,
        1: escapeHatchCaller,
        2: escapeHatchDestination,
        3: someoneaddr,
        9: sometoken,
    } = accounts;

    it("internal variables are created in constructor", async () => {
        const escapable = await TestPayableTokenEscapable.new(
          sometoken,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );

        assert.equal(await escapable.escapeHatchCaller(), escapeHatchCaller);
        assert.equal(await escapable.escapeHatchDestination(), escapeHatchDestination);
    });

    it("prevent non-authorized call to escapeHatch()", async () => {
        const escapable = await TestPayableTokenEscapable.new(
          sometoken,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );

        try {
            await escapable.escapeHatch({ from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("escapeHatch() sends ether amount to the destination", async () => {
        const escapable = await TestPayableTokenEscapable.new(
          sometoken,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );

        const balance = web3.eth.getBalance(escapeHatchDestination);
        await escapable.send(ONEWEI, { from: someoneaddr });

        const result = await escapable.escapeHatch({
            from: escapeHatchCaller,
        });
        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "EscapeHatchCalled");
        assert.equal(result.logs[ 0 ].args.amount, "1");

        assert.isTrue(
            web3.eth.getBalance(escapeHatchDestination).equals(balance.plus(ONEWEI)));
    });

    it("escapeHatch(_token) sends token amount to the destination", async () => {
        const escapable = await TestPayableTokenEscapable.new(
          sometoken,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );

        const token = await TestToken.new(owner, 1000);
        await token.transfer(escapable.address, 1000);
        assert.equal(await token.balanceOf(escapable.address), 1000);

        const result = await escapable.escapeHatchToken(token.address, {
            from: escapeHatchCaller,
        });
        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "EscapeHatchCalled");
        assert.equal(result.logs[ 0 ].args.amount, 1000);
        assert.equal(result.logs[ 0 ].args.token, token.address);

        assert.equal(await token.balanceOf(escapeHatchDestination), 1000);
    });

    it("can blacklist escape of ethers", async () => {
        const escapable = await TestPayableTokenEscapable.new(
          0x0,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );
        assert.equal(await escapable.isTokenEscapable(0x0), true);
        assert.equal(await escapable.isTokenEscapable(escapable.address), false);
        try {
            await escapable.escapeHatch({ from: escapeHatchCaller });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("can blacklist escape of tokens", async () => {
        const token = await TestToken.new(owner, 1000);

        const escapable = await TestPayableTokenEscapable.new(
          token.address,
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );

        assert.equal(await escapable.isTokenEscapable(token.address), true);
        assert.equal(await escapable.isTokenEscapable(0x0), false);

        try {
            await escapable.escapeHatchToken(token.address, { from: escapeHatchCaller });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });
});
