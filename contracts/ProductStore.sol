// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Owned.sol";
import "./ProductIdentification.sol";
import "./ProductDeposit.sol";

contract ProductStore is Owned {
    address payable private productIdentificationAddress;
    ProductIdentification private productIdentification;

    address payable private productDepositAddress;
    ProductDeposit private productDeposit;

    event sellEvent(string);

    struct PricedProduct {
        uint price;
        uint quantity;
    }

    // Producer => productId => quantity
    mapping(address => mapping(uint => PricedProduct)) products;

    function setProductIdentificationContractAddress(address newProductIdentificationAddress) external onlyOwner {
        productIdentificationAddress = payable(newProductIdentificationAddress);
        productIdentification = ProductIdentification(productIdentificationAddress);
    }

    function setProductDepositContractAddress(address newProductDepositAddress) external onlyOwner {
        productDepositAddress = payable(newProductDepositAddress);
        productDeposit = ProductDeposit(productDepositAddress);
    }

    function addProductToStore(address producer, uint productId, uint quantity, uint price) external onlyOwner {
        productDeposit.extractProduct(producer, productId, quantity);

        products[producer][productId] = PricedProduct(price, quantity);
    }

    function setPriceToProduct(address producer, uint productId, uint price) external onlyOwner {
        require(products[producer][productId].quantity != 0, "There must be products in store.");

        products[producer][productId].price = price;
    }

    function checkProductAvailability(address producer, uint productId) external view returns (bool) {
        if (products[producer][productId].quantity <= 0) {
            return false;
        }

        return true;
    }

    function isProductAuthentic(address producer, uint productId) external view returns (bool) {
        if (productIdentification.getProduct(producer, productId).producer == address(0)) {
            return false;
        }

        return true;
    }

    function buyProduct(address producer, uint productId, uint quantity) external payable returns (ProductIdentification.Product memory, uint) {
        PricedProduct memory product = products[producer][productId];
        require(product.quantity - quantity >= 0, "There must be enough products in store.");

        product.quantity = product.quantity - quantity;
        uint payment = quantity * product.price;

        payable(producer).transfer(payment / 2);
        payable(owner).transfer(payment / 2);

        return (productIdentification.getProduct(producer, productId), quantity);
    }
}