const SimpleStorage = artifacts.require("SimpleStorage");
module.exports = async (deployer) => {
    await deployer.deploy(SimpleStorage);
    // await deployer.deploy(SimpleStorage, 5, { value: 1000000000 });
    // var instance = await SimpleStorage.deployed();
    // console.log(await instance.get());
} 