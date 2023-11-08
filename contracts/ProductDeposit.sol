// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Owned.sol";
import "./ProductIdentification.sol";

contract ProductDeposit is Owned {
    uint private taxPerVolumeUnit;
    uint private maxDepositVolume;
    address payable private productIdentificationAddress;

    function setProductIdentificationContractAddress(address newProductIdentificationAddress) external {
        productIdentificationAddress = payable(newProductIdentificationAddress);
    }

    function setTaxPerVolumeUnit(uint newTaxPerVolumeUnit, uint) external onlyOwner {
        taxPerVolumeUnit = newTaxPerVolumeUnit;
    }

    function getTaxPerVolumeUnit() external view returns (uint) {
        return taxPerVolumeUnit;
    }
    
    function setMaxDepositVolume(uint newMaxDepositVolume, uint) external onlyOwner {
        maxDepositVolume = newMaxDepositVolume;
    }

    function getMaxDepositVolume() external view returns (uint) {
        return maxDepositVolume;
    }

    function depositProduct(uint productId) external {
        
    }
}