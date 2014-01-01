//
//  Profile.m
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Profile.h"
#import "Globals.h"
#import "Charity.h"
#import "MyCharity.h"

NSString* profileFile = @"user_profile";

@implementation Profile

@synthesize userImg;

- (id) init {
    
    self = [super init];
    
    if (self) {
        charities = [[NSMutableDictionary alloc] initWithCapacity:10];
        myCharities = [[NSMutableDictionary alloc] init];
        
        [self addDefCharities];
        [self addDefMyCharities];
    }
    
    return self;
}

+ (id) loadFromArchive {
    
    Profile* retProfile = nil;
    NSString* filePath = getDocPath(profileFile);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];

        @try {
            retProfile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
        }
    }
    
    return retProfile;
}

- (void) save {
    @synchronized(self) {
        NSString* filePath = getDocPath(profileFile);
        [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:userImg forKey:@"User Image"];
    [coder encodeObject:charities forKey:@"Charities List"];
    [coder encodeObject:myCharities forKey:@"My Charities List"];
}

- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super init];
    
    if (self) {
        userImg = [coder decodeObjectForKey:@"User Image"];

        charities = [coder decodeObjectForKey:@"Charities List"];
        if (!charities){
            charities = [[NSMutableDictionary alloc] initWithCapacity:10];
            [self addDefCharities];
        }
        
        myCharities = [coder decodeObjectForKey:@"My Charities List"];
        if (!myCharities) {
            myCharities = [[NSMutableDictionary alloc] init];
            [self addDefMyCharities];
        }
    }
    
    return self;
}

- (void) addMyCharity:(NSString*) name {
    
    MyCharity* myCharity = [[MyCharity alloc] initWithName:name];
    [myCharities setObject:myCharity forKey:name];
}

- (MyCharity*) myCharityByName:(NSString*) charityName {
    MyCharity* myCharity = [myCharities objectForKey:charityName];
    
    if (!myCharity) {
        myCharity = [[MyCharity alloc] initWithName:charityName];
        [myCharities setObject:myCharity forKey:charityName];
    }
    
    return myCharity;
}

- (NSDictionary*) getCharities {
    return charities;
}

- (void) setUserImg:(UIImage*) img {
    userImg = img;
    [self save];
}

- (void) addDefMyCharities {
    NSArray* arrCharities = [charities allValues];
    
    for(Charity* charity in arrCharities) {
        MyCharity* myCharity = [[MyCharity alloc] initWithName:charity.name];
        
        myCharity.steps = [[NSMutableString alloc] initWithFormat:@"%d", arc4random() % 10000];
        
        long stepsPerDollar = [charity.stepsPerDollar intValue];
        int moneyRaised = (int) [myCharity.steps intValue] / stepsPerDollar;
        
        myCharity.stepsPerDollar = charity.stepsPerDollar;
        myCharity.momeyRaised = [[NSMutableString alloc] initWithFormat:@"%d", moneyRaised];
        
        [myCharities setObject:myCharity forKey:charity.name];
    }
}

// Load the basic profile
- (void) addDefCharities {
    
    // Set default set of charities 
    struct Provider {
        char* name;
        char* description;
        char* joined;
        char* money;
        char* iconPath;
        char* url;
    };
    
    struct Provider providers[] = { {"American Heart Association Heart Walk",   "The American Heart Association is a non-profit organization in the United States that fosters appropriate cardiac care in an effort to reduce disability and deaths caused by cardiovascular disease and stroke. It is headquartered in Dallas, Texas", "12346" ,"64791", "heart.png", "http://www.cnn.com"},
        {"Habitat for humanity",                    "Habitat for Humanity International, generally referred to as Habitat for Humanity or simply Habitat, is an international, non-governmental, and non-profit organization, which was founded in 1976","11093" ,"72889", "habitat.png", "www.msnbc.com"},
        {"SPCA of San Francisco Cat & Dog Walk",    "	The Society for the Prevention of Cruelty to Animals in Israel—Tel Aviv-Yafo, is a philanthropic organization without any goal of a profit, which was founded in the year 1927, and which has been operating since then to prevent suffering and pain to animals.","11002" ,"52363", "Spca.png", "www.apple.com"},
        {"American Red Cross Walkathon",            "The American Red Cross, also known as the American National Red Cross, is a humanitarian organization that provides emergency assistance, disaster relief and education inside the United States", "9768" ,"42405", "redCross.png", "www.yahoo.com"}
    };

    int size  = sizeof(providers) / sizeof(providers[0]);
    
    for(int i= 0; i < size; i++) {
        Charity* charity = [[Charity alloc] initWithValues:[NSString stringWithUTF8String:providers[i].name]
                                               description:[NSString stringWithUTF8String:providers[i].description]
                                                    joined:[NSString stringWithUTF8String:providers[i].joined]
                                               moneyRaised:[NSString stringWithUTF8String:providers[i].money]
                                                  iconPath:[NSString stringWithUTF8String:providers[i].iconPath]
                                                       url:[NSString stringWithUTF8String:providers[i].url]];
        [charities setObject:charity forKey:charity.name];
    }
}

@end
