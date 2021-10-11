pragma ton-solidity >= 0.50.0;

contract VestingDistributionContract {

    // Error codes: 
    uint constant ERROR_SENDER_IS_NOT_OWNER = 101;
    uint constant ERROR_LOW_BALANCE = 102;

    // vesting variables
    uint128 m_vestingAmount;
    uint8 m_distributionType; // 0 - equal destribution
                              // 1 - exponential destribution
    address[] m_users;
    uint32 m_timestamp;
    uint32 m_initialTimestap;
    uint32 m_lastTimestamp;
    uint32 m_duration;
    uint32 m_lastVestingTimestamp;

    constructor(uint128 sum, address[] users, uint8 distributionType, uint32 duration) public {
        require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
        require(address(this).balance > sum, ERROR_LOW_BALANCE);
        tvm.accept();
        m_vestingAmount = sum;
        m_distributionType = distributionType;
        m_users = users;
        m_duration = duration;
        m_timestamp = now;
        m_lastVestingTimestamp = now;
        m_initialTimestap = now;
        m_lastTimestamp = m_initialTimestap + m_duration;
    }

    modifier onlyOwner() {
        require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
        tvm.accept();       
        _;
    }

    function stopVesting(address user) public onlyOwner {
        calculateVesting();
        address[] users;
        for (uint i=0; i<m_users.length; i++) {
            if (m_users[i] == user){
                continue;
            } else {
                users.push(m_users[i]);
            }
        }
        m_users = users;
    }

    function distributeVesting(uint128 currentVesting) private {
        for (uint i=0; i<m_users.length; i++) {
            m_users[i].transfer(currentVesting, true, 0);
        }
        m_lastVestingTimestamp = now;
    }

    function calculateVesting() public onlyOwner {
        if (m_distributionType == 0) {
            calculateVestingEqual();
        }
    }

    function calculateVestingEqual() public onlyOwner {
        uint128 maxAlloc = m_vestingAmount / uint128(m_users.length);
        uint128 vestingPerSecond = maxAlloc / m_duration;
        uint128 currentVesting = (now - m_lastVestingTimestamp) * vestingPerSecond;
        distributeVesting(currentVesting);
    }

/*    function getCurrentVestingInfo() public {
        
    }*/


}