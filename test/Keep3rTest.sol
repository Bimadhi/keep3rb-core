pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./script.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

         return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface Keep3rLike {
   function setup() external payable;
   function balanceOf(address) external view returns (uint);
   function liquidity() external view returns (address);

   function bond(uint) external;
   function activate() external;
   function unbond() external;
   function withdraw() external;
   function claim() external;

   function isKeeper(address) external view returns (bool);

   function addJob(address) external;
   function removeJob(address) external;
   function jobs(address) external view returns (bool);

   function workReceipt(address,uint) external;

   function submitJob(address,uint) external;
}

contract Keep3rTest is script {
    using SafeMath for uint;

    Keep3rLike constant private KPR = Keep3rLike(0x4fF0170A2bf39368681109034A2F7d505f181544);

	function run() public {
	    run(this.init).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.bond).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    advanceBlocks(3 days);
	    run(this.activate).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.unbond).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    advanceBlocks(14 days);
	    run(this.withdraw).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.manageJobs).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.submitJob).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.work).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	    run(this.claim).withCaller(0x2D407dDb06311396fE14D4b49da5F0471447d45C);
	}

	function submitJob() external {
        fmt.printf("liquidity=%.18u\n",abi.encode(ERC20Like(KPR.liquidity()).balanceOf(address(this))));
	    ERC20Like(KPR.liquidity()).approve(address(KPR), uint(-1));
	    KPR.submitJob(address(this), ERC20Like(KPR.liquidity()).balanceOf(address(this)));
        fmt.printf("liquidity=%.18u\n",abi.encode(ERC20Like(KPR.liquidity()).balanceOf(address(this))));
	}

	function work() external {
	    KPR.workReceipt(address(this), 1e18);
	}

	function manageJobs() external {
	    KPR.addJob(address(this));
	    KPR.removeJob(address(this));
        fmt.printf("isJob=%b\n",abi.encode(KPR.jobs(address(this))));
	    KPR.addJob(address(this));
        fmt.printf("isJob=%b\n",abi.encode(KPR.jobs(address(this))));
	}

    function init() external {
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
        KPR.setup.value(1e18)();
        fmt.printf("liquidity=%a\n",abi.encode(KPR.liquidity()));
    }

    function bond() external {
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
        KPR.bond(KPR.balanceOf(address(this)));
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
    }

    function activate() external {
        KPR.activate();
        fmt.printf("isKeeper=%b\n",abi.encode(KPR.isKeeper(address(this))));
    }

    function unbond() external {
        KPR.unbond();
        fmt.printf("isKeeper=%b\n",abi.encode(KPR.isKeeper(address(this))));
    }

    function withdraw() external {
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
        KPR.withdraw();
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
    }

    function claim() external {
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
        KPR.claim();
        fmt.printf("balanceOf=%.18u\n",abi.encode(KPR.balanceOf(address(this))));
    }
}
