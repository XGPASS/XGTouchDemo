## 主要内容
手势密码解锁和指纹TouchID解锁的demo，逐步修改中...
### 注意
设置TouchID，需要在真机模式下设置，模拟器无法设置;
保存密码解锁类型和状态用的是NSUserDefaults存储，如果设置好解锁类型或状态，立即重新运行会出现保存失败的bug，
经查相关文章，这是Xcode的bug，调试的时候断开Xcode链接，则无此bug;
###效果如图
![image](https://github.com/XGPASS/XGTouchDemo/blob/master/images/develop.gif)
