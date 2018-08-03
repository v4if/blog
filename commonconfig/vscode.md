## plugins
[ms-vscode.cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
![ms-vscode.cpptools](https://ms-vscode.gallerycdn.vsassets.io/extensions/ms-vscode/cpptools/0.17.0/1525737226765/Microsoft.VisualStudio.Services.Icons.Default) C/C++ Preview

[vscode-clang](https://marketplace.visualstudio.com/items?itemName=mitaki28.vscode-clang)
C/C++ Clang Command Adapter `使用Clang实时分析，什么模板嵌套都能分析，功能异常强大，需要指定clang路径，可以在c_cpp_properties.json中添加includePath`

[twxs.cmake](https://marketplace.visualstudio.com/items?itemName=twxs.cmake)
![twxs.cmake](https://twxs.gallerycdn.vsassets.io/extensions/twxs/cmake/0.0.17/1488841920286/Microsoft.VisualStudio.Services.Icons.Default) CMake

[sftp](https://marketplace.visualstudio.com/items?itemName=liximomo.sftp)
![sftp](https://liximomo.gallerycdn.vsassets.io/extensions/liximomo/sftp/1.2.3/1530090897991/Microsoft.VisualStudio.Services.Icons.Default)
开发机文件自动同步

[ftp-simple](https://marketplace.visualstudio.com/items?itemName=humy2833.ftp-simple)
![ftp-simple](https://humy2833.gallerycdn.vsassets.io/extensions/humy2833/ftp-simple/0.6.7/1529308303570/Microsoft.VisualStudio.Services.Icons.Default)与sftp作用相同，可配合SSHExtension使用Open SSH Connection

[SSHExtension](https://marketplace.visualstudio.com/items?itemName=kondratiev.sshextension)
![SSHExtension](https://kondratiev.gallerycdn.vsassets.io/extensions/kondratiev/sshextension/0.2.1/1512571641774/Microsoft.VisualStudio.Services.Icons.Default) Open SSH Connection

[Diff Tool](https://marketplace.visualstudio.com/items?itemName=jinsihou.diff-tool)

## 快捷键
`Ctrol + 鼠标左键` : 代码跳转

`Alt + <-` : 回退

## User Settings
```bash
# 文件 -> 首选项 -> 设置

{
    "window.zoomLevel": 0,
    "editor.minimap.enabled": false,
    "editor.fontFamily": "'YaHei Monaco Hybird', Consolas, 'Courier New', monospace",
    "editor.fontSize": 18,
    
    "http.proxy": "http://10.170.27.50:1080",
    "http.proxyStrictSSL": false,
    
    "cmake.cmakePath": "C:/Program Files/CMake/bin/cmake.exe",
    
    # LF
    "files.eol":"\n",
    # 宽度超过屏幕自动换行
    "editor.wordWrap": "on",
    
    "clang.executable": "C:/Program Files/LLVM/bin/clang.exe",
    "clang.completion.enable": true,
    "clang.completion.triggerChars": [
    ".",
    ":",
    ">"],
    "clang.cxxflags": ["-std=c++11"],
    
    # 关闭预览模式，打开文件时在新选项卡而不是覆盖原来文件
    "workbench.editor.enablePreview": false,
    # add new line at end of file
    "files.insertFinalNewline": true,
    
    # 将cmd替换为bash
    "terminal.integrated.shell.windows": "C:/Program Files/Git/bin/bash.exe",
    "terminal.integrated.shellArgs.windows": [
        "--login", "-i"
    ],
    # 控制资源管理器是否应在删除文件到废纸篓时进行确认
    "explorer.confirmDelete": false
}
```

## c_cpp_properties.json
```bash
# 打开命令模式，选择[C/Cpp: Edit Configurations]

{
    "configurations": [
        {
            "name": "Win32",
            "browse": {
                "path": [
                    "${workspaceFolder}"
                ],
                "limitSymbolsToIncludedHeaders": true
            },
            "includePath": [
                "${workspaceFolder}",
                "${workspaceFolder}/include",
                "${workspaceFolder}/build"
            ],
            "defines": [
                "_DEBUG",
                "UNICODE",
                "_UNICODE"
            ],
            "cStandard": "c11",
            "cppStandard": "c++17",
            "intelliSenseMode": "msvc-x64"
        }
    ],
    "version": 4
}
```

## sftp.json
```bash
# Ctrl + Shift + P -> SFTP:config

{
    "protocol": "sftp",
    "host": "",
    "username": "",
    "password": "",
    "port": ,
    "uploadOnSave": false,
    "downloadOnOpen": false,
    "watcher": {
        "files": "**/*",
        "autoUpload": true,
        "autoDelete": true
    },
    "ignore": [
        "node_modules",
        ".vscode",
        ".idea",
        ".DS_Store"
    ],
    "remotePath": ""
}

```

## ftp-simple.json
```bash
# Ctrl + Shift + P -> ftp-simple:config

[
	{
		"name": "RemoteServer",
		"host": "",
		"port": ,
		"type": "sftp",
		"username": "",
		"password": "",
		"path": "",
		"autosave": false,
		"confirm": true
	}
]
```
