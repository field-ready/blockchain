pragma solidity ^0.4.4;

// Field Ready MakerNet Ethereum Smart Contract
// Distributed Manufacturing Contracting, Payment & Quality Assurance Engine
// Contract version: 1.3 beta | Daniel James Paterson
// Contract run: PROTO0001

// Import string function library from local
import "./StringUtils.sol";

contract FieldReady {

    // Restrict access to known Field Ready test participants

        // Set Field Ready test wallet addresses
        address FieldReadyAdr   = 0x6C0cD5fff7d9Af54D711e6BCe4cE8dD7AaD7939c;
        address CustomerAdr     = 0xa86406131Cd158c225dAFdeFc823D44aeC0BC699;
        address Supplier1Adr    = 0x3EA2552CEe84400ECc1CC4140E7C495B8C3c0e5C;
        address Supplier2Adr    = 0x726445E33163c37c2734a263d45753f6a8Ce4b96;
        address Supplier3Adr    = 0x7054c2f30Bff875880E899A43bf2daCe71E2dA0c;
        address QualityCtrlAdr  = 0x5387E0387C1ec49DfF7a63802cAD0AD8800e8F4b;
        address ThisContractAdr = address(this);

        modifier FRonly { if(      msg.sender == FieldReadyAdr
                                || msg.sender == CustomerAdr
                                || msg.sender == Supplier1Adr                               
                                || msg.sender == Supplier2Adr                               
                                || msg.sender == Supplier3Adr                                
                                || msg.sender == QualityCtrlAdr                                
                                || msg.sender == ThisContractAdr                               
           ) { _; } else { revert(); }
        }
        
    // Declarations of variables
    
        // Customer data
            string  _CustomerName;               // Customer name
            string  _CustomerCode;               // 4-digit customer code
            address _CustomerWallet;	         // Customer wallet address
        
        // Supplier data
        
            // Supplier data structures
                
                // Supplier meta data
                struct SupplierMetaData {
                    bytes4  _SupplierCode;          // 4-digit supplier code   
                    string	_SupplierName;	        // Supplier name
                    address	_SupplierWallet;	    // Supplier wallet address
                    string	_SupplierAgreeFlag;	    // Supplier agreement flag
                    string  _CustomerAgreeFlag;	    // Customer agreement flag
                    string  _PositionFlag;          // Process position flag
                    address	_SupplierDesignHash;	// Supplier's design hash
                    address	_SupplierContractHash;	// Supplier's contract hash
                    address	_CustomerDesignHash;    // Customer's design hash
                    address	_CustomerContractHash;	// Customer's contract hash
                }
                
                // Supplier order data
                struct SupplierOrderData {
                    bytes4  _SupplierCode;       // 4-digit supplier code 
                    uint    _Quantity;           // Production quantity
                    uint	_DeliveryDate;	     // Delivery date
                    uint	_PricePerItem;	     // Price per item
                    uint	_AQLTestAmount;	     // AQL test amount
                    uint	_AQLMajorFaults;	 // AQL major faults
                    uint	_AQLMinorFaults;	 // AQL minor faults
                    uint	_UpfrontPayment;	 // Upfront payment (in Wei)
                    uint	_BatchPayment;	     // Pre-batch payment (in Wei)
                    uint	_FinalPayment;	     // Final payment (in Wei)
                    uint	_FinalPaymentDate;	 // Final payment date
                
                    // Process position flag value table
                        // DA : Design and contract have been approved
                        // FA : Quality of first-off has been approved
                        // FR : Quality of first-off has been rejected
                        // MA : Quality of main batch has been approved
                        // MR : Quality of main batch has been rejected
                        
                    // Customer and Supplier aggreement flag
                        // A : Agree (Used in combination with signer address)
                }

                // Supplier codes registry    
                bytes4[] _SupplierRegistry;
            
            // Data maps for multiple suppliers
                mapping(bytes4 => SupplierMetaData) SuppliersMeta;
                mapping(bytes4 => SupplierOrderData) SuppliersOrder;

    // Events emitted by contract
    
        // Design and contract signed off by customer
            event CustomerSignOff( 
                    string indexed CustomerName,
                    bytes4 indexed SupplierCode,
                    string indexed PositionFlag);

        // Design and contract signed off by supplier
           event SupplierSignOff( 
                    bytes4 indexed SupplierCode,
                    string indexed CustomerName,
                    string indexed PositionFlag);
            
        // First-off quality approved
            event FirstOffApproved(
                    string indexed CustomerName,
                    bytes4 indexed SupplierCode,
                    string indexed PositionFlag);
            
        // First-off quality rejected
            event FirstOffRejected (
                    string indexed CustomerName,
                    bytes4 indexed SupplierCode,
                    string indexed PositionFlag);

        // Main batch quality approved
            event MainBatchApproved(
                    string indexed CustomerName,
                    bytes4 indexed SupplierCode,
                    string indexed PositionFlag);
            
        // Main batch quality rejected
            event MainBatchRejected(
                    string indexed CustomerName,
                    bytes4 indexed SupplierCode,
                    string indexed PositionFlag);

    // Contract functions

        // Data input functions
         
            // Input customer data
                function InputCustomerData (
                    string  CustomerName,
                    string  CustomerCode,
                    address CustomerWallet) FRonly public {
                    _CustomerName    = CustomerName;
                    _CustomerWallet  = CustomerWallet;
                    _CustomerCode    = CustomerCode;
                }
            
            // Input supplier meta data
                function InputSupplierMetaData(
                    bytes4	SupplierCode,
                    string	SupplierName,
                    address	SupplierWallet) FRonly public {
                    
                    var CurrentSupplierMeta = SuppliersMeta[SupplierCode];

                    CurrentSupplierMeta._SupplierCode      = SupplierCode;
                    CurrentSupplierMeta._SupplierName      = SupplierName;
                    CurrentSupplierMeta._SupplierWallet    = SupplierWallet;
                    
                    // Add supplier code to registry
                    _SupplierRegistry.push(SupplierCode);
                }

            // Input supplier order data
                function InputSupplierOrderData(
                    bytes4	SupplierCode,
                    uint    Quantity,
                    uint	DeliveryDate,
                    uint	PricePerItem,
                    uint	AQLTestAmount,
                    uint	AQLMajorFaults,
                    uint	AQLMinorFaults,
                    uint	UpfrontPayment,
                    uint	BatchPayment,
                    uint	FinalPayment,
                    uint	FinalPaymentDate ) FRonly public {
                    
                    var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                    CurrentSupplierOrder._Quantity          = Quantity;
                    CurrentSupplierOrder._DeliveryDate      = DeliveryDate;
                    CurrentSupplierOrder._PricePerItem      = PricePerItem;
                    CurrentSupplierOrder._AQLTestAmount     = AQLTestAmount;
                    CurrentSupplierOrder._AQLMajorFaults    = AQLMajorFaults;
                    CurrentSupplierOrder._AQLMinorFaults    = AQLMinorFaults;
                    CurrentSupplierOrder._UpfrontPayment    = UpfrontPayment;
                    CurrentSupplierOrder._BatchPayment      = BatchPayment;
                    CurrentSupplierOrder._FinalPayment      = FinalPayment;
                    CurrentSupplierOrder._FinalPaymentDate  = FinalPaymentDate;
                }
            
            // Approve final design and supplier contract
            //  and trigger upfront payment
                
                // Customer approval of design and contract

                    function CustomerApproval(
                        bytes4  SupplierCode, 
                        string  CustomerAgreeFlag,
                        address DesignHash,
                        address ContractHash) FRonly public {
                        
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Add design and contract hashes
                        CurrentSupplierMeta._CustomerDesignHash 
                            = DesignHash;
                        CurrentSupplierMeta._CustomerContractHash 
                            = ContractHash;

                        // Set customer agreement flag
                        CurrentSupplierMeta._CustomerAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment and 
                        //  event if both customer and supplier have signed off
                        if ( 
                StringUtils.equal(CurrentSupplierMeta._CustomerAgreeFlag,"A") &&
                StringUtils.equal(CurrentSupplierMeta._SupplierAgreeFlag,"A") ){
                                CurrentSupplierMeta._PositionFlag = "DA";
 
                                // Trigger upfront payment
                                    SendSupplierPayment(
                                        CurrentSupplierMeta._SupplierWallet,
                                        CurrentSupplierOrder._UpfrontPayment);

                                // Trigger event
                                    CustomerSignOff( 
                                        _CustomerName,
                                        CurrentSupplierMeta._SupplierCode,
                                        CurrentSupplierMeta._PositionFlag); }
                    }
                
                // Supplier approval of design and contract

                    function SupplierApproval(
                        bytes4  SupplierCode, 
                        string  SupplierAgreeFlag,
                        address DesignHash,
                        address ContractHash
                        ) FRonly public {
                    
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Add design and contract hashes
                        CurrentSupplierMeta._SupplierDesignHash 
                            = DesignHash;
                        CurrentSupplierMeta._SupplierContractHash 
                            = ContractHash;

                        // Set customer agreement flag
                        CurrentSupplierMeta._SupplierAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment and 
                        //  event if both customer and supplier have signed off
                        if ( 
                StringUtils.equal(CurrentSupplierMeta._CustomerAgreeFlag,"A") &&
                StringUtils.equal(CurrentSupplierMeta._SupplierAgreeFlag,"A") ){
                                CurrentSupplierMeta._PositionFlag = "DA";
 
                                // Trigger upfront payment
                                    SendSupplierPayment(
                                        CurrentSupplierMeta._SupplierWallet,
                                        CurrentSupplierOrder._UpfrontPayment);

                                // Trigger event
                                    SupplierSignOff( 
                                        CurrentSupplierMeta._SupplierCode,
                                        _CustomerName,
                                        CurrentSupplierMeta._PositionFlag); }
                    }
                
            // Input first-off quality control result 
            //  and trigger pre-batch payment

                    function InputFirstOffQuality(
                        bytes4  SupplierCode,
                        string  QualityFirstOff) FRonly public  {

                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Update process postion flag
                            QualityFirstOff = QualityFirstOff;
                            if (StringUtils.equal(QualityFirstOff, "A")) 
                                {CurrentSupplierMeta._PositionFlag = "MA";}
                            if (StringUtils.equal(QualityFirstOff, "R")) 
                                {CurrentSupplierMeta._PositionFlag = "MR";}
                        
                        // Trigger pre-batch payment
                        if (StringUtils.equal(QualityFirstOff, "A")) { 
                            SendSupplierPayment(
                                CurrentSupplierMeta._SupplierWallet,
                                CurrentSupplierOrder._BatchPayment);
                        }
                        
                        // Trigger events
                            if (StringUtils.equal(QualityFirstOff, "A")) {
                                FirstOffApproved(
                                    _CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta._PositionFlag); }
                            if (StringUtils.equal(QualityFirstOff, "R")) {
                                FirstOffRejected (
                                    _CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta._PositionFlag); }
                    }

            // Input main batch quality control result 
            //  and trigger final payment

                    function InputMainBatchQuality(
                        bytes4  SupplierCode,
                        string  QualityMainBatch) FRonly public  {
 
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode]; 
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode]; 
 
                        // Update process postion flag
                            QualityMainBatch = QualityMainBatch;

                            if (StringUtils.equal(QualityMainBatch, "A")) 
                                {CurrentSupplierMeta._PositionFlag = "MA";}
                            if (StringUtils.equal(QualityMainBatch, "R")) 
                                {CurrentSupplierMeta._PositionFlag = "MR";}
                        
                        // Trigger final payment
                        if (StringUtils.equal(QualityMainBatch, "A")) { 
                            SendSupplierPayment(
                                CurrentSupplierMeta._SupplierWallet,
                                CurrentSupplierOrder._FinalPayment);
                        }
                        
                        // Trigger events
                            if (StringUtils.equal(QualityMainBatch, "A")) {
                                MainBatchApproved(
                                    _CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta._PositionFlag); }
                            if (StringUtils.equal(QualityMainBatch, "R")) {
                                MainBatchRejected (
                                    _CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta._PositionFlag); }
                    }

        // Payment functions
            
            // Fallback function to allow contract to receive customer payment
                function() payable public { }           
            
            // Send money from contract to suppliers
                function SendSupplierPayment (
                    address PaymentReceiver,
                    uint PaymentAmount) FRonly payable public {
                        PaymentReceiver.transfer(PaymentAmount);
                }

        // Information recall functions

            // Display customer information
                function DisplayCustomerInfo() 
                    FRonly public constant returns(
                        string CustomerName, 
                        string CustomerCode){
                            return (_CustomerName, _CustomerCode);
                }
                
            // Display supplier process position
                
                // Supplier 1
                function DisplaySupplier1Position() 
                    FRonly public constant returns(
                        bytes4 SupplierCode,
                        string ProcessPosition){
                            var CurrentSupplierMeta 
                                = SuppliersMeta[SupplierCode];
                            return(_SupplierRegistry[0],
                                   CurrentSupplierMeta._PositionFlag );
                }
                
                // Supplier 2
                function DisplaySupplier2Position() 
                    FRonly public constant returns(
                        bytes4 SupplierCode,
                        string ProcessPosition){
                            var CurrentSupplierMeta 
                                = SuppliersMeta[SupplierCode];
                            return(_SupplierRegistry[1],
                                   CurrentSupplierMeta._PositionFlag );
                }
                
                // Supplier 3
                function DisplaySupplier3Position() 
                    FRonly public constant returns(
                        bytes4 SupplierCode,
                        string ProcessPosition){
                            var CurrentSupplierMeta 
                                = SuppliersMeta[SupplierCode];
                            return(_SupplierRegistry[2],
                                   CurrentSupplierMeta._PositionFlag );
                }
}