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

    uint private registrationTax;
    mapping(address => bool) private registeredProducers;
    mapping(uint => Product) private registeredProducts;

    function setRegistrationTax(uint newRegistrationTax) external onlyOwner {
        registrationTax = newRegistrationTax;
    }

    function getRegistrationTax() external view returns (uint) {
        return registrationTax;
    }

    function registerProducer() external payable {
        require(msg.value >= registrationTax, "Registration tax wasn't payed");

        registeredProducers[msg.sender] = true;
        payable(msg.sender).transfer(msg.value - registrationTax);
    }

    function registerProduct(uint productId, Product calldata product) external {
        require(registeredProducers[msg.sender] == true, "Caller isn't a registered producer");
        require(product.producer == msg.sender, "Product producer isn't the same as caller");
        // TODO: check if productId and validate product details.

        registeredProducts[productId] = product;
    }

    function isRegisteredProducer() external view returns (bool) {
        return registeredProducers[msg.sender];
    }

    function isRegisteredProducer(address producerAddress) external view returns (bool) {
        return registeredProducers[producerAddress];
    }
}