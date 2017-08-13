C++11 thread线程库
```bash
cmake_minimum_required(VERSION 3.8)
project(C11_Test)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp)

add_executable(C11_Test ${SOURCE_FILES})
target_link_libraries (C11_Test pthread)
```
