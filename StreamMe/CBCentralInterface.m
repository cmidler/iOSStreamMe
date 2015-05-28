//
//  CBCentralInterface.m
//  Genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 Genesis. All rights reserved.
//


#import "CBCentralInterface.h"

@implementation CBCentralInterface



- (CBCentralInterface *)init {
    if (self = [super init]) {
        _bluetoothOn = YES;
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil
                                           options:@{ CBCentralManagerOptionRestoreIdentifierKey:
                                                          @"CentralManagerIdentifier" }];
        _bluetoothProfiles = [[NSMutableDictionary alloc] init];
        //_isScanning = 0;
        //_isConnected = 0;
        //_lastQueryTime = 0.0;
        //_inQuery = NO;
        //see if the last time the app was opened if it was on or off
        // initialize defaults
        NSString *bluetoothKey    = @"bluetoothOn";
        NSNumber *bluetoothStatus = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:bluetoothKey];
        if (bluetoothStatus == nil)     // App first run: set up user defaults.
        {
            NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], bluetoothKey, nil];
            
            bluetoothStatus = [NSNumber numberWithBool:YES];
            
            // sync the defaults to disk
            [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        _centralOn = bluetoothStatus.boolValue;
        
    }
    
    NSLog(@"CentralManager: Powered on. %@", _centralManager);
    return self;
}

- (bool) getBluetoothOnValue
{
    return _centralOn;
}

- (void) toggleCentralOn
{
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _centralOn = !_centralOn;
    [defaults setObject:[NSNumber numberWithBool:_centralOn] forKey:@"bluetoothOn"];
    [defaults synchronize];
    
    //turn on scanning or turn it off
    if(_centralOn)
        [self startScanningForUserProfiles];
    else
        [self stopScanningForUserProfiles];
}

- (void) startScanningForUserProfiles {
    [self startScanningForUserProfiles:_centralManager];
    
    //Also start a timer to remove stale profiles
    //_timer =[NSTimer scheduledTimerWithTimeInterval:RESET_TIME target:self selector:@selector(checkStaleProfile) userInfo:nil repeats:YES];
}


- (void)startScanningForUserProfiles:(CBCentralManager *)central {
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:nil];
    //NSLog(@"Started Scanning");
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        //[PFCloud callFunctionInBackground:@"consoleLogFunction" withParameters:@{} block:^(id object, NSError *error) {}];
        //NSLog(@"central state is %d", central.state);
        return;
    }
    /*if(!_centralOn)
    {
        [PFCloud callFunctionInBackground:@"consoleLogFunction" withParameters:@{} block:^(id object, NSError *error) {}];
        return;
    }*/
    // Scan for devices
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:nil];
    //_isScanning = 1;
}

//stop scanning for profiles and remove all profiles in list
- (void) stopScanningForUserProfiles {
    //_isScanning = 0;
    //[_timer invalidate];
    [_centralManager stopScan];
    NSLog(@"Stopped scanning for user profiles");
    for(NSString* key in [_bluetoothProfiles allKeys])
        [self cleanup:key];
}


//Cleanup services
- (void)cleanup:(NSString*)UUID {
    
    //Lock adding or removing from common dictionary
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:UUID];
    
    // See if we are subscribed to a characteristic on the peripheral
    if (bp.peripheral.services != nil) {
        for (CBService *service in bp.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        [bp.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        NSLog(@"CentralManager: Canceled subscription to characteristic %@ in service %@ on peripheral %@.", characteristic.UUID.UUIDString, service.UUID.UUIDString, bp.peripheral.identifier.UUIDString);
                    }
                }
            }
        }
    }
    
    
    if(bp.peripheral.state != CBPeripheralStateDisconnected)
    {
        [_centralManager cancelPeripheralConnection:bp.peripheral];
        bp.isMarkedForDelete = YES;
        NSLog(@"Disconnecting %@ in cleanup with state %d", bp.peripheral.identifier.UUIDString, (int)bp.peripheral.state);
        return;
    }
    else
    {
        NSLog(@"Cleaning up disconnected peripheral");
        //_isConnected = 0;
        //bp.isConnectedProfile = NO;
    }
    
    bp.peripheral = nil;
    //bp.profile = nil;
    //remove bluetooh profile from dictionary and let garbage collector take care of the details
    [_bluetoothProfiles removeObjectForKey:UUID];
    
}

//restore state for central manager.  Need to get the user ids that were stored
- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary *)state {
    
    NSLog(@"RESTORING STATE FOR CENTRAL");
    //setup variables
    _bluetoothProfiles = [[NSMutableDictionary alloc] init];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil
                                                         options:@{ CBCentralManagerOptionRestoreIdentifierKey:
                                                                        @"CentralManagerIdentifier" }];
    //[self startScanningForUserProfiles];
    
    NSLog(@"after central manager");
    
}

////////////////////////////////////////////////
// CBCentralManager delegate methods
////////////////////////////////////////////////

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
        //[PFCloud callFunctionInBackground:@"consoleLogFunction" withParameters:@{@"field":[NSNumber numberWithInt:central.state]} block:^(id object, NSError *error) {}];
    
        // Display new state of central manager
        NSString *state = nil;
        switch (central.state) {
            case CBCentralManagerStatePoweredOff:
                state = @"off";
                _bluetoothOn = NO;
                //if (_isScanning)
                //{
                    
                //    _isScanning = 0;
                    [_centralManager stopScan];
                //}
                break;
            case CBCentralManagerStatePoweredOn:
                _bluetoothOn = YES;
                [self startScanningForUserProfiles];
                state = @"on";
                break;
            default:
                _bluetoothOn = NO;
                state = @"other";
                //if (_isScanning)
                //{
                  //  _isScanning = 0;
                    [_centralManager stopScan];
                    
                //}
                // Notifying that bluetooth is not working on this device
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"bluetoothNotWorking" object:self];
                break;
        }
    //if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSection" object:self];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSMutableArray* serviceUUIDs = [[NSMutableArray alloc]init];
    
    //Adding service uuids to array
    for(CBUUID* cbuuid in [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"])
        [serviceUUIDs addObject:cbuuid];
    for(CBUUID* cbuuid in [advertisementData objectForKey:@"kCBAdvDataHashedServiceUUIDs"])
    {
        if(![serviceUUIDs containsObject:cbuuid])
            [serviceUUIDs addObject:cbuuid];
    }
    
    double currentTime = [[NSDate date]timeIntervalSince1970];
    double expirationTime = currentTime-TIMEOUT_TIME;
    NSLog(@"discovered peripheral id %@ at %@", peripheral.identifier.UUIDString, [NSDate date]);
    MainDatabase* md = [MainDatabase shared];
    __block bool inQueue = YES;
    __block bool connect = NO;
    [md.queue inDatabase:^(FMDatabase *db) {
        
        
        //need to delete the peripherals that are about to expire
        NSString *peripheralSQL = @"SELECT * FROM user WHERE peripheral_id = ?";
        NSArray* values = @[peripheral.identifier.UUIDString];
        FMResultSet *s = [db executeQuery:peripheralSQL withArgumentsInArray:values];
        bool hasPeripheral = NO;
        //get the peripheral ids
        while([s next])
        {
            hasPeripheral = YES;
        }
        
        //has peripheral so update time
        if(hasPeripheral)
        {
            NSLog(@"has peripheral");
            NSString *updateSQL = @"UPDATE user SET time_since_update = ? WHERE peripheral_id = ?";
            NSArray* values = @[[NSNumber numberWithDouble:currentTime], peripheral.identifier.UUIDString];
            [db executeUpdate:updateSQL withArgumentsInArray:values];
        }
        else
        {
            connect = YES;
        }

        //delete all expired user ids
        NSString *deleteSQL = @"DELETE FROM user WHERE peripheral_id != ? AND time_since_update < ? AND is_me != ?";
        values = @[peripheral.identifier.UUIDString,[NSNumber numberWithDouble:expirationTime], [NSNumber numberWithInt:1]];
        [db executeUpdate:deleteSQL withArgumentsInArray:values];
        inQueue = NO;
    }];
    
    //wait until queue is over
    while(inQueue)
        ;
    
    //connect to the peripheral
    if(connect)
    {
        NSLog(@"Does not have peripheral");
        BluetoothProfile* bp = [[BluetoothProfile alloc]init];
        //bp.timestamp = [[NSDate date] timeIntervalSince1970];
        NSLog(@"setting bp.initial time");
        //bp.initialTime = [[NSDate date] timeIntervalSince1970];
        bp.peripheral = peripheral;
        [_bluetoothProfiles setObject:bp forKey:peripheral.identifier.UUIDString];
        [_centralManager connectPeripheral:bp.peripheral options:nil];
    }
    else
    {
        [self queryForNewUserStreams];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"CentralManager: Error, Failed to connect to peripheral %@.", peripheral.identifier.UUIDString);
    
    
    /* This is a hack of code to bypass apple's 1309 error in bluetooth code*/
    if (error) {
        /*if(_isScanning)
        {
            _isScanning = 0;
            NSLog(@"Stopped scan for error");
         
        }*/
        [_centralManager stopScan];
        self.centralManager.delegate = nil;
        self.centralManager = nil;
        
        //Failure to connect (should only connect serially so we should be free)
        NSLog(@"Failed to connect so not connected");
        //BluetoothProfile* bp = _bluetoothProfiles[peripheral.identifier.UUIDString];
        //bp.isConnectedProfile = NO;
        // Remove all references to any peripherals you've been interacting with
        [self cleanup:peripheral.identifier.UUIDString];
        
        /* Some delay (more than the next iteration of the runloop, less than 2 seconds) is required in order to:
         * • Allow ARC to drain the autorelease pool, ensuring destruction of the centralManager
         * • Allow Core Bluetooth to turn off the radio.
         */
     
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            
        });
    }
    else
    {
        //Failure to connect (should only connect serially so we should be free)
        NSLog(@"Failed to connect so not connected");
        //BluetoothProfile* bp = _bluetoothProfiles[peripheral.identifier.UUIDString];
        //bp.isConnectedProfile = NO;
    }
    
    //_isConnected = 0;
    
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"CentralManager: Connected to peripheral %@.", peripheral.identifier.UUIDString);
    NSMutableArray* tmp =[[NSMutableArray alloc] init];
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];
    
    
    NSLog(@"bp is %@", bp.peripheral.identifier.UUIDString);
    
    [bp.peripheral setDelegate:self];
    //if(!bp.hasUserId)
    [tmp addObject:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]];
    
    
    NSLog(@"tmp is %@ with length %d", tmp, (int)[tmp count]);
    
    [peripheral discoverServices:tmp];
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];
    NSLog(@"CentralManager: Disconnecting from peripheral %@.", bp.peripheral.identifier.UUIDString);

    if(error)
    {
        /*if(_isScanning)
        {
            _isScanning = 0;
            NSLog(@"Stopped scan due to error %@",error);
         
        }*/
        [_centralManager stopScan];
        self.centralManager.delegate = nil;
        self.centralManager = nil;
        // Remove all references to any peripherals you've been interacting with
        [self cleanup:peripheral.identifier.UUIDString];
        
        /* Some delay (more than the next iteration of the runloop, less than 2 seconds) is required in order to:
         * • Allow ARC to drain the autorelease pool, ensuring destruction of the centralManager
         * • Allow Core Bluetooth to turn off the radio.
         */
     
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            
        });
        //_isConnected = 0;
        //bp.isConnectedProfile = NO;
        return;
    }
    
    
    // See if we are subscribed to a characteristic on the peripheral
    if (bp.peripheral.services != nil) {
        for (CBService *service in bp.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        [bp.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        NSLog(@"CentralManager: Canceled subscription to characteristic %@ in service %@ on peripheral %@.", characteristic.UUID.UUIDString, service.UUID.UUIDString, bp.peripheral.identifier.UUIDString);
                    }
                }
            }
        }
    }
    
    //See if this profile is marked for deletion
    if(bp.isMarkedForDelete)
    {
        bp.peripheral = nil;
        //bp.profile = nil;
        //remove bluetooh profile from dictionary and let garbage collector take care of the details
        [_bluetoothProfiles removeObjectForKey:peripheral.identifier.UUIDString];
    }
    
    
    //_isConnected = 0;
    /*bp.isConnectedProfile = NO;
    if(_isScanning == 0)
    {
        NSLog(@"Starting to scan after disconnect");
     
    }*/
    [self startScanningForUserProfiles:central];
}

////////////////////////////////////////////////
// CBPeripheral delegate methods
////////////////////////////////////////////////

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"CentralManager: Discovered service in peripheral %@.", peripheral.identifier.UUIDString);
    if (error) {
        NSLog(@"Central Manager: Error in didDiscoverServices: %@.", [error localizedDescription]);
        /*if(_isScanning)
        {
            _isScanning = 0;
            NSLog(@"Stopped scan for error");
         
        }*/
        [_centralManager stopScan];
        self.centralManager.delegate = nil;
        self.centralManager = nil;
        
        //Failure to connect (should only connect serially so we should be free)
        //NSLog(@"Failed to connect so not connected");
        //BluetoothProfile* bp = _bluetoothProfiles[peripheral.identifier.UUIDString];
        //bp.isConnectedProfile = NO;
        // Remove all references to any peripherals you've been interacting with
        [self cleanup:peripheral.identifier.UUIDString];
        
        /* Some delay (more than the next iteration of the runloop, less than 2 seconds) is required in order to:
         * • Allow ARC to drain the autorelease pool, ensuring destruction of the centralManager
         * • Allow Core Bluetooth to turn off the radio.
         */
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            
        });
        return;
    }
    
    NSLog(@"service count is %d",(int)[peripheral.services count]);
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];

    
    //if there isn't an error but services count is 0 then disconnect and retry again
    if(![peripheral.services count])
    {
        [_centralManager cancelPeripheralConnection:bp.peripheral];
    }
    
    //loop through services
    for(CBService* service in peripheral.services)
    {
        NSLog(@"discovered service %@", service.UUID.UUIDString);
        NSMutableArray* characteristics;
        //get user id
        if([service.UUID.UUIDString isEqualToString:TRANSFER_SERVICE_UUID])
        {
            characteristics = [[NSMutableArray alloc] init];
            [characteristics addObject:[CBUUID UUIDWithString:USER_ID_UUID]];
        }
        
        NSLog(@"characteristics for service are %@", characteristics);
        
        //add the correct characteristics to the service
        [peripheral discoverCharacteristics:characteristics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        NSLog(@"CentralManager: Error in didDiscoverCharacteristicsForService: %@.", [error localizedDescription]);
        /*if(_isScanning)
        {
            _isScanning = 0;
            NSLog(@"Stopped scan for error");
            
        }*/
        [_centralManager stopScan];
        self.centralManager.delegate = nil;
        self.centralManager = nil;
        
        //Failure to connect (should only connect serially so we should be free)
        //NSLog(@"Failed to connect so not connected");
        //BluetoothProfile* bp = _bluetoothProfiles[peripheral.identifier.UUIDString];
        //bp.isConnectedProfile = NO;
        // Remove all references to any peripherals you've been interacting with
        [self cleanup:peripheral.identifier.UUIDString];
        
        /* Some delay (more than the next iteration of the runloop, less than 2 seconds) is required in order to:
         * • Allow ARC to drain the autorelease pool, ensuring destruction of the centralManager
         * • Allow Core Bluetooth to turn off the radio.
         */
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            
        });
        return;
    }
    
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];
    
    NSLog(@"in discovered characteristics");
    //loop through characteristics in service
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"discovered characteristic %@", characteristic.UUID.UUIDString);
        //read userid
        if([characteristic.UUID.UUIDString isEqualToString:USER_ID_UUID])
        {
            NSLog(@"Read value characteristic");
            [peripheral readValueForCharacteristic:characteristic];
        }
        //notify data
        else
        {
            NSLog(@"read data for characteristic %@", characteristic.UUID.UUIDString);
            //add a data storage object for the characteristic if it doesn't exist
            if(![bp.dataDict objectForKey:characteristic.UUID.UUIDString])
            {
                NSMutableData* data = [[NSMutableData alloc]init];
                [bp.dataDict setObject: data forKey:characteristic.UUID.UUIDString];
            }
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

/*Delegate method to write a value to the specified characteristic*/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error writing value %@", error);
        
    }
    NSLog(@"didwritevalueforcharacteristic on peripheral %@", peripheral.identifier.UUIDString);
    /*BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];
    bp.needsToWriteVote = NO;
    [bp.votes removeAllObjects];
    [_centralManager cancelPeripheralConnection:bp.peripheral];*/
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"CentralManager: Error in didUpdateNotificationStateForCharacteristic: %@.", [error localizedDescription]);
        return;
    }
    
    //Checking if we need to stop the connection to the peripheral
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    } else {
        // Notification has stopped
        NSLog(@"Notification stopped on %@", characteristic);
        //[_centralManager cancelPeripheralConnection:peripheral];
    }
}


//This means that there is some new data to consume
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Central Manager: Error in didUpdateValueForCharacteristic: %@.", [error localizedDescription]);
        [self cleanup:peripheral.identifier.UUIDString];
        //if(_isScanning == 0)
        {
            [self startScanningForUserProfiles:_centralManager];
        }
        return;
    }
    
    NSLog(@"did update value for characteristic %@", characteristic.UUID.UUIDString);
    //create BluetoothProfile variable to save data
    BluetoothProfile* bp = [_bluetoothProfiles objectForKey:peripheral.identifier.UUIDString];
    
    //Updating that we got a communication with timestamp
    //bp.timestamp = [[NSDate date] timeIntervalSince1970];
    
    //see if we read the user id
    if([characteristic.UUID.UUIDString isEqualToString:USER_ID_UUID])
    {
        bp.user_id = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        bool alreadyHave = NO;
        //check if the peripheral switched its identifier
        for(NSString* key in [_bluetoothProfiles allKeys])
        {
            BluetoothProfile* check = [_bluetoothProfiles objectForKey:key];
            //We have a match
            //if(check.hasUserId && [check.user_id isEqualToString:bp.user_id])
            if([check.user_id isEqualToString:bp.user_id] && ![check.peripheral.identifier.UUIDString isEqualToString:bp.peripheral.identifier.UUIDString])
            {
                NSLog(@"found an old match");
                //Getting some of the old paramters and migrating them over
                bp.dataDict = [NSMutableDictionary dictionaryWithDictionary:check.dataDict];
                
                //mark the old peripheral as old
                check.isMarkedAsOld = YES;
                alreadyHave = YES;
            }
        }
        
        double currentTime = [[NSDate date] timeIntervalSince1970];
        __block bool inQueue = YES;
        //write to database if it is a new one
        if(!alreadyHave)
        {
            //get current time
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                
                //first see if the user is already in the database
                NSString *peripheralSQL = @"SELECT peripheral_id FROM user WHERE user_id = ? AND is_me != ?";
                NSArray* values = @[bp.user_id, [NSNumber numberWithInt:1]];
                FMResultSet *s = [db executeQuery:peripheralSQL withArgumentsInArray:values];
                
                //get the peripheral ids
                while([s next])
                {
                    NSString* key = [s stringForColumnIndex:0];
                    if(key && key.length)
                    {
                        //delete all expired user ids
                        NSString *deleteSQL = @"DELETE FROM user WHERE peripheral_id = ?";
                        [db executeUpdate:deleteSQL withArgumentsInArray:@[key]];
                    }
                }
                
                NSString *insertUserSQL = @"INSERT INTO user (user_id, is_me, time_since_update, peripheral_id) VALUES (?,?,?,?)";
                NSArray* userValues = @[bp.user_id, [NSNumber numberWithInt:0], [NSNumber numberWithDouble:currentTime], bp.peripheral.identifier.UUIDString];
                [db executeUpdate:insertUserSQL withArgumentsInArray:userValues];
                NSLog(@"inserting into user");
                inQueue = NO;
            }];
        }
        else //need to update the peripheral id and time since update
        {
            NSLog(@"updating peripheral");
            //get the main database
            MainDatabase* md = [MainDatabase shared];
            [md.queue inDatabase:^(FMDatabase *db) {
                NSString *updateSQL = @"UPDATE user SET time_since_update = ?, peripheral_id = ? WHERE user_id = ?";
                NSArray* values = @[[NSNumber numberWithDouble:currentTime], bp.peripheral.identifier.UUIDString, bp.user_id];
                [db executeUpdate:updateSQL withArgumentsInArray:values];
                inQueue = NO;
            }];

        }
        
        //busy loop
        while(inQueue)
            ;
        //bp.hasUserId = YES;
        //bp.peripheral = nil;
        [self queryForNewUserStreams];
        NSLog(@"Bp user id is %@", bp.user_id);
        [_centralManager cancelPeripheralConnection:bp.peripheral];
        [self cleanup:bp.peripheral.identifier.UUIDString];
        return;
    }
    else
    {
        [_centralManager cancelPeripheralConnection:bp.peripheral];
    }
}

//call rest api for parse with nsurlsession to add userstreams of those around me
-(void) queryForNewUserStreams
{
    NSLog(@"query for new users called");
    MainDatabase* md = [MainDatabase shared];
    __block bool inQueue = YES;
    NSMutableArray* userIds = [[NSMutableArray alloc] init];
    [md.queue inDatabase:^(FMDatabase *db) {
        
        
        //need to delete the peripherals that are about to expire
        NSString *userSQL = @"SELECT DISTINCT user_id FROM user WHERE is_me != ?";
        NSArray* values = @[[NSNumber numberWithInt:1]];
        FMResultSet *s = [db executeQuery:userSQL withArgumentsInArray:values];
        //get the peripheral ids
        while([s next])
        {
            NSLog(@"found user");
            [userIds addObject:[s stringForColumnIndex:0]];
        }
        inQueue = NO;
    }];
    
    //busy loop
    /*while(inQueue)
        ;
    
    //count the user ids
    if(userIds.count)
    {
        NSLog(@"calling new streams from nearby users");
        [PFCloud callFunctionInBackground:@"getNewStreamsFromNearbyUsers" withParameters:@{@"userIds":userIds} block:^(id object, NSError *error) {if(error) NSLog(@"error for nearby user streams is %@", error);}];
    }*/
    
}

@end
