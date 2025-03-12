// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract MediTrack {
    struct MedicineBatch {
        string batchId;
        string name;
        string manufacturer;
        string expiryDate;
        address currentHolder;
        bool isAuthentic;
    }

    mapping(string => MedicineBatch) public medicineBatches;
    address public owner;
    
    event BatchRegistered(string batchId, string name, string manufacturer);
    event BatchTransferred(string batchId, address newHolder);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function registerMedicineBatch(
        string memory _batchId, 
        string memory _name, 
        string memory _manufacturer, 
        string memory _expiryDate
    ) public onlyOwner {
        require(bytes(medicineBatches[_batchId].batchId).length == 0, "Batch already exists");
        
        medicineBatches[_batchId] = MedicineBatch({
            batchId: _batchId,
            name: _name,
            manufacturer: _manufacturer,
            expiryDate: _expiryDate,
            currentHolder: msg.sender,
            isAuthentic: true
        });
        
        emit BatchRegistered(_batchId, _name, _manufacturer);
    }
    
    function transferBatch(string memory _batchId, address _newHolder) public {
        require(medicineBatches[_batchId].isAuthentic, "Batch is not authentic");
        require(msg.sender == medicineBatches[_batchId].currentHolder, "Only current holder can transfer");
        
        medicineBatches[_batchId].currentHolder = _newHolder;
        emit BatchTransferred(_batchId, _newHolder);
    }
    
    function verifyMedicine(string memory _batchId) public view returns (string memory, string memory, string memory, string memory, address, bool) {
        MedicineBatch memory batch = medicineBatches[_batchId];
        require(bytes(batch.batchId).length > 0, "Medicine not found");
        
        return (batch.batchId, batch.name, batch.manufacturer, batch.expiryDate, batch.currentHolder, batch.isAuthentic);
    }
}
