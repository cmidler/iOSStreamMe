//
//  CBPeripheralInterface.m
//  Genesis
//
//  Created by Chase Midler on 9/4/14.
//  Copyright (c) 2014 Genesis. All rights reserved.
//


#import "CBPeripheralInterface.h"

@implementation CBPeripheralInterface


- (CBPeripheralInterface *)init {
    NSLog(@"Init peripheral");
    if (self = [super init]) {
        dispatch_queue_t queue= dispatch_queue_create("peripheral_queue", DISPATCH_QUEUE_SERIAL);
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue options:@{ CBPeripheralManagerOptionRestoreIdentifierKey: @"PeripheralManagerIdentifier" }];
        
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
        _peripheralOn = bluetoothStatus.boolValue;
        _userId = nil;
        _uuidArray = @[USER_ID_UUID];
        _advertisedServices = [[NSMutableDictionary alloc] init];
        
        //Fill out characteristics arrays
        _characteristicsArray = [[NSMutableArray alloc]init];
        int i = 0;
        //adding characteristics to be transferred via bluetooth
        for(NSString* uuid in _uuidArray)
        {
            //NSLog(@"characteristic in uuidarray %@", uuid);
            _characteristicsArray[i] = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuid] properties: CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
            
            i++;
        }
    }
    return self;
}

/* helper function to start advertising user data*/
- (void) startAdvertisingProfile {
    NSLog(@"Hit start advertising profile");
    if(_peripheralManager.state != CBPeripheralManagerStatePoweredOn || !_peripheralOn)
    {
        //NSLog(@"peripheral manager state is not powered on %d, state = %d", _peripheralOn, _peripheralManager.state);
        return;
    }
    //else
    //    NSLog(@"peripheral state is = %d", _peripheralManager.state);
    
    //if the user profile doesn't have data then return since we can't broadcast anything
    if(!_userId || !_userId.length)
        return;
    
    [self stopAdvertisingProfile];
    
    NSMutableArray* tmp = [[NSMutableArray alloc]init];
    
    for(NSString* uuid in [_advertisedServices allKeys])
        [tmp addObject:[CBUUID UUIDWithString:uuid]];
    
    NSLog(@"Broadcasting out services for following UUIDs %@ for userid %@", tmp, _userId);
    
    [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : tmp }];
}


- (void) togglePeripheralOn
{
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _peripheralOn = !_peripheralOn;
    [defaults setObject:[NSNumber numberWithBool:_peripheralOn] forKey:@"bluetoothOn"];
    [defaults synchronize];
    
    //turn on scanning or turn it off
    if(_peripheralOn)
        [self startAdvertisingProfile];
    else
        [self stopAdvertisingProfile];
}



//helper method to stop advertising profile
- (void) stopAdvertisingProfile{
    NSLog(@"stopped advertising");
    [_peripheralManager stopAdvertising];
}

////////////////////////////////////////////////
// CBPeripheralManager delegate methods
////////////////////////////////////////////////

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    
    //Checking if we already added the service
    BOOL checkStringInArray = NO;
    
    for(NSString* string in [_advertisedServices allKeys])
    {
        if([string isEqualToString:TRANSFER_SERVICE_UUID])
        {
            checkStringInArray = YES;
            break;
        }
    }
    
    
    //need to setup characteristics
    if (!checkStringInArray) {
       
        _centralsDict = [[NSMutableDictionary alloc]init];
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        //Set characteristics for the transfer service
        transferService.characteristics = _characteristicsArray;
        [_peripheralManager addService:transferService];
        [_advertisedServices setObject:transferService forKey:TRANSFER_SERVICE_UUID];
    }
    
    
    //Now call helper method to start advertising
    [self startAdvertisingProfile];
    
}


/* called anytime a new service is added */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    //NSLog(@"PeripheralManager: Added service %@.", service.UUID.UUIDString);
    if (error) {
        NSLog(@"PeripheralManager: Error in didAddService: %@.", [error localizedDescription]);
        return;
    }
    
    NSLog(@"Adding service with uuid %@", service.UUID.UUIDString);
    
    
    //For each new service added, stop advertising and call start advertising
    //[_peripheralManager stopAdvertising];
    [self startAdvertisingProfile];
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    //NSLog(@"PeripheralManager: Started advertising.");
    if (error) {
        //NSLog(@"PeripheralManager: Error in peripheralManagerDidStartAdvertising: %@.", [error localizedDescription]);
    }
}


//State restorations delegate method
- (void)peripheralManager:(CBPeripheralManager *)peripheral
      willRestoreState:(NSDictionary *)state {
    
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
    _peripheralOn = bluetoothStatus.boolValue;
    
    [self stopAdvertisingProfile];
    
    //Alloc myPollsArray
    //_myPollsArray = [[NSMutableArray alloc] init];
    
    //get the main database
    MainDatabase* md = [MainDatabase shared];
    [md.queue inDatabase:^(FMDatabase *db) {
        
        NSString *querySQL = @"SELECT user_id FROM user WHERE is_me = \"1\"";
        FMResultSet *s = [db executeQuery:querySQL];
        //get the user profile
        while([s next])
            _userId = [s stringForColumnIndex:0];
        [self startAdvertisingProfile];
    }];
    NSLog(@"Init peripheral");
    dispatch_queue_t queue= dispatch_queue_create("peripheral_queue", DISPATCH_QUEUE_SERIAL);
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue options:@{ CBPeripheralManagerOptionRestoreIdentifierKey: @"PeripheralManagerIdentifier" }];
    _uuidArray = @[USER_ID_UUID];
    _advertisedServices = [[NSMutableDictionary alloc] init];
    //Fill out characteristics arrays
    _characteristicsArray = [[NSMutableArray alloc]init];
    int i = 0;
    //adding characteristics to be transferred via bluetooth
    for(NSString* uuid in _uuidArray)
    {
        //NSLog(@"characteristic in uuidarray %@", uuid);
        _characteristicsArray[i] = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuid] properties: CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
        
        i++;
    }
    
   
    NSLog(@"WILL RESTORE STATE HIT IN PERIPH");
    //NSLog(@"%@, %@, %@, %@, %@, %@, %@, %@", profile.first_name, profile.age, profile.sex, profile.relationship_status, profile.interested_in, profile.is_open, profile.facebookID, profile.picture_data_length);
    
}


//handle read requests
- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    
    NSLog(@"read request");
    NSData* userId = [_userId dataUsingEncoding:NSUTF8StringEncoding];
    //See if the read request is for the user id
    if ([request.characteristic.UUID.UUIDString isEqualToString:USER_ID_UUID]) {
        if (request.offset > userId.length) {
            [_peripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            NSLog(@"received request offset %d and userid length %d", (int)request.offset, (int)userId.length);
            return;
        }
        
        request.value = [userId subdataWithRange:NSMakeRange(request.offset, userId.length - request.offset)];
        [_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}




//Function to send data to subscribed centrals
/*- (void)sendData {
    //looping through all centrals to see if data is there to send
    for(NSString* centralUUID in [_centralsDict allKeys])
    {
        NSArray* centralArray = _centralsDict[centralUUID];
        NSMutableDictionary* sendDataDict = (NSMutableDictionary*)centralArray[0];
        //See if there is data to send in any of the characteristics
        for (NSString* key in [sendDataDict allKeys])
        {
            // Is there any left to send?
            CharacteristicData* cd = sendDataDict[key];
            
            //No data to send for this characteristic
            if(!cd.dataToSend || cd.dataToSend.length ==0)
                continue;
            
            //NSLog(@"data to send is %@", cd.characteristic.UUID.UUIDString);
            
            NSArray* centrals = nil;
            //check if we will broadcast to all centrals or just to a subscribed one
            if(cd.dataToSend.length>NOTIFY_MTU)
                centrals = [[NSArray alloc] initWithObjects:(CBCentral*)centralArray[1], nil];
            
            //checking that we sent all of data and EOM
            if (cd.sendDataIndex >= cd.dataToSend.length && cd.eomSent) {
                continue;
            }
            //if we sent all of the data but not eom, try to send eom
            if (cd.sendDataIndex >= cd.dataToSend.length)
            {
                [self sendEOM:cd.characteristic forCentral:centralUUID];
                continue;
            }
            
            // There's data left, so send until the callback fails, or we're done.
            BOOL didSend = YES;
            
            while (didSend) {
                // Work out how big it should be
                NSInteger amountToSend = cd.dataToSend.length - cd.sendDataIndex;
                
                // Can't be longer than 20 bytes for some phones
                if(amountToSend>cd.centralMaximumUpdateValueLength)
                    amountToSend = cd.centralMaximumUpdateValueLength;
                
                // Copy out the data we want
                NSData *chunk = [NSData dataWithBytes:cd.dataToSend.bytes+cd.sendDataIndex length:amountToSend];
                
                didSend = [self.peripheralManager updateValue:chunk forCharacteristic:(CBMutableCharacteristic*)cd.characteristic onSubscribedCentrals:centrals];
                
                // If it didn't work, drop out and wait for the callback
                if (!didSend) {
                    continue;
                }
                
                // It did send, so update our index
                cd.sendDataIndex += amountToSend;
        
                // Was it the last one?
                if (cd.sendDataIndex >= cd.dataToSend.length) {
                    [self sendEOM:cd.characteristic forCentral:centralUUID];
                    continue;
                }
            }
        }
    }
}


//Function to send EOM
- (void) sendEOM: (CBCharacteristic*) characteristic forCentral: (NSString*) centralUUID
{
    NSArray* centralArray = _centralsDict[centralUUID];
    NSMutableDictionary* sendDataDict = (NSMutableDictionary*)centralArray[0];
    CharacteristicData* cd = sendDataDict[characteristic.UUID.UUIDString];
    
    NSArray* centrals = nil;
    //check if we will broadcast to all centrals or just to a subscribed one
    if(cd.dataToSend.length>NOTIFY_MTU)
        centrals = [[NSArray alloc] initWithObjects:(CBCentral*)centralArray[1], nil];
    
    cd.eomSent = [self.peripheralManager updateValue:[EOM_UUID dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic*)characteristic onSubscribedCentrals:centrals];
    if (!cd.eomSent)
        return;
    
    NSLog(@"Sent EOM FOR %@", characteristic.UUID.UUIDString);
    
    //check if we sent all data to the central
    for (NSString* charUUID in [sendDataDict allKeys])
    {
        CharacteristicData* charData = sendDataDict[charUUID];
        //if eomsent is false, return.
        if (!charData.eomSent)
            return;
    }
    
    
    //got here and need to remove central
    //NSLog(@"removing central from dict");
    if ([[_centralsDict allKeys] containsObject:centralUUID])
    {
        //[(NSTimer*)centralArray[2] invalidate];
        [_centralsDict removeObjectForKey:centralUUID];
    }
    
}*/

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"PeripheralManager: Is ready to update subscribers.");
    //[self sendData];
}

@end
