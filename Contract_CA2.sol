// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureStatus {
    // Maximum length for status messages to prevent gas attacks
    uint256 public constant MAX_STATUS_LENGTH = 280; // Similar to Twitter's limit
    
    // Custom errors
    error StatusTooLong(uint256 length);
    error EmptyStatus();
    
    // Private mapping for better access control
    mapping(address => string) private statuses;
    
    function setStatus(string calldata newStatus) external {
        // Prevent empty status
        if (bytes(newStatus).length == 0) {
            revert EmptyStatus();
        }
        
        // Prevent excessively long status messages
        if (bytes(newStatus).length > MAX_STATUS_LENGTH) {
            revert StatusTooLong(bytes(newStatus).length);
        }
        
        statuses[msg.sender] = newStatus;
    }
    
    function getStatus(address user) external view returns (string memory) {
        return statuses[user];
    }
}
