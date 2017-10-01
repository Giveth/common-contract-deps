/* global artifacts */
/* global contract */
/* global assert */

const assertFail = require("./helpers/assertFail.js");

const Owned = artifacts.require("../contracts/Owned.sol");

contract("Owned", (accounts) => {
    let owned;

    const {
        0: owner,
        3: someoneaddr,
    } = accounts;

    beforeEach(async () => {
        owned = await Owned.new();
    });

    it("should have an owner assigned to msg.sender initially", async () => {
        const contractOwner = await owned.owner();
        assert.isTrue(contractOwner === owner);
    });

    it("changes owner after changeOwner call, and a log is genearated", async () => {
        const result = await owned.changeOwner(someoneaddr);
        assert.isTrue(await owned.owner() === someoneaddr);

        assert.equal(result.logs.length, 1);
        assert.equal(result.logs[ 0 ].event, "NewOwner");
        assert.equal(result.logs[ 0 ].args.oldOwner, owner);
        assert.equal(result.logs[ 0 ].args.newOwner, someoneaddr);
    });

    it("should prevent non-owners from transfering ownership", async () => {
        try {
            await owned.changeOwner(someoneaddr, { from: someoneaddr });
        } catch (error) {
            return assertFail(error);
        }
        assert.fail("should have thrown before");
    });
});
