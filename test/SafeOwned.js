/* global artifacts */
/* global contract */
/* global assert */

const assertFail = require("./helpers/assertFail.js");

const SafeOwned = artifacts.require("../contracts/SafeOwned.sol");

contract("SafeOwned", (accounts) => {
    let owned;

    const {
        0: owner1,
        1: owner2,
        3: someoneaddr,
    } = accounts;

    beforeEach(async () => {
        owned = await SafeOwned.new();
    });

    it("should have an owner assigned to msg.sender initially", async () => {
        const contractOwner = await owned.owner();
        assert.equal(contractOwner, owner1);
    });

    it("changes owner after transferOwnership & acceptOwnership call, and a log is genearated", async () => {
        let result = await owned.transferOwnership(owner2);
        assert.equal(await owned.newOwnerCandidate(), owner2);

        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "OwnershipRequested");
        assert.equal(result.logs[ 0 ].args.by, owner1);
        assert.equal(result.logs[ 0 ].args.to, owner2);

        result = await owned.acceptOwnership({ from: owner2 });
        assert.equal(await owned.newOwnerCandidate(), 0);
        assert.equal(await owned.owner(), owner2);

        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "OwnershipTransferred");
        assert.equal(result.logs[ 0 ].args.from, owner1);
        assert.equal(result.logs[ 0 ].args.to, owner2);
    });

    it("non-owners cannot call transferOwnership", async () => {
        try {
            await owned.transferOwnership(owner2, { from: owner2 });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("non-owners cannot call transferOwnership", async () => {
        try {
            await owned.transferOwnership(someoneaddr, { from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("address non proposed for new membership cannot call acceptOwnership", async () => {
        await owned.transferOwnership(owner2);
        try {
            await owned.acceptOwnership({ from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("ownership can be removed", async () => {
        const result = await owned.removeOwnership(0xdead);
        assert.equal(await owned.owner(), 0);
        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "OwnershipRemoved");
    });

    it("ownership cannot be removed without using 0xdead parameter", async () => {
        try {
            await owned.removeOwnership(0xdead1);
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });

    it("ownership cannot be removed by non-owner", async () => {
        try {
            await owned.removeOwnership(0xdead, { from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });
});
