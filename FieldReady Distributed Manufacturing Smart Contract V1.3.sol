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
            string  _CustomerName;                  // Customer name

        // Supplier data
                
            // Supplier 1
                string	_S1Name;	            // Supplier name
                address	_S1Wallet;	            // Supplier wallet address
                string	_S1SupAgreeFlag; 	    // Supplier agreement flag
                string  _S1CustAgreeFlag;	    // Customer agreement flag
                string  _S1PosFlag = "AA";      // Process position flag
                address	_S1SupDesignHash;	    // Supplier's design hash
                address	_S1SupContractHash;     // Supplier's contract hash
                address	_S1CustDesignHash;      // Customer's design hash
                address	_S1CustContractHash;    // Customer's contract hash
                uint	_S1Upfront;	            // Upfront payment (in Wei)
                uint	_S1Batch;	            // Pre-batch payment (Wei)
                uint	_S1Final;	            // Final payment (in Wei)
     
            // Process position flag value table
                // AA : Design and contract awaiting approval
                // DA : Design and contract have been approved
                // FA : Quality of first-off has been approved
                // FR : Quality of first-off has been rejected
                // MA : Quality of main batch has been approved
                // MR : Quality of main batch has been rejected
                        
            // Customer and Supplier aggreement flag
                // A : Agree (Used in combination with signer address)

    // Contract functions

        // Data input functions
         
            // Input customer data
                function InputCustomerData (
                    string  CustomerName) FRonly public {
                    _CustomerName    = CustomerName;
                }
            
            // Input supplier data
                function InputSupplierData(
                    string	SupplierName,
                    address	SupplierWallet,
                    uint	UpfrontPayment,
                    uint	BatchPayment,
                    uint	FinalPayment ) FRonly public {
                        _S1Name	            = SupplierName;
                        _S1Wallet	        = SupplierWallet;     
                        _S1Upfront      	= UpfrontPayment;
                        _S1Batch            = BatchPayment;	    
                        _S1Final            = FinalPayment;
                }

            // Approve final design and supplier contract
            //  and trigger upfront payment
                
                // Customer approval of design and contract

                    function CustomerApproval(
                        string  CustomerAgreeFlag,
                        address DesignHash,
                        address ContractHash) FRonly public {
                        
                         // Add design and contract hashes
                        _S1CustDesignHash   = DesignHash;
                        _S1CustContractHash = ContractHash;

                        // Set customer agreement flag
                        _S1CustAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment  
                        // if both customer and supplier have signed off
                        if (    StringUtils.equal(_S1CustAgreeFlag,"A") &&
                                StringUtils.equal(_S1SupAgreeFlag,"A") ){
                                    _S1PosFlag = "DA";
 
                                    // Trigger upfront payment
                                        SendSupplierPayment(
                                            _S1Wallet, _S1Upfront); }
                    }
                
                // Supplier approval of design and contract

                    function SupplierApproval(
                        string  SupplierAgreeFlag,
                        address DesignHash,
                        address ContractHash ) FRonly public {
  
                        // Add design and contract hashes
                        _S1SupDesignHash   = DesignHash;
                        _S1SupContractHash = ContractHash;

                        // Set supplier agreement flag
                        _S1SupAgreeFlag = "A";
                        
                        // Set process postion flag and trigger payment  
                        // if both customer and supplier have signed off
                        if (    StringUtils.equal(_S1CustAgreeFlag,"A") &&
                                StringUtils.equal(_S1SupAgreeFlag,"A") ){
                                    _S1PosFlag = "DA";
 
                                    // Trigger upfront payment
                                        SendSupplierPayment(
                                            _S1Wallet, _S1Upfront); }
                        }

            // Input first-off quality control result 
            //  and trigger pre-batch payment

                    function InputFirstOffQuality(
                        string  QualityFirstOff) FRonly public  {

                        string memory QualityFirstOffFlag = QualityFirstOff;
 
                            // Update process postion flag
                            if (StringUtils.equal(QualityFirstOffFlag, "A")) 
                                {_S1PosFlag = "FA";}
                            if (StringUtils.equal(QualityFirstOffFlag, "R")) 
                                {_S1PosFlag = "FR";}
                        
                            // Trigger pre-batch payment
                            if (StringUtils.equal(QualityFirstOffFlag, "A")) { 
                                SendSupplierPayment(_S1Wallet, _S1Batch);
                            }
                        
                        QualityFirstOffFlag = "-";
                    }

            // Input main batch quality control result 
            //  and trigger final payment

                    function InputMainBatchQuality(
                        string  QualityMainBatch) FRonly public  {

                        string memory QualityMainBatchFlag = QualityMainBatch;
 
                            // Update process postion flag
                            if (StringUtils.equal(QualityMainBatchFlag, "A")) 
                                {_S1PosFlag = "MA";}
                            if (StringUtils.equal(QualityMainBatchFlag, "R")) 
                                {_S1PosFlag = "MR";}
                        
                            // Trigger pre-batch payment
                            if (StringUtils.equal(QualityMainBatchFlag, "A")) { 
                                SendSupplierPayment(_S1Wallet, _S1Final);
                            }

                        QualityMainBatchFlag = "-";
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
                        string CustomerName){
                            return (_CustomerName);
                }
                
            // Display supplier process position
                
                // Supplier
                function DisplaySupplierPosition() 
                    FRonly public constant returns(
                        string  SupplierName,
                        string  ProcessPosition ){
                            return (    _S1Name,
                                        _S1PosFlag );
                }
}