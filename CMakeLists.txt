cmake_minimum_required(VERSION 3.29)
project(C_Wire C)

set(CMAKE_C_STANDARD 11)

add_executable(C_Wire
    main.c
        data_tree.c
        process.c
        settings.h
        datatransfer.c
)
