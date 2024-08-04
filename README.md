# MacOSBattery
<<<<<<< HEAD
MacOS Battery Manager.
=======
### 一款监控Mac电池温度的插件

 非常适合`Air`这种没有风扇的用户使用(doge)，检测到温度过高自动开启节能模式，以保护电池健康（虽然我也不知道这样做用途大不大，但是身边有好多朋友都是这样做的），由于本人并非专业Mac开发，~~甚至不会swift和oc~~，所以只能做到使用终端启动，并不能制作好看的ui打包为App，欢迎各位Mac开发大佬打包成app维护

---

## 功能：

- 支持三个国家的语言（中文，English，日语）英语及日语均使用`ChatGPT`翻译，如有不对欢迎提交
- 自定义温度阀值
- 自定义检查时间（就是多久检查一次，减少性能开支）
- 检测到温度超过设置的阀值自动开启节能模式
- 检测到温度降下来后自动关闭节能模式

### ~~缺点~~：

- 仅支持`Apple Silicon`芯片
- 只能通过终端启动
- 并且终端要一直挂在后台，不能关闭
- ~~垃圾的代码风格~~

---

## 使用：

打开终端

```shell
cd <下载的目录>
chmod 777 Battery
sudo ./Battery
```

>  注意⚠️：必须使用sudo执行，因为打开节能模式需要权限



---

## 下载：

[Releases v1.0](https://github.com/Jiang-Night/MacOSBattery/releases/tag/1.0)

---

## 鸣谢

- [Stats](https://github.com/exelban/stats) : 获取电池温度一开始是从ioreg读取的，但是从ioreg读取的温度不准确，最终在Stats项目中扣出了获取温度的代码(详见smc.swift)
- QQ群中的`QuickRecorder`大佬，Github主页：[lihaoyun6](https://github.com/lihaoyun6)
>>>>>>> 10a0015 (更改REEADME.md)
