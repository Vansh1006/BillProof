// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BillProof
 * @notice Fraud-proof billing registry on Polygon.
 *         Issuers register a SHA-256 hash of a bill; anyone can verify it.
 * @dev    Deployed on Polygon Amoy testnet (chainId 80002) for hackathon demo.
 *         Mainnet deploy: Polygon PoS (chainId 137).
 */
contract BillProof {

    // ─── Structs ────────────────────────────────────────────────────────────

    struct BillRecord {
        address issuer;       // wallet that registered the bill
        uint256 timestamp;    // block timestamp of registration
        string  invoiceNum;   // human-readable invoice number (for display)
        bool    exists;       // existence flag
    }

    // ─── State ──────────────────────────────────────────────────────────────

    /// @dev hash (bytes32) → record
    mapping(bytes32 => BillRecord) private _bills;

    /// @dev issuer address → list of hashes they registered
    mapping(address => bytes32[]) private _issuerBills;

    uint256 public totalBills;

    // ─── Events ─────────────────────────────────────────────────────────────

    event BillRegistered(
        bytes32 indexed billHash,
        address indexed issuer,
        string  invoiceNum,
        uint256 timestamp
    );

    // ─── Errors ─────────────────────────────────────────────────────────────

    error BillAlreadyExists(bytes32 billHash);
    error InvalidHash();

    // ─── Core Functions ──────────────────────────────────────────────────────

    /**
     * @notice Register a bill hash on-chain.
     * @param billHash   keccak256 OR sha256 of the canonical bill string
     *                   (computed client-side before calling this function).
     * @param invoiceNum Human-readable invoice ID stored for UX lookup.
     */
    function registerBill(bytes32 billHash, string calldata invoiceNum) external {
        if (billHash == bytes32(0)) revert InvalidHash();
        if (_bills[billHash].exists)  revert BillAlreadyExists(billHash);

        _bills[billHash] = BillRecord({
            issuer:     msg.sender,
            timestamp:  block.timestamp,
            invoiceNum: invoiceNum,
            exists:     true
        });

        _issuerBills[msg.sender].push(billHash);
        totalBills++;

        emit BillRegistered(billHash, msg.sender, invoiceNum, block.timestamp);
    }

    /**
     * @notice Verify whether a bill hash is registered.
     * @return exists    true if the hash is on-chain.
     * @return issuer    address that registered it.
     * @return timestamp unix time of registration.
     * @return invoiceNum  invoice number stored at registration.
     */
    function verifyBill(bytes32 billHash)
        external
        view
        returns (
            bool   exists,
            address issuer,
            uint256 timestamp,
            string memory invoiceNum
        )
    {
        BillRecord storage r = _bills[billHash];
        return (r.exists, r.issuer, r.timestamp, r.invoiceNum);
    }

    /**
     * @notice Returns all bill hashes registered by a given issuer.
     */
    function getBillsByIssuer(address issuer)
        external
        view
        returns (bytes32[] memory)
    {
        return _issuerBills[issuer];
    }
}
