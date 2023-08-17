// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HackBank {
    struct Student {
        address studentAddress;
        uint256 CASNumber; // Add CAS number field
        string fullName;
        string email;
        bool registered;
        bool verified;
    }

    mapping(uint256 => Student) public students;

    event StudentRegistered(
        address indexed studentAddress,
        uint256 indexed CASNumber,
        string fullName,
        string email
    );
    event StudentVerified(
        address indexed studentAddress,
        uint256 indexed CASNumber
    );
    event PaymentProcessed(
        address indexed sender,
        uint256 indexed CASNumber,
        uint256 amount,
        address recipient,
        string bankAccountSortCode,
        string bankAccountNumber,
        string bankName
    );

    uint256 private exchangeRatePKTToGBP = 2700; // 1 PKR = 0.0027 GBP (Fixed exchange rate for PKR to GBP)

    function registerStudent(
        uint256 _CASNumber,
        string memory _fullName,
        string memory _email
    ) public {
        require(
            _CASNumber >= 10 ** 9 && _CASNumber < 10 ** 10,
            "CAS Number must be exactly 10 digits"
        );
        require(bytes(_fullName).length > 0, "Full Name must not be empty");
        require(bytes(_email).length > 0, "Email must not be empty");
        require(
            students[_CASNumber].studentAddress == address(0),
            "CAS Number already registered"
        );
        require(containsAtSymbol(_email), "Invalid email format");

        Student memory newStudent = Student({
            studentAddress: msg.sender,
            CASNumber: _CASNumber,
            fullName: _fullName,
            email: _email,
            registered: true,
            verified: false // Initialize verified as false during registration
        });
        students[_CASNumber] = newStudent;

        emit StudentRegistered(msg.sender, _CASNumber, _fullName, _email);
    }

    function containsAtSymbol(
        string memory _email
    ) private pure returns (bool) {
        bytes memory emailBytes = bytes(_email);
        for (uint256 i = 0; i < emailBytes.length; i++) {
            if (emailBytes[i] == "@") {
                return true;
            }
        }
        return false;
    }

    function verifyStudent(uint256 _CASNumber) public {
        Student storage student = students[_CASNumber];
        require(
            student.studentAddress == msg.sender,
            "You can only verify your own registration"
        );
        require(student.registered, "Student not registered.");

        // Perform document verification here (off-chain) and set the verified status to true
        student.verified = true;

        emit StudentVerified(student.studentAddress, _CASNumber);
    }

    function processPayment(
        uint256 _CASNumber,
        address _recipient,
        string memory _bankAccountSortCode,
        string memory _bankAccountNumber,
        string memory _bankName
    ) public payable {
        Student storage student = students[_CASNumber];
        require(
            student.studentAddress == msg.sender,
            "You can only process payment for your own registration"
        );
        require(student.registered, "Student not registered.");
        require(student.verified, "Student not verified.");
        require(msg.value > 0, "Amount must be greater than 0");

        // Calculate the equivalent amount in GBP based on the PKR/GBP exchange rate
        uint256 amountGBP = (msg.value * exchangeRatePKTToGBP) / 1000000; // Divide by 10^6 to account for the exchange rate precision

        // Transfer the Ether to the recipient based on the calculated GBP amount
        (bool success, ) = _recipient.call{value: amountGBP}("");
        require(success, "Payment failed");

        // Emit the PaymentProcessed event with additional bank details
        emit PaymentProcessed(
            msg.sender,
            _CASNumber,
            amountGBP,
            _recipient,
            _bankAccountSortCode,
            _bankAccountNumber,
            _bankName
        );
    }
}
