// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.11;

import { CalculationsFixedForex } from "../../Oracle/Calculations/FixedForex.sol";
import { TestUtils } from "../utils/TestUtils.sol";

contract CalculationsFixedForexTests is TestUtils {
  address ibAud = "0xfafdf0c4c1cb09d430bf88c75d88bb46dae09967";
  address random_token = "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e";
  CalculationsFixedForex calculationsFixedForex;

  bleepbloop

  function setUp() public {
    calculationsFixedForex = new CalculationsFixedForex();
  }

  function testIBAud() public {
    assertGt(calculationsFixedForex.getPriceUsdc(ibAud), 0);
  }
}
