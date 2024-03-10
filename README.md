# go_author_client

目前只适配了pc端

## 运行项目

删除项目下的build、macos、windows目录, 根本运营平台重新启用mac或者windows, 再运行即可。这一步不会的请稳步flutter官方文档学习项目的构建和运行

## Mac平台DIO无法访问网络

在*package*/macos/Runner下DebugProfile.entilements与Release.entilements添加网络访问权限：

```
<key>com.apple.security.network.client</key>
<true/>
```

