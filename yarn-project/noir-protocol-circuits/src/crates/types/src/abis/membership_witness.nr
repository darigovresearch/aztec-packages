use dep::aztec::constants_gen::{
    CONTRACT_TREE_HEIGHT,
    FUNCTION_TREE_HEIGHT,
    KERNELS_PER_BASE_ROLLUP,
    MAX_NEW_NULLIFIERS_PER_BASE_ROLLUP,
    NOTE_HASH_TREE_HEIGHT,
    ROLLUP_VK_TREE_HEIGHT,
};

struct MembershipWitness<N> {
    leaf_index: Field,
    sibling_path: [Field; N]
}

// TODO(Kev): Instead of doing `MembershipWitness<FUNCTION_TREE_HEIGHT>` we are forced 
// to  do this new struct because the typescript bindings generator
// does not have logic to monomorphize these properly. See the file named
// `typechain-type-alias` in the folder `bug-collecting-crate`
struct FunctionLeafMembershipWitness{
    leaf_index: Field,
    sibling_path: [Field; FUNCTION_TREE_HEIGHT]
}

struct ContractLeafMembershipWitness{
    leaf_index: Field,
    sibling_path: [Field; CONTRACT_TREE_HEIGHT]
}

struct VKMembershipWitness{
    leaf_index: Field,
    sibling_path: [Field; ROLLUP_VK_TREE_HEIGHT]
}

struct NullifierMembershipWitness{
    leaf_index: Field,
    sibling_path: [Field; MAX_NEW_NULLIFIERS_PER_BASE_ROLLUP]
}

struct HistoricBlocksTreeRootMembershipWitness{
    leaf_index: Field,
    sibling_path: [Field; KERNELS_PER_BASE_ROLLUP]
}

struct ReadRequestMembershipWitness {
    leaf_index: Field,
    sibling_path: [Field; NOTE_HASH_TREE_HEIGHT],
    // whether or not the read request corresponds to a pending commitment
    // In case we change the default to true, we have to adapt is_empty() method
    // hint to point kernel to the commitment this rr corresponds to
    is_transient: bool,
    hint_to_commitment: Field,
}