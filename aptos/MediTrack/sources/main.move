module MyModule::MediTrack {

    use aptos_framework::signer;
    use aptos_framework::table;
    use std::vector;
    use std::string;
    use std::address;

    /// Struct representing a batch of medicine.
    struct MedicineBatch has store, key {
        batch_id: vector<u8>,        // Unique batch ID
        name: vector<u8>,            // Medicine name
        manufacturer: vector<u8>,     // Manufacturer name
        expiry_date: vector<u8>,      // Expiry date
        current_holder: address,      // Current holder of the medicine batch
        is_authentic: bool,           // Authenticity status
    }

    /// Resource storing all registered medicine batches
    struct MediTrackStore has key {
        batches: table::Table<vector<u8>, MedicineBatch>,
    }

    /// Function to initialize the module and create storage.
    public entry fun init_store(account: &signer) {
        move_to(account, MediTrackStore { batches: table::new<vector<u8>, MedicineBatch>() });
    }

    /// Function to register a new medicine batch.
    public entry fun register_medicine_batch(
        owner: &signer,
        batch_id: vector<u8>,
        name: vector<u8>,
        manufacturer: vector<u8>,
        expiry_date: vector<u8>
    ) acquires MediTrackStore {
        let store = borrow_global_mut<MediTrackStore>(signer::address_of(owner));
        
        // Ensure batch does not already exist
        assert!(!table::contains(&store.batches, &batch_id), 1);
        
        let new_batch = MedicineBatch {
            batch_id: batch_id,
            name: name,
            manufacturer: manufacturer,
            expiry_date: expiry_date,
            current_holder: signer::address_of(owner),
            is_authentic: true,
        };

        // Store the batch in the table
        table::add(&mut store.batches, batch_id, new_batch);
    }

    /// Function to transfer a medicine batch to a new holder.
    public entry fun transfer_batch(
        sender: &signer,
        batch_id: vector<u8>,
        new_holder: address
    ) acquires MediTrackStore {
        let store = borrow_global_mut<MediTrackStore>(signer::address_of(sender));
        
        // Ensure batch exists
        assert!(table::contains(&store.batches, &batch_id), 2);
        
        let batch = table::borrow_mut(&mut store.batches, &batch_id);
        
        // Check authenticity
        assert!(batch.is_authentic, 3);
        
        // Ensure sender is the current holder
        assert!(batch.current_holder == signer::address_of(sender), 4);
        
        // Transfer ownership
        batch.current_holder = new_holder;
    }

    /// Function to verify medicine details.
    public fun verify_medicine(
        owner: address,
        batch_id: vector<u8>
    ) acquires MediTrackStore returns (
        vector<u8>, vector<u8>, vector<u8>, vector<u8>, address, bool
    ) {
        assert!(exists<MediTrackStore>(owner), 5);

        let store = borrow_global<MediTrackStore>(owner);
        
        // Ensure batch exists
        assert!(table::contains(&store.batches, &batch_id), 6);
        
        let batch = table::borrow(&store.batches, &batch_id);
        
        (batch.batch_id, batch.name, batch.manufacturer, batch.expiry_date, batch.current_holder, batch.is_authentic)
    }
}
