struct MerkleTree<N> {
    leaves: [Field; N],
    nodes: [Field; N],
}

impl<N> MerkleTree<N> {
    fn new(leaves: [Field; N]) -> Self {
        let mut nodes = [0; N];
        
        // We need one less node than leaves, but we cannot have computed array lengths
        let total_nodes = N - 1;
        let half_size = N/2;
        
        // hash base layer
        for i in 0..half_size {
            nodes[i] = dep::std::hash::pedersen_hash([leaves[2*i], leaves[2*i+1]]);
        }

        // hash the other layers
        for i in 0..(total_nodes - half_size) {
            nodes[half_size+i] = dep::std::hash::pedersen_hash([nodes[2*i], nodes[2*i+1]]);
        }

        MerkleTree {
            leaves,
            nodes,
        }
    }

    fn get_root(self) -> Field {
        self.nodes[N-2]
    }
}

pub fn calculate_subtree<N>(leaves : [Field; N]) -> Field { 
    MerkleTree::new(leaves).get_root()
}

// These values are precomputed and we run tests to ensure that they
// are correct. The values themselves were computed from the cpp code.
//
// Would be good if we could use width since the compute_subtree
// algorithm uses depth.
pub fn calculate_empty_tree_root(depth : Field) -> Field {
    if depth == 1 {
        0x27b1d0839a5b23baf12a8d195b18ac288fcf401afb2f70b8a4b529ede5fa9fed
    } else if depth == 2 {
        0x21dbfd1d029bf447152fcf89e355c334610d1632436ba170f738107266a71550
    } else if depth == 3{
        0x0bcd1f91cf7bdd471d0a30c58c4706f3fdab3807a954b8f5b5e3bfec87d001bb
    } else if depth == 4 {
        0x06e62084ee7b602fe9abc15632dda3269f56fb0c6e12519a2eb2ec897091919d
    } else if depth == 5 {
        0x03c9e2e67178ac638746f068907e6677b4cc7a9592ef234ab6ab518f17efffa0
    } else if depth == 6 {
        0x15d28cad4c0736decea8997cb324cf0a0e0602f4d74472cd977bce2c8dd9923f
    } else if depth == 7 {
        0x268ed1e1c94c3a45a14db4108bc306613a1c23fab68e0466a002dfb0a3f8d2ab
    } else if depth == 8 {
        0x0cd8d5695bc2dde99dd531671f76f1482f14ddba8eeca7cb9686d4a62359c257
    } else if depth == 9 {
        0x047fbb7eb974155702149e58ea6ad91f4c6e953e693db35e953e250d8ceac9a9
    } else if depth == 10 {
        0x00c5ae2526e665e2c7c698c11a06098b7159f720606d50e7660deb55758b0b02
    } else {
        assert(false, "depth should be between 1 and 10");
        0
    }
}


#[test]
fn test_merkle_root_interop_test() {
    // This is a test to ensure that we match the cpp implementation.
    // You can grep for `TEST_F(root_rollup_tests, noir_interop_test)`
    // to find the test that matches this.
    let root = calculate_subtree([1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4]);
    assert(0x17e8bb70a11d0c946345950879484d2f4f9fef397ff6adbfdec3baab2d41faab == root);

    let empty_root = calculate_subtree([0; 16]);
    assert(0x06e62084ee7b602fe9abc15632dda3269f56fb0c6e12519a2eb2ec897091919d == empty_root);
}

#[test]
fn test_empty_subroot() {
    let expected_empty_root_2 = calculate_subtree([0; 2]);
    assert(calculate_empty_tree_root(1) == expected_empty_root_2);
    
    let expected_empty_root_4 = calculate_subtree([0; 4]);
    assert(calculate_empty_tree_root(2) == expected_empty_root_4);

    let expected_empty_root_8 = calculate_subtree([0; 8]);
    assert(calculate_empty_tree_root(3) == expected_empty_root_8);

    let expected_empty_root_16 = calculate_subtree([0; 16]);
    assert(calculate_empty_tree_root(4) == expected_empty_root_16);

    let expected_empty_root_32 = calculate_subtree([0; 32]);
    assert(calculate_empty_tree_root(5) == expected_empty_root_32);
    
    let expected_empty_root_64 = calculate_subtree([0; 64]);
    assert(calculate_empty_tree_root(6) == expected_empty_root_64);
 
    let expected_empty_root_128 = calculate_subtree([0; 128]);
    assert(calculate_empty_tree_root(7) == expected_empty_root_128);
}