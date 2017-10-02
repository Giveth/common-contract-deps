/* global artifacts */
/* global contract */
/* global web3 */
/* global assert */

const assertFail = require("./helpers/assertFail.js");

const TestPayableEscapable = artifacts.require("../contracts/test/TestPayableEscapable.sol");

contract("Escapable", (accounts) => {
    const ONEWEI = web3.toBigNumber("1");

    const {
        1: escapeHatchCaller,
        2: escapeHatchDestination,
        3: someoneaddr,
    } = accounts;

    let escapable;

    beforeEach(async () => {
        escapable = await TestPayableEscapable.new(
          escapeHatchCaller, // _escapeHatchCaller
          escapeHatchDestination, // _escapeHatchDestination
        );
    });

    it("internal variables are created in constructor", async () => {
        assert.equal(await escapable.escapeHatchCaller(), escapeHatchCaller);
        assert.equal(await escapable.escapeHatchDestination(), escapeHatchDestination);
    });

    it("prevent non-authorized call to escapeHatch()", async () => {
        try {
            await escapable.escapeHatch(0, { from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("prevent non-authorized call to changeEscapeHatchCaller()", async () => {
        try {
            await escapable.changeEscapeCaller(someoneaddr, { from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("changeEscapeCaller() changes the permission", async () => {
        await escapable.changeEscapeCaller(someoneaddr, {
            from: escapeHatchCaller,
        });
        assert.equal(await escapable.escapeHatchCaller(), someoneaddr);
    });

    it("escapeHatch() sends amount to the destination", async () => {
        const balance = web3.eth.getBalance(escapeHatchDestination);
        await escapable.send(ONEWEI, { from: someoneaddr });

        const result = await escapable.escapeHatch(0,{
            from: escapeHatchCaller,
        });
        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "EscapeHatchCalled");
        assert.equal(result.logs[ 0 ].args.amount, "1");
        assert.equal(result.logs[ 0 ].args.destination, escapeHatchDestination);

        assert.isTrue(
      web3.eth
        .getBalance(escapeHatchDestination)
        .equals(balance.plus(ONEWEI)),
    );
    });
});
