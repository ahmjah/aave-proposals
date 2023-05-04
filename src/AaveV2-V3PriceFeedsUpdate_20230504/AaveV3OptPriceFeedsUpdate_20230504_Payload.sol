// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3PayloadOptimism, IEngine} from 'aave-helpers/v3-config-engine/AaveV3PayloadOptimism.sol';

/**
 * @title wstETH Price Feed update
 * @author BGD Labs
 * @notice Change wstETH price feed on the Aave Optimism v3 pool.
 * - Governance Forum Post: https://governance.aave.com/t/bgd-generalised-price-sync-adapters/11416
 */
contract AaveV3OptPriceFeedsUpdate_20230504_Payload is AaveV3PayloadOptimism {
  // WSTETH / ETH / USD price adapter
  address public constant WSTETH_ADAPTER = 0x05225Cd708bCa9253789C1374e4337a019e99D56;

  function priceFeedsUpdates() public pure override returns (IEngine.PriceFeedUpdate[] memory) {
    IEngine.PriceFeedUpdate[] memory priceFeedUpdate = new IEngine.PriceFeedUpdate[](1);
    priceFeedUpdate[0] = IEngine.PriceFeedUpdate({
      asset: AaveV3OptimismAssets.wstETH_UNDERLYING,
      priceFeed: WSTETH_ADAPTER
    });

    return priceFeedUpdate;
  }
}
