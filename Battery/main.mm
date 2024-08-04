//
//  main.cpp
//  Battery
//
//  Created by 江晚 on 2024/8/4.
//

#import <Foundation/Foundation.h>
#include "SMCBridge.h"
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <map>
#include <thread>
#include <unistd.h>

// ANSI颜色代码
const std::string RESET = "\033[0m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string YELLOW = "\033[33m";
const std::string BLUE = "\033[34m";
const std::string MAGENTA = "\033[35m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[37m";

// 获取电池温度 --获取的并不准确
double getBatteryTemperature() {
  io_service_t service = IOServiceGetMatchingService(
      kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"));
  if (service) {
    CFTypeRef temperatureRef = IORegistryEntryCreateCFProperty(
        service, CFSTR("Temperature"), kCFAllocatorDefault, 0);
    if (temperatureRef) {
      if (CFGetTypeID(temperatureRef) == CFNumberGetTypeID()) {
        double temperature;
        if (CFNumberGetValue((CFNumberRef)temperatureRef, kCFNumberDoubleType,
                             &temperature)) {
          CFRelease(temperatureRef);
          IOObjectRelease(service);
          return temperature / 100.0;
        }
      }
      CFRelease(temperatureRef);
    }
    IOObjectRelease(service);
  }
  return 0; // 错误
}


double getBatterySensorsTemperature() {
    auto value = std::max([[SMCBridge sharedInstance] getValueForKey:@"TB1T"],[[SMCBridge sharedInstance] getValueForKey:@"TB2T"]);
    double roundedValue = std::round(value * 10.0) / 10.0;
    return roundedValue;
}

// 输出带有延迟的文本
void printWithDelay(const std::string &text, int delayMs) {
  for (char ch : text) {
    std::cout << ch;
    std::cout.flush();
    std::this_thread::sleep_for(std::chrono::milliseconds(delayMs));
  }
}

// 输出带有颜色和延迟的文本
void printWithColorAndDelay(const std::string &text, const std::string &color,
                            int delayMs) {
  std::cout << color;
  printWithDelay(text, delayMs);
  std::cout << RESET;
}

// 显示菜单
void displayMenu() {
  printWithColorAndDelay("======== Battery Temperature Monitor ========\n",
                         BLUE, 30);
  printWithColorAndDelay("1. 中文\n", GREEN, 30);
  printWithColorAndDelay("2. English\n", GREEN, 30);
  printWithColorAndDelay("3. 日本語\n", GREEN, 30);
  printWithColorAndDelay("Please select a language (1/2/3): ", CYAN, 30);
}

// 显示语言选项和获取保护温度
void displayLanguageOptions(int choice) {
  switch (choice) {
  case 1: // 中文
    printWithColorAndDelay("======== 电池温度监控======== \n", BLUE, 30);
    printWithColorAndDelay("电池温度过高，电池寿命会缩短。\n", BLUE, 30);
    printWithColorAndDelay("请及时降低电池温度。\n", BLUE, 30);
    printWithColorAndDelay("作者: JiangNight\n", MAGENTA, 30);
    break;
  case 2: // English
    printWithColorAndDelay("======== Battery Temperature Monitor ========\n",
                           BLUE, 30);
    printWithColorAndDelay(
        "Battery temperature is too high, battery life will be shortened.\n",
        BLUE, 30);
    printWithColorAndDelay("Please reduce the battery temperature in time.\n",
                           BLUE, 30);
    printWithColorAndDelay("Author: JiangNight\n", MAGENTA, 30);
    break;
  case 3: // 日本語
    printWithColorAndDelay("======== バッテリー温度モニター ========\n", BLUE,
                           30);
    printWithColorAndDelay(
        "バッテリー温度が高すぎると、バッテリー寿命が短くなります。\n", BLUE,
        30);
    printWithColorAndDelay("バッテリー温度を早めに下げてください。\n", BLUE,
                           30);
    printWithColorAndDelay("著者: JiangNight\n", MAGENTA, 30);
    break;
  default:
    printWithDelay("Invalid choice\n", 30);
    exit(1);
  }
}

// 获取语言选项
void getLanguageOptions(int choice, std::string &tempMessage,
                        std::string &highTempMessage,
                        std::string &lowTempMessage,
                        std::string &inputTempMessage,
                        std::string &inputIntervalMessage) {
  switch (choice) {
  case 1: // 中文
    tempMessage = "当前电池温度: ";
    highTempMessage = "电池温度过高,已自动开启节能模式\n";
    lowTempMessage = "电池温度已恢复正常，节能模式已关闭。\n";
    inputTempMessage = "请输入电池温度保护值（摄氏度）：";
    inputIntervalMessage = "请输入检查间隔时间（秒）：";
    break;
  case 2: // English
    tempMessage = "Current battery temperature: ";
    highTempMessage = "Battery temperature is too high, power saving mode has "
                      "been automatically turned on.\n";
    lowTempMessage = "Battery temperature has returned to normal, power saving "
                     "mode has been turned off.\n";
    inputTempMessage =
        "Please enter the battery temperature protection value (Celsius): ";
    inputIntervalMessage = "Please enter the check interval time (seconds): ";
    break;
  case 3: // 日本語
    tempMessage = "現在のバッテリー温度: ";
    highTempMessage = "バッテリー温度が高すぎます。省エネモードが自動的にオンに"
                      "なりました。\n";
    lowTempMessage =
        "バッテリー温度が正常に戻りました。省エネモードがオフになりました。\n";
    inputTempMessage = "バッテリー温度保護値（摂氏）を入力してください：";
    inputIntervalMessage = "チェック間隔時間（秒）を入力してください：";
    break;
  default:
    printWithColorAndDelay("Invalid choice\n", RED, 30);
    exit(1);
  }
}

// 启用或禁用节能模式
void setPowerSavingMode(bool enable) {
  if (enable) {
    system("pmset -a powermode 1");
  } else {
    system("pmset -a powermode 0");
  }
}

// 监听温度
void temperatureMonitoring(double protect_temperature, int check_interval,
                           const std::string &tempMessage,
                           const std::string &highTempMessage,
                           const std::string &lowTempMessage) {
  bool powerSavingModeEnabled = false;
  while (true) {
      double temperature = getBatterySensorsTemperature();
        // 使用 stringstream 进行格式化
        std::stringstream ss;
        ss << std::fixed << std::setprecision(1) << temperature;
        std::string formattedTemperature = ss.str();
    if (temperature != 0.0) {
      if (temperature > protect_temperature) {
        if (!powerSavingModeEnabled) {
          printWithColorAndDelay(
              tempMessage + formattedTemperature + "°C\n", CYAN, 30);
          setPowerSavingMode(true);
          printWithColorAndDelay(highTempMessage, RED, 30);
          powerSavingModeEnabled = true;
        }
      } else {
        if (powerSavingModeEnabled) {
          printWithColorAndDelay(
              tempMessage + formattedTemperature + "°C\n", CYAN, 30);
          setPowerSavingMode(false);
          printWithColorAndDelay(lowTempMessage, GREEN, 30);
          powerSavingModeEnabled = false;
        }
      }
    } else {
      printWithColorAndDelay("Unable to retrieve temperature.\n", RED, 30);
      exit(1);
    }
    std::this_thread::sleep_for(std::chrono::seconds(check_interval));
  }
}

int main() {
  if (geteuid() != 0) {
    printWithColorAndDelay("Please run this program with sudo.\n", RED, 30);
    return 1;
  }

  displayMenu();

  int choice;
  std::cin >> choice;

  double protect_temperature;
  int check_interval;

  // 获取语言选项
  std::string tempMessage, highTempMessage, lowTempMessage, inputTempMessage,
      inputIntervalMessage;
  getLanguageOptions(choice, tempMessage, highTempMessage, lowTempMessage,
                     inputTempMessage, inputIntervalMessage);

  // printWithColorAndDelay("\n======== Battery Temperature Monitor ========\n",
  //                        30);
  displayLanguageOptions(choice);

  printWithColorAndDelay(inputTempMessage, CYAN, 30);
  std::cin >> protect_temperature;

  printWithColorAndDelay(inputIntervalMessage, CYAN, 30);
  std::cin >> check_interval;

  std::thread monitoringThread(temperatureMonitoring, protect_temperature,
                               check_interval, tempMessage, highTempMessage,
                               lowTempMessage);
  monitoringThread.detach(); // 使线程在后台运行

  // 主线程保持运行
  while (true) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
  }

  return 0;
}
