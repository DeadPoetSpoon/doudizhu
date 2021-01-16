# doudizhu（并不完整）

doudizhu by godot

利用Godot制作的十分简单的斗地主，把每一张牌画出来是愚蠢的，但是没办法画图的过程我是快乐的。

主要参考了官方示例

[Multiplayer Bomber](https://github.com/godotengine/godot-demo-projects/tree/master/networking/multiplayer_bomber)

[WebSocket Multiplayer](https://github.com/godotengine/godot-demo-projects/tree/master/networking/websocket_multiplayer)

使用传统WebSocket方式可以通过frp方式间接网络联机而非仅仅局域网联机，而High Level似乎只能局域网，或许能使用其他方式完成。

官方说明了WebSocket对HTML5的支持，但是使用load（将要被废除的方法）加载图片提示错误。于是放弃，说到底其实不该画出每一张牌，13点加4花色进行拼接更好，打包资源也更方便。