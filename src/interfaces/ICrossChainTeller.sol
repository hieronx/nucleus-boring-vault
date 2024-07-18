// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@solmate/tokens/ERC20.sol";

error CrossChainTellerBase_MessagesNotAllowedFrom(uint32 chainSelector);
error CrossChainTellerBase_MessagesNotAllowedFromSender(uint256 chainSelector, address sender);
error CrossChainTellerBase_MessagesNotAllowedTo(uint256 chainSelector);
error CrossChainTellerBase_ZeroMessageGasLimit();
error CrossChainTellerBase_GasLimitExceeded();
error CrossChainTellerBase_GasTooLow();

struct BridgeData{
    uint32 chainSelector;
    address destinationChainReceiver;
    ERC20 bridgeFeeToken;
    uint64 messageGas;
    bytes data;
}

struct Chain{
    bool allowMessagesFrom;
    bool allowMessagesTo;
    address targetTeller;
    uint64 messageGasLimit;
    uint64 minimumMessageGas;
}

/**
 * @title ICrossChainTeller
 * @notice Interface for CrossChainTeller contracts
 */
interface ICrossChainTeller {

    event MessageSent(bytes32 messageId, uint256 shareAmount, address to);
    event MessageReceived(bytes32 messageId, uint256 shareAmount, address to);

    event ChainAdded(
        uint256 chainSelector,
        bool allowMessagesFrom,
        bool allowMessagesTo,
        address targetTeller,
        uint64 messageGasLimit,
        uint64 messageGasMin
    );
    event ChainRemoved(uint256 chainSelector);
    event ChainAllowMessagesFrom(uint256 chainSelector, address targetTeller);
    event ChainAllowMessagesTo(uint256 chainSelector, address targetTeller);
    event ChainStopMessagesFrom(uint256 chainSelector);
    event ChainStopMessagesTo(uint256 chainSelector);
    event ChainSetGasLimit(uint256 chainSelector, uint64 messageGasLimit);


    /**
     * @dev function to deposit into the vault AND bridge cosschain in 1 call
     * @param depositAsset ERC20 to deposit
     * @param depositAmount amount of deposit asset to deposit
     * @param minimumMint minimum required shares to receive
     * @param data Bridge Data
     */
    function depositAndBridge(ERC20 depositAsset, uint256 depositAmount, uint256 minimumMint, BridgeData calldata data) external payable;

    /**
     * @dev only code for bridging for users who already deposited
     * @param shareAmount to bridge
     * @param data bridge data
     */
    function bridge(uint256 shareAmount, BridgeData calldata data) external payable returns(bytes32);

    /**
     * @dev adds an acceptable chain to bridge to
     * @param chainSelector chainSelector of chain
     * @param allowMessagesFrom allow messages from this chain
     * @param allowMessagesTo allow messages to the chain
     * @param targetTeller address of the target teller on this chain
     * @param messageGasLimit to pass to bridge
     */
    function addChain(
        uint32 chainSelector,
        bool allowMessagesFrom,
        bool allowMessagesTo,
        address targetTeller,
        uint64 messageGasLimit,
        uint64 messageGasMin
    ) external;

    /**
     * @dev block messages from a particular chain
     * @param chainSelector of chain
     */
    function stopMessagesFromChain(uint32 chainSelector) external;

    /**
     * @dev allow messages from a particular chain
     * @param chainSelector of chain
     */
    function allowMessagesFromChain(uint32 chainSelector, address targetTeller) external;

    /**
     * @notice Remove a chain from the teller.
     * @dev Callable by MULTISIG_ROLE.
     */
    function removeChain(uint32 chainSelector) external;

    /**
     * @notice Allow messages to a chain.
     * @dev Callable by OWNER_ROLE.
     */
    function allowMessagesToChain(uint32 chainSelector, address targetTeller, uint64 messageGasLimit)
        external;

    /**
     * @notice Stop messages to a chain.
     * @dev Callable by MULTISIG_ROLE.
     */
    function stopMessagesToChain(uint32 chainSelector) external;

    /**
     * @notice Set the gas limit for messages to a chain.
     * @dev Callable by OWNER_ROLE.
     */
    function setChainGasLimit(uint32 chainSelector, uint64 messageGasLimit) external;

}