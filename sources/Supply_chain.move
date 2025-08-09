module 0x4c9a090c98a0237d6cdcd651e7db1cbbd4b62eaa1845d3aace22ed1a89418ea5::SupplyChainTracker {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::String;

    
    struct Product has store, key, drop {
        product_id: u64,
        name: String,
        origin: address,
        current_owner: address,
        timestamp: u64,
        status: String,
        is_verified: bool,
    }

    
    struct ProductRegistry has key {
        next_product_id: u64,
    }


    const E_PRODUCT_NOT_FOUND: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;

    
    fun init_registry(account: &signer) {
        if (!exists<ProductRegistry>(signer::address_of(account))) {
            let registry = ProductRegistry {
                next_product_id: 1,
            };
            move_to(account, registry);
        };
    }


    public entry fun create_product(
        creator: &signer,
        name: String,
        status: String
    ) acquires ProductRegistry {
        let creator_addr = signer::address_of(creator);
        
        // Initialize registry if it doesn't exist
        init_registry(creator);
        
        let registry = borrow_global_mut<ProductRegistry>(creator_addr);
        let product_id = registry.next_product_id;
        registry.next_product_id = product_id + 1;

        let product = Product {
            product_id,
            name,
            origin: creator_addr,
            current_owner: creator_addr,
            timestamp: timestamp::now_seconds(),
            status,
            is_verified: true,
        };

        move_to(creator, product);
    }

    
    public entry fun transfer_product(
        current_owner: &signer,
        new_owner: address,
        product_id: u64,
        new_status: String
    ) acquires Product {
        let owner_addr = signer::address_of(current_owner);
        
        assert!(exists<Product>(owner_addr), E_PRODUCT_NOT_FOUND);
        
        let product = borrow_global_mut<Product>(owner_addr);
        
        assert!(product.current_owner == owner_addr, E_NOT_AUTHORIZED);
        assert!(product.product_id == product_id, E_PRODUCT_NOT_FOUND);

        // Update product details
        product.current_owner = new_owner;
        product.timestamp = timestamp::now_seconds();
        product.status = new_status;
    }
}
