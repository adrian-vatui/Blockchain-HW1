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

    // Producer => bool
    mapping(address => bool) private producers;
    // Producer => productId => product
    mapping(address => mapping(uint => Product)) products;
    // Producer => last index for id
    mapping(address => uint) currentIndexForProducer;

    function setRegistrationTax(uint newRegistrationTax) external onlyOwner {
        registrationTax = newRegistrationTax;
    }

    function getRegistrationTax() external view returns (uint) {
        return registrationTax;
    }

    // PRODUCERS

    function registerProducer() external payable {
        require(msg.value >= registrationTax, "Not enough credits.");

        producers[msg.sender] = true;

        payable(msg.sender).transfer(msg.value - registrationTax);
        payable(owner).transfer(registrationTax);
    }

    function isProducerRegistered(address producerAddress) external view returns (bool) {
        return producers[producerAddress];
    }

    // PRODUCTS

    function registerProduct(Product calldata product) external returns(uint, Product memory) {
        require(producers[msg.sender] == true, "Caller isn't a registered producer.");
        require(product.producer == msg.sender, "Product producer isn't the same as caller.");
        
        currentIndexForProducer[msg.sender] = currentIndexForProducer[msg.sender] + 1;
        uint productId = currentIndexForProducer[msg.sender];
        products[msg.sender][productId] = product;

        return (productId, product);
    }

    function isProductRegistered(uint productId) external view returns (bool) {
        return products[msg.sender][productId].producer != address(0);
    }

    function isProductRegistered(address producerAddress, uint productId) external view returns (bool) {
        return products[producerAddress][productId].producer != address(0);
    }

    function getProduct(uint productId) external view returns (Product memory) {
        require(products[msg.sender][productId].producer != address(0), "Product does not exist");

        return products[msg.sender][productId];
    }

    function getProduct(address producerAddress, uint productId) external view returns (Product memory) {
        require(products[producerAddress][productId].producer != address(0), "Product does not exist");

        return products[producerAddress][productId];
    }
}