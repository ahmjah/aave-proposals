// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import 'forge-std/Test.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {ProtocolV3TestBase, ReserveConfig, ReserveTokens, IERC20} from 'aave-helpers/ProtocolV3TestBase.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/ProtocolV3TestBase.sol';
import {AaveV3EthDFSFlashBorrowActivation} from './AaveV3ETHDFSFlashBorrowActivation_20230403.sol';
import {TestWithExecutor} from 'aave-helpers/GovHelpers.sol';

contract MockReceiver {
  event TestEvent();

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata,
    uint256[] calldata,
    address,
    bytes calldata
  ) external returns (bool) {
    emit TestEvent();
    for (uint256 i = 0; i < assets.length; i++) {
      IERC20(assets[i]).approve(address(AaveV3Ethereum.POOL), type(uint256).max);
    }

    return true;
  }
}

contract AaveV3EthDFSFlashBorrowActivationTest is TestWithExecutor, MockReceiver {
  address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 16932117);
    _selectPayloadExecutor(AaveGovernanceV2.SHORT_EXECUTOR);
  }

  function testZeroFee() public {
    // 1. create payload
    AaveV3EthDFSFlashBorrowActivation proposalPayload = new AaveV3EthDFSFlashBorrowActivation();

    // 2. execute payload
    _executePayload(address(proposalPayload));

    // 3. check fee is zero
    address user = proposalPayload.FL_AAVE_V3();
    vm.startPrank(user);
    address[] memory assetsToFlash = new address[](1);
    assetsToFlash[0] = DAI;
    uint256[] memory amountsToFlash = new uint256[](1);
    amountsToFlash[0] = 1_000_000 ether;
    uint256[] memory interestRatesToFlash = new uint256[](1);
    interestRatesToFlash[0] = 0;
    vm.expectEmit(true, true, true, true);
    emit TestEvent();

    AaveV3Ethereum.POOL.flashLoan(
      address(this),
      assetsToFlash,
      amountsToFlash,
      interestRatesToFlash,
      user,
      bytes(''),
      42
    );
  }
}