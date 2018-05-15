## plugins
[ms-vscode.cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
[vscode-clang](https://marketplace.visualstudio.com/items?itemName=mitaki28.vscode-clang)
> 使用Clang实时分析，什么模板嵌套都能分析，功能异常强大，需要指定clang路径

## User Settings
```bash
# 文件 -> 首选项 -> 设置

{
    "window.zoomLevel": 1,
    "editor.minimap.enabled": false,
    "http.proxy": "http://10.170.27.50:1080",
    "http.proxyStrictSSL": false,
    
    "clang.executable": "C:/Program Files/LLVM/bin/clang.exe",
    "clang.completion.enable": true,
    "clang.completion.triggerChars": [
    ".",
    ":",
    ">"],
    "clang.cxxflags": ["-std=c++11"]
}
```

## c_cpp_properties.json
```bash
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
