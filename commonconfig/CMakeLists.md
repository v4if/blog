```CMakeLists
cmake_minimum_required(VERSION 3.0)
project(async_rpc_echo)

set(CMAKE_CXX_FLAGS "-g -Wall -Werror -std=c++14")

find_package(Boost REQUIRED COMPONENTS system filesystem thread)
include_directories(${Boost_INCLUDE_DIRS})

find_package(Protobuf REQUIRED)
include_directories(${Protobuf_INCLUDE_DIRS})

protobuf_generate_cpp(Meta_src Meta_hdr meta.proto)
protobuf_generate_cpp(Echo_src Echo_hdr echo.proto)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

aux_source_directory(../../src Core_Src)

add_executable(async_client ${Core_Src} async_client.cpp ${Meta_hdr} ${Meta_src} ${Echo_hdr} ${Echo_src})
add_executable(async_server ${Core_Src} async_server.cpp ${Meta_hdr} ${Meta_src} ${Echo_hdr} ${Echo_src})
target_link_libraries(async_client ${Boost_LIBRARIES} ${Protobuf_LIBRARIES})
target_link_libraries(async_server ${Boost_LIBRARIES} ${Protobuf_LIBRARIES})


#include_directories(${CMAKE_CURRENT_LIST_DIR}/include)
#link_directories(${CMAKE_CURRENT_LIST_DIR}/lib)
#aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/src ${hello_src})
#add_executable(${PROJECT_NAME} ${hello_src})
#target_link_libraries(${PROJECT_NAME} util)
#set(CMAKE_CXX_COMPILER      "clang++" )         # 显示指定使用的C++编译器
#set(CMAKE_CXX_FLAGS   "-std=c++11")             # c++11
#set(CMAKE_CXX_FLAGS   "-g")                     # 调试信息
#set(CMAKE_CXX_FLAGS   "-Wall")                  # 开启所有警告
#set(CMAKE_CXX_FLAGS_DEBUG   "-O0" )             # 调试包不优化
#set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG " )   # release包优化 
```


## 一些有用的命令
`cmake --help-module FindProtobuf`
