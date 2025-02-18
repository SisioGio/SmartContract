{
    { }
    function abi_encode_tuple_t_uint256__to_t_uint256__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, value0)
    }
    function abi_encode_tuple_t_string_memory_ptr__to_t_string_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        mstore(headStart, 32)
        let length := mload(value0)
        mstore(add(headStart, 32), length)
        mcopy(add(headStart, 64), add(value0, 32), length)
        mstore(add(add(headStart, length), 64), 0)
        tail := add(add(headStart, and(add(length, 31), not(31))), 64)
    }
    function abi_decode_address(offset) -> value
    {
        value := calldataload(offset)
        if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
    }
    function abi_decode_tuple_t_addresst_uint256(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        let value := 0
        value := calldataload(add(headStart, 32))
        value1 := value
    }
    function abi_encode_tuple_t_bool__to_t_bool__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, iszero(iszero(value0)))
    }
    function abi_decode_tuple_t_address(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
    }
    function abi_decode_tuple_t_addresst_addresst_uint256(headStart, dataEnd) -> value0, value1, value2
    {
        if slt(sub(dataEnd, headStart), 96) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        value1 := abi_decode_address(add(headStart, 32))
        let value := 0
        value := calldataload(add(headStart, 64))
        value2 := value
    }
    function abi_decode_tuple_t_uint256t_uint256(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let value := 0
        value := calldataload(headStart)
        value0 := value
        let value_1 := 0
        value_1 := calldataload(add(headStart, 32))
        value1 := value_1
    }
    function abi_encode_tuple_t_uint8__to_t_uint8__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, 0xff))
    }
    function abi_decode_tuple_t_uint256(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let value := 0
        value := calldataload(headStart)
        value0 := value
    }
    function abi_encode_tuple_t_address__to_t_address__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
    }
    function abi_decode_tuple_t_addresst_address(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        value1 := abi_decode_address(add(headStart, 32))
    }
    function extract_byte_array_length(data) -> length
    {
        length := shr(1, data)
        let outOfPlaceEncoding := and(data, 1)
        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
        if eq(outOfPlaceEncoding, lt(length, 32))
        {
            mstore(0, shl(224, 0x4e487b71))
            mstore(4, 0x22)
            revert(0, 0x24)
        }
    }
    function panic_error_0x11()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(0, 0x24)
    }
    function checked_sub_t_uint256(x, y) -> diff
    {
        diff := sub(x, y)
        if gt(diff, x) { panic_error_0x11() }
    }
    function checked_div_t_uint256(x, y) -> r
    {
        if iszero(y)
        {
            mstore(0, shl(224, 0x4e487b71))
            mstore(4, 0x12)
            revert(0, 0x24)
        }
        r := div(x, y)
    }
    function checked_mul_t_uint256(x, y) -> product
    {
        product := mul(x, y)
        if iszero(or(iszero(x), eq(y, div(product, x)))) { panic_error_0x11() }
    }
    function abi_encode_tuple_t_stringliteral_d482ed43a9821257830811182d2b3f9a900acea135ec66054f65e478bae8a2f5__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 33)
        mstore(add(headStart, 64), "End time must be after start tim")
        mstore(add(headStart, 96), "e")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_589780fdaac943d73bde148f4b0fd3e83692efc7fc17ad3217c393187982f13a__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 33)
        mstore(add(headStart, 64), "Amount must be greater than zero")
        mstore(add(headStart, 96), ".")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_7572e40391d07d4b91d51e72cb8caa5f33f56b2b616c219ac11e2b95b18edce9__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 21)
        mstore(add(headStart, 64), "Insufficient balance.")
        tail := add(headStart, 96)
    }
    function checked_add_t_uint256(x, y) -> sum
    {
        sum := add(x, y)
        if gt(x, sum) { panic_error_0x11() }
    }
    function abi_encode_tuple_t_stringliteral_a69daac55d8db000fd874f5f76fa44daafef21c30d5fd1b5a03aadff5cdfc62f__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 23)
        mstore(add(headStart, 64), "Presale not started yet")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_893728d0e71b0800df2adedc4ebc96c8ebb7f6a47f5b7d4635aabadfc4a61040__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 20)
        mstore(add(headStart, 64), "No rewards available")
        tail := add(headStart, 96)
    }
    function checked_exp_helper(_base, exponent, max) -> power, base
    {
        power := 1
        base := _base
        for { } gt(exponent, 1) { }
        {
            if gt(base, div(max, base)) { panic_error_0x11() }
            if and(exponent, 1) { power := mul(power, base) }
            base := mul(base, base)
            exponent := shr(1, exponent)
        }
    }
    function checked_exp_unsigned(base, exponent) -> power
    {
        if iszero(exponent)
        {
            power := 1
            leave
        }
        if iszero(base)
        {
            power := 0
            leave
        }
        switch base
        case 1 {
            power := 1
            leave
        }
        case 2 {
            if gt(exponent, 255) { panic_error_0x11() }
            power := shl(exponent, 1)
            let _1 := 0
            _1 := 0
            leave
        }
        if or(and(lt(base, 11), lt(exponent, 78)), and(lt(base, 307), lt(exponent, 32)))
        {
            power := exp(base, exponent)
            let _2 := 0
            _2 := 0
            leave
        }
        let power_1, base_1 := checked_exp_helper(base, exponent, not(0))
        if gt(power_1, div(not(0), base_1)) { panic_error_0x11() }
        power := mul(power_1, base_1)
    }
    function checked_exp_t_uint256_t_uint8(base, exponent) -> power
    {
        power := checked_exp_unsigned(base, and(exponent, 0xff))
    }
    function abi_encode_tuple_t_stringliteral_a571dd8293399cb309f7b2bde54569ca999ce44e86cd0c229f3ea182fce1d17a__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 19)
        mstore(add(headStart, 64), "Already whitelisted")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_218413e24d7817fa46f780a765a55d181a2663121ab3737af6e2eca3f387ed51__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 21)
        mstore(add(headStart, 64), "Cannot refer yourself")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_365536250f99788f936d49966e981df01b0e105731e868ee8d76041fac1210b4__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 17)
        mstore(add(headStart, 64), "No tokens staked.")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_88a06aeb1ddf079af0f09813e3c0a21d0be789b97ce895e6b2fef895a65d7254__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 27)
        mstore(add(headStart, 64), "Unstake only after 4 weeks.")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_uint256_t_uint256__to_t_uint256_t_uint256__fromStack_reversed(headStart, value1, value0) -> tail
    {
        tail := add(headStart, 64)
        mstore(headStart, value0)
        mstore(add(headStart, 32), value1)
    }
    function abi_encode_tuple_t_stringliteral_320ca9ab72a35519bbc8b5873959d0db86e8bef67b21390649d1ea4fc97479fd__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 16)
        mstore(add(headStart, 64), "Sale not active.")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_23d60e945fa370db8474797fa42a3cd81862ed96e8b023a0ea874ae96f92fc76__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 28)
        mstore(add(headStart, 64), "Must send ETH to buy tokens.")
        tail := add(headStart, 96)
    }
    function checked_exp_t_uint256_t_uint256(base, exponent) -> power
    {
        power := checked_exp_unsigned(base, exponent)
    }
    function abi_encode_tuple_t_stringliteral_b9c5fc59fb887abaa73495a2571327740b47269757d965c80185503f648aa6d7__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 28)
        mstore(add(headStart, 64), "Not enough tokens available.")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_bd96d2e26503bb0de5edb62cf76d4698ffe5bd7b7a7f7da5027cddfc25c5ed82__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 24)
        mstore(add(headStart, 64), "Pre-sale not started yet")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_address_t_uint256_t_uint256__to_t_address_t_uint256_t_uint256__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
        mstore(add(headStart, 32), value1)
        mstore(add(headStart, 64), value2)
    }
}