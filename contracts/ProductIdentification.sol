// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Owned.sol";

/**
 * @title ProductIdentification
 * @dev TODO write
 */
contract ProductIdentification is Owned {
    struct Product {
        address producer;
        string name;
        uint volume;
    }

    uint registrationTax;
    mapping(address => bool) private registeredProducers;
    mapping(uint => Product) private registeredProducts;

    function setRegistrationTax(uint newRegistrationTax) external onlyOwner {
        registrationTax = newRegistrationTax;
    }

    function getRegistrationTax() external view returns (uint) {
        return registrationTax;
    }

    function registerProducer() external payable {
        require(registrationTax <= msg.value, "Registration tax wasn't payed");

        registeredProducers[msg.sender] = true;
    }

    function isRegisteredProducer() external view returns (bool) {
        return registeredProducers[msg.sender];
    }

    function isRegisteredProducer(address producerAddress) external view returns (bool) {
        return registeredProducers[producerAddress];
    }

    function registerProduct(uint productId, Product calldata product) external {
        require(registeredProducers[msg.sender] == true, "Caller isn't a registered producer");
        require(product.producer == msg.sender, "Product producer isn't the same as caller");

        registeredProducts[productId] = product;
    }
}