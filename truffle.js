module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      from: "0x627306090abaB3A6e1400e9345bC60c78a8BEf57",
      network_id: "5777"
    }
    // ropsten: {
    //   host: "localhost",
    //   port: 8545,
    //   network_id: "3"
    // },
    // rinkeby: {
    //   host: "localhost", // Connect to geth on the specified
    //   port: 8545,
    //   network_id: 4
    //   // gas: 4612388 // Gas limit used for deploys
    // }
    // PRODUCTION: {
    //   host: "localhost",
    //   port: 8545,
    //   network_id: "1",
    //   from: "0x0"
    // }
  }
};