pragma solidity ^0.4.4;

// Field Ready MakerNet Ethereum Smart Contract
// Distributed Manufacturing Contracting, Payment & Quality Assurance Engine
// Contract version: 1.2 beta | Daniel James Paterson
// Contract run: PROTO0001

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
            string  CustomerName;           // Customer name
            string  CustomerCode;           // 8-digit customer code
            address CustomerWallet;	        // Customer wallet address
        
        // Supplier data
        
            // Supplier data structures
                
                // Supplier meta data
                struct SupplierMetaData {
                    string  SupplierCode;       //  8-digit supplier code   
                    string	SupplierName;	    //  Supplier name
                    address	SupplierWallet;	    // 	Supplier wallet address
                    bytes1	SupplierAgreeFlag;	// 	Supplier agreement flag
                    bytes1  CustomerAgreeFlag;	//  Customer agreement flag
                    bytes2  PositionFlag;       //  Process position flag
                    string	DesignHash;	        // 	Design hash
                    string	ContractHash;	    // 	Supplier contract hash
                }
                
                // Supplier order data
                struct SupplierOrderData {
                    string  SupplierCode;       //  8-digit supplier code 
                    uint    Quantity;           //  Production quantity
                    uint	DeliveryDate;	    // 	Delivery date
                    uint	PricePerItem;	    // 	Price per item
                    uint	AQLTestAmount;	    // 	AQL test amount
                    uint	AQLMajorFaults;	    // 	AQL major faults
                    uint	AQLMinorFaults;	    // 	AQL minor faults
                    uint	UpfrontPayment;	    // 	Upfront payment (in Wei)
                    uint	BatchPayment;	    // 	Pre-batch payment (in Wei)
                    uint	FinalPayment;	    // 	Final payment (in Wei)
                    uint	FinalPaymentDate;	// 	Final payment date
                
                    // Process position flag value table
                        // DA : Design and contract have been approved
                        // FA : Quality of first-off has been approved
                        // FR : Quality of first-off has been rejected
                        // MA : Quality of main batch has been approved
                        // MR : Quality of main batch has been rejected
                        
                    // Customer and Supplier aggreement flag
                        // A : Agree (Used in combination with signer address)
                }
            
            // Data maps for multiple suppliers
                mapping(string => SupplierMetaData) SuppliersMeta;
                mapping(string => SupplierOrderData) SuppliersOrder;

    // Events emitted by contract
    
        // Design and contract signed off by customer
            event CustomerSignOff( 
                    string indexed CustomerName,
                    string indexed SupplierCode,
                    bytes2 indexed PositionFlag);

        // Design and contract signed off by supplier
           event SupplierSignOff( 
                    string indexed SupplierCode,
                    string indexed CustomerName,
                    bytes2 indexed PositionFlag);
            
        // First-off quality approved
            event FirstOffApproved(
                    string indexed CustomerName,
                    string indexed SupplierCode,
                    bytes2 indexed PositionFlag);
            
        // First-off quality rejected
            event FirstOffRejected (
                    string indexed CustomerName,
                    string indexed SupplierCode,
                    bytes2 indexed PositionFlag);

        // Main batch quality approved
            event MainBatchApproved(
                    string indexed CustomerName,
                    string indexed SupplierCode,
                    bytes2 indexed PositionFlag);
            
        // Main batch quality rejected
            event MainBatchRejected(
                    string indexed CustomerName,
                    string indexed SupplierCode,
                    bytes2 indexed PositionFlag);

    // Contract functions

        // Data input functions
         
            // Input customer data
                function InputCustomerData (
                    string  CustomerName,
                    string  CustomerCode,
                    address CustomerWallet) FRonly public {
                    CustomerName    = CustomerName;
                    CustomerWallet  = CustomerWallet;
                    CustomerCode    = CustomerCode;
                }
            
            // Input supplier meta data
                function InputSupplierMetaData(
                    string	SupplierCode,
                    string	SupplierName,
                    address	SupplierWallet,
                    bytes2  PositionFlag,
                    string	DesignHash,
                    string	ContractHash  ) FRonly public {
                    
                    var CurrentSupplierMeta = SuppliersMeta[SupplierCode];

                    CurrentSupplierMeta.SupplierCode        = SupplierCode;
                    CurrentSupplierMeta.SupplierName    	= SupplierName;
                    CurrentSupplierMeta.SupplierWallet      = SupplierWallet;
                    CurrentSupplierMeta.PositionFlag        = PositionFlag;
                    CurrentSupplierMeta.DesignHash          = DesignHash;
                    CurrentSupplierMeta.ContractHash        = ContractHash;
                }

            // Input supplier order data
                function InputSupplierOrderData(
                    string	SupplierCode,
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

                    CurrentSupplierOrder.Quantity           = Quantity;
                    CurrentSupplierOrder.DeliveryDate       = DeliveryDate;
                    CurrentSupplierOrder.PricePerItem       = PricePerItem;
                    CurrentSupplierOrder.AQLTestAmount      = AQLTestAmount;
                    CurrentSupplierOrder.AQLMajorFaults     = AQLMajorFaults;
                    CurrentSupplierOrder.AQLMinorFaults     = AQLMinorFaults;
                    CurrentSupplierOrder.UpfrontPayment     = UpfrontPayment;
                    CurrentSupplierOrder.BatchPayment       = BatchPayment;
                    CurrentSupplierOrder.FinalPayment       = FinalPayment;
                    CurrentSupplierOrder.FinalPaymentDate   = FinalPaymentDate;
                }
            
            // Approve final design and supplier contract
            //  and trigger upfront payment
                
                // Customer approval of design and contract

                    function CustomerApproval(
                        string  SupplierCode, 
                        bytes1  CustomerAgreeFlag) FRonly public {
                        
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Set customer agreement flag
                        CurrentSupplierMeta.CustomerAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment and 
                        //  event if both customer and supplier have signed off
                        if (CurrentSupplierMeta.CustomerAgreeFlag == "A" &&
                            CurrentSupplierMeta.SupplierAgreeFlag == "A") {
                                CurrentSupplierMeta.PositionFlag = "DA";
 
                                // Trigger upfront payment
                                    SendSupplierPayment(
                                        CurrentSupplierMeta.SupplierWallet,
                                        CurrentSupplierOrder.UpfrontPayment);

                                // Trigger event
                                    CustomerSignOff( 
                                        CustomerName,
                                        CurrentSupplierMeta.SupplierCode,
                                        CurrentSupplierMeta.PositionFlag); }
                    }
                
                // Supplier approval of design and contract

                    function SupplierApproval(
                        string  SupplierCode, 
                        bytes1  SupplierAgreeFlag) FRonly public {
                    
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Set customer agreement flag
                        CurrentSupplierMeta.SupplierAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment and 
                        //  event if both customer and supplier have signed off
                        if (CurrentSupplierMeta.CustomerAgreeFlag == "A" &&
                            CurrentSupplierMeta.SupplierAgreeFlag == "A") {
                                CurrentSupplierMeta.PositionFlag = "DA";
 
                                // Trigger upfront payment
                                    SendSupplierPayment(
                                        CurrentSupplierMeta.SupplierWallet,
                                        CurrentSupplierOrder.UpfrontPayment);

                                // Trigger event
                                    SupplierSignOff( 
                                        CurrentSupplierMeta.SupplierCode,
                                        CustomerName,
                                        CurrentSupplierMeta.PositionFlag); }
                    }
                
            // Input first-off quality control result 
            //  and trigger pre-batch payment

                    function InputFirstOffQuality(
                        string  SupplierCode,
                        bytes1  QualityFirstOff) FRonly public  {

                        // Set process postion code
                            QualityFirstOff = QualityFirstOff;
                            bytes2 PositionCode;
                            if (QualityFirstOff == "A") {PositionCode = "MA";}
                            if (QualityFirstOff == "R") {PositionCode = "MR";}
                        
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode];
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];

                        // Update process postion flag
                            CurrentSupplierMeta.PositionFlag = PositionCode;
                        
                        // Trigger pre-batch payment
                        if (QualityFirstOff == "A") { 
                            SendSupplierPayment(
                                CurrentSupplierMeta.SupplierWallet,
                                CurrentSupplierOrder.BatchPayment);
                        }
                        
                        // Trigger events
                            if (QualityFirstOff == "A") {
                                FirstOffApproved(
                                    CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta.PositionFlag); }
                            if (QualityFirstOff == "R") {
                                FirstOffRejected (
                                    CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta.PositionFlag); }
                    }

            // Input main batch quality control result 
            //  and trigger final payment

                    function InputMainBatchQuality(
                        string  SupplierCode,
                        bytes1  QualityMainBatch) FRonly public  {

                        // Set process postion code
                            QualityMainBatch = QualityMainBatch;
                            bytes2 PositionCode;
                            if (QualityMainBatch == "A") {PositionCode = "MA";}
                            if (QualityMainBatch == "R") {PositionCode = "MR";}
                        
                        var CurrentSupplierMeta  = SuppliersMeta[SupplierCode]; 
                        var CurrentSupplierOrder = SuppliersOrder[SupplierCode];                         

                        // Update process postion flag
                            CurrentSupplierMeta.PositionFlag = PositionCode;
                        
                        // Trigger final payment
                        if (QualityMainBatch == "A") { 
                            SendSupplierPayment(
                                CurrentSupplierMeta.SupplierWallet,
                                CurrentSupplierOrder.FinalPayment);
                        }
                        
                        // Trigger events
                            if (QualityMainBatch == "A") {
                                MainBatchApproved(
                                    CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta.PositionFlag); }
                            if (QualityMainBatch == "R") {
                                MainBatchRejected (
                                    CustomerName,
                                    SupplierCode,
                                    CurrentSupplierMeta.PositionFlag); }
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

            // Display supplier process position
                function GetSupplierPosition(string SupplierCode) 
                    FRonly public returns(bytes2 PositionFlag){
                        var CurrentSupplierMeta = SuppliersMeta[SupplierCode]; 
                        return CurrentSupplierMeta.PositionFlag;

                }
}