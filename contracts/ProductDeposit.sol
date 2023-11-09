// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Owned.sol";
import "./ProductIdentification.sol";

contract ProductDeposit is Owned {
    uint private taxPerVolumeUnit;
    uint private maxVolume;
    uint private usedVolume;

    // Producer => store
    mapping(address => address) private authorizedStores;

    struct ProductWithQuantity {
        uint productId;
        ProductIdentification.Product product;
        uint quantity;
    }
    // Producer => productId => productWithQuantity
    mapping(address => mapping(uint => ProductWithQuantity)) products;

    address payable private productIdentificationAddress;
    ProductIdentification private productIdentification;

    function setProductIdentificationContractAddress(address newProductIdentificationAddress) external onlyOwner {
        productIdentificationAddress = payable(newProductIdentificationAddress);
        productIdentification = ProductIdentification(productIdentificationAddress);
    }

    function setTaxPerVolumeUnit(uint newTaxPerVolumeUnit, uint) external onlyOwner {
        taxPerVolumeUnit = newTaxPerVolumeUnit;
    }

    function getTaxPerVolumeUnit() external view returns (uint) {
        return taxPerVolumeUnit;
    }
    
    function setMaxDepositVolume(uint newMaxDepositVolume, uint) external onlyOwner {
        maxVolume = newMaxDepositVolume;
    }

    function getMaxDepositVolume() external view returns (uint) {
        return maxVolume;
    }

    function depositProduct(ProductWithQuantity calldata productWithQuantity) external payable {
        require(productIdentification.isProducerRegistered(msg.sender), "The producer is not authorized.");
        require(productIdentification.isProductRegistered(msg.sender, productWithQuantity.productId), "Product does not exist.");

        uint productsVolume = productWithQuantity.quantity * productWithQuantity.product.volume;
        require(usedVolume + productsVolume <= maxVolume, "Not enough space.");

        uint price = taxPerVolumeUnit * productsVolume;
        require(msg.value >= price, "Not enough credits.");

        usedVolume += productsVolume;
        products[msg.sender][productWithQuantity.productId] = productWithQuantity;

        payable(msg.sender).transfer(msg.value - price);
        payable(owner).transfer(price);
    }

    // VERIFICATA
    function registerStore(address storeAddress) external {
        require(productIdentification.isProducerRegistered(msg.sender), "The producer is not authorized.");

        authorizedStores[msg.sender] = storeAddress;
    }

    // VERIFICATA
    function extractProduct(address producer, uint productId, uint quantity) external returns (ProductIdentification.Product memory, uint) {
        bool isAuthorized = msg.sender == producer  || msg.sender == authorizedStores[producer];
        require(isAuthorized, "Caller is not the producer or an authorized store.");

        ProductWithQuantity memory productWithQuantity = products[producer][productId];

        require(quantity <= productWithQuantity.quantity, "Not enough products.");

        productWithQuantity.quantity = productWithQuantity.quantity - quantity;
        usedVolume = usedVolume - quantity * productWithQuantity.product.volume;

        return (productWithQuantity.product, quantity);
    }
}