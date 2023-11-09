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

    // ProductId => quantity
    mapping(uint => PricedProduct) products;

    function setProductIdentificationContractAddress(address newProductIdentificationAddress) external onlyOwner {
        productIdentificationAddress = payable(newProductIdentificationAddress);
        productIdentification = ProductIdentification(productIdentificationAddress);
    }

    function setProductDepositContractAddress(address newProductDepositAddress) external onlyOwner {
        productDepositAddress = payable(newProductDepositAddress);
        productDeposit = ProductDeposit(productDepositAddress);
    }

    function addProductToStore(uint productId, uint quantity, uint price) external onlyOwner {
        productDeposit.extractProduct(productId, quantity);

        products[productId] = PricedProduct(price, quantity);
    }

    function setPriceForProduct(uint productId, uint price) external onlyOwner {
        require(products[productId].quantity != 0, "There must be products in store.");

        products[productId].price = price;
    }

    function checkProductAvailability(uint productId) external view returns (bool) {
        if (products[productId].quantity <= 0) {
            return false;
        }

        return true;
    }

    function isProductAuthentic(uint productId) external view returns (bool) {
        if (productIdentification.getProduct(productId).producer == address(0x0)) {
            return false;
        }

        return true;
    }

    function buyProduct(uint productId, uint quantity) external payable returns (ProductIdentification.Product memory, uint) {
        PricedProduct memory product = products[productId];
        uint payment = quantity * product.price;
        require(product.quantity >= quantity, "There must be enough products in store.");
        require(msg.value >= payment, "Not enough credits.");

        products[productId].quantity = product.quantity - quantity;

        address producer = productIdentification.getProduct(productId).producer;
        payable(producer).transfer(payment / 2);
        payable(owner).transfer(payment / 2);

        return (productIdentification.getProduct(productId), quantity);
    }
}