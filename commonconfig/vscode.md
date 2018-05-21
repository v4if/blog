## plugins
[ms-vscode.cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
![ms-vscode.cpptools](https://ms-vscode.gallerycdn.vsassets.io/extensions/ms-vscode/cpptools/0.17.0/1525737226765/Microsoft.VisualStudio.Services.Icons.Default)

[vscode-clang](https://marketplace.visualstudio.com/items?itemName=mitaki28.vscode-clang)
`使用Clang实时分析，什么模板嵌套都能分析，功能异常强大，需要指定clang路径，可以在c_cpp_properties.json中添加includePath`

[twxs.cmake](https://marketplace.visualstudio.com/items?itemName=twxs.cmake)
![twxs.cmake](https://twxs.gallerycdn.vsassets.io/extensions/twxs/cmake/0.0.17/1488841920286/Microsoft.VisualStudio.Services.Icons.Default)

## User Settings
```bash
# 文件 -> 首选项 -> 设置

{
    "window.zoomLevel": 1,
    "editor.minimap.enabled": false,
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
    
    # 关闭预览模式，
    "workbench.editor.enablePreview": false,
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
