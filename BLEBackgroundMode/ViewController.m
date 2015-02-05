//
//  ViewController.m
//  BLEBackgroundMode
//
//  Created by Mario Zhang on 13-12-30.
//  Copyright (c) 2013年 Mario Zhang. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManger;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) NSTimer *timer;

- (void)readRSSI;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.centralManger = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:nil];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)readRSSI
{
  DLog();
  if (self.peripheral) {
    [self.peripheral readRSSI];
  }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  DLog();
  if (central.state == CBCentralManagerStatePoweredOn) {
    [self.centralManger scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"66B9"]]
                                               options:nil];
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
  DLog(@"peripheral name %@ id %@ rssi %d", peripheral.name, peripheral.identifier, [RSSI integerValue]);

  self.peripheral = peripheral;
  [self.centralManger connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
  DLog();
  self.peripheral.delegate = self;
  if (!self.timer) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(readRSSI)
                                                userInfo:nil
                                                 repeats:1.0];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
  }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  [self.centralManger connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
  if (!error) {
    NSLog(@"rssi %d", [[peripheral RSSI] integerValue]);
  }
}

@end
