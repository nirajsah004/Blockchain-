// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MySupplyChain {
    // keeping track of who can do what
    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isWorker;
    
    uint256 private nextId = 1;
    
    // different states a package can be in
    enum Status {
        Pending,    // just created
        Shipping,   // on the way
        Warehouse,  // at our warehouse
        Delivered   // done!
    }
    
    struct Package {
        uint256 id;
        string stuff;     // what's in it
        address sender;
        Status status;
        uint256 when;     // last update time
    }
    
    // all our packages
    mapping(uint256 => Package) public packages;
    
    // quick way to check if caller is allowed to do stuff
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "nope - admins only!");
        _;
    }
    
    modifier onlyWorker() {
        require(isWorker[msg.sender] || isAdmin[msg.sender], "not authorized!");
        _;
    }
    
    // when we start, maker of contract is the first admin
    constructor() {
        isAdmin[msg.sender] = true;
    }
    
    // admin can add workers
    function addWorker(address worker) external onlyAdmin {
        isWorker[worker] = true;
    }
    
    // admin can add other admins
    function addAdmin(address newAdmin) external onlyAdmin {
        isAdmin[newAdmin] = true;
    }
    
    // create new package
    function createPackage(string memory _stuff) external onlyWorker returns (uint256) {
        uint256 packageId = nextId;
        
        packages[packageId] = Package({
            id: packageId,
            stuff: _stuff,
            sender: msg.sender,
            status: Status.Pending,
            when: block.timestamp
        });
        
        nextId++;
        return packageId;
    }
    
    // update where package is at
    function updateStatus(uint256 packageId, Status newStatus) external onlyWorker {
        require(packageId < nextId, "package doesn't exist!");
        require(newStatus <= Status.Delivered, "invalid status!");
        
        Package storage pkg = packages[packageId];
        // can't change if already delivered
        require(pkg.status != Status.Delivered, "package already delivered!");
        
        pkg.status = newStatus;
        pkg.when = block.timestamp;
    }
    
    // anyone can check package status
    function getPackage(uint256 packageId) external view returns (
        string memory stuff,
        address sender,
        Status status,
        uint256 when
    ) {
        require(packageId < nextId, "package doesn't exist!");
        Package storage pkg = packages[packageId];
        return (pkg.stuff, pkg.sender, pkg.status, pkg.when);
    }
}
