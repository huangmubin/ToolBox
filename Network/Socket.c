//
//  Socket.c
//  Socket10
//
//  Created by Myron on 2017/4/13.
//  Copyright © 2017年 Myron. All rights reserved.
//

// MARK: - Include

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>

#include <stdlib.h>
#include <unistd.h>

#include <fcntl.h>

#include <errno.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

#define ERROR_SOCKET        -1
#define ERROR_BIND          -2
#define ERROR_LISTION       -3
#define ERROR_ACCEPT        -4
#define ERROR_CONNECT       -5
#define ERROR_REUSEADDR     -6

#define ERROR_READ          -7
#define ERROR_WRITE         -8

#define ERROR_SELECT        -9
#define ERROR_TIMEOUT       -10

// MARK: - Tools

// MARK: Input

// @_silgen_name("socket_input") private func c_socket_input(input: UnsafePointer<UInt8>, length: Int32) -> Void
void socket_input(void * input, int size) {
    bzero(input, size);
    fgets(input, size, stdin);
}

/** 获取当前局域网 IP 地址 */
// @_silgen_name("socket_host_address") private func c_socket_host_address() -> UnsafePointer<UInt8>
char *socket_host_address() {
    
    char *address = "127.0.0.1";
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if (strcmp(temp_addr->ifa_name, "en0") == 0) {
                    // Get Address
                    address = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}


// MARK: - 阻塞

/// 0 为非阻塞
void socket_isblock(int socket, int on) {
    int flags = fcntl(socket, F_GETFL, 0);
    if (on == 0) {
        fcntl(socket, F_SETFL, flags | O_NONBLOCK);
    } else {
        flags &= ~ O_NONBLOCK;
        fcntl(socket, F_SETFL, flags);
    }
}

// MARK: - 关闭

// @_silgen_name("socket_close") private func c_socket_close(socket: Int32) -> Int32
/** 关闭 socket 连接 */
int socket_close(int socket) {
    return close(socket);
}

// @_silgen_name("socket_shutdown") private func c_socket_shutdown(socket: Int32, howto: Int32) -> Int32
/** 断开连接 */
int socket_shutdown(int socket, int howto) {
    return shutdown(socket, howto);
}


// MARK: - TCP

// @_silgen_name("socket_tcp_new_server") private func c_socket_tcp_create_server(port: Int32, listens: Int32) -> Int32
int socket_tcp_new_server(int port, int listen_count) {
    //创建 Socket TCP
    int server_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (server_socket == -1) {
        perror("socket error");
        return ERROR_SOCKET;
    }
    
    // 创建 Socket 地址结构
    struct sockaddr_in server_addr;
    server_addr.sin_len         = sizeof(struct sockaddr_in);
    server_addr.sin_family      = AF_INET;
    server_addr.sin_port        = htons(port);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    bzero(&(server_addr.sin_zero),8);
    
    // Bind
    int bind_result = bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (bind_result == -1) {
        perror("bind error");
        return ERROR_BIND;
    }
    
    //listen侦听 第一个参数是套接字，第二个参数为等待接受的连接的队列的大小，在connect请求过来的时候,完成三次握手后先将连接放到这个队列中，直到被accept处理。如果这个队列满了，且有新的连接的时候，对方可能会收到出错信息。
    int listen_result = listen(server_socket, listen_count);
    if (listen_result == -1) {
        perror("listen error");
        return ERROR_LISTION;
    }
    
    // SO_NOSIGPIPE
    int set = 1;
    setsockopt(server_socket, SOL_SOCKET, SO_NOSIGPIPE, &set, sizeof(int));
    
    return server_socket;
}

// @_silgen_name("socket_tcp_new_client") private func c_socket_tcp_create_client(address: UnsafePointer<UInt8>, port: Int32, sec: Int32, usec: Int32) -> Int32
int socket_tcp_new_client(const char * address, int port, int sec, int usec) {
    int client_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (client_socket == -1) {
        perror("socket error");
        return ERROR_SOCKET;
    }
    
    struct sockaddr_in server_addr;
    server_addr.sin_len = sizeof(server_addr);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    server_addr.sin_addr.s_addr = inet_addr(address);
    bzero(&(server_addr.sin_zero),8);
    
    // SO_NOSIGPIPE
    int set = 1;
    setsockopt(client_socket, SOL_SOCKET, SO_NOSIGPIPE, &set, sizeof(int));
    
    // TIME
    if (sec > 0 || usec > 0) {
        socket_isblock(client_socket, 0);
        int connect_result = connect(client_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));
        if (connect_result != 0) {
            fd_set client_fd_set;
            struct timeval tv;
            tv.tv_sec = sec;
            tv.tv_usec = usec;
            
            FD_ZERO(&client_fd_set);
            FD_SET(client_socket, &client_fd_set);
            int ret = select(client_socket + 1, NULL, &client_fd_set, NULL, &tv);
            
            if (ret < 0) {
                perror("select error");
                return ERROR_SELECT; // select 出错
            }
            else if(ret == 0){
                perror("timeout error");
                return ERROR_TIMEOUT; // select 超时
            }
            else {
                int error = -1;
                int length = sizeof(int);
                getsockopt(client_socket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&length);
                if (error != 0) {
                    close(client_socket);
                    perror("connect error");
                    return ERROR_CONNECT;
                }
            }
        }
        socket_isblock(client_socket, 1);
        return client_socket;
    }
    
    int connect_result = connect(client_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (connect_result == 0) {
        return client_socket;
    }
    else {
        perror("connect error");
        return ERROR_CONNECT;
    }
}

// @_silgen_name("socket_tcp_accept") private func c_socket_tcp_accept(socket: Int32, address: UnsafePointer<UInt8>, port: UnsafePointer<Int32>, sec: Int32, usec: Int32) -> Int32
int socket_tcp_accept(int server_socket, char * address, int * port, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set server_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&server_fd_set);
        FD_SET(server_socket, &server_fd_set);
        int ret = select(server_socket + 1, &server_fd_set, NULL, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    struct sockaddr_in client_address;
    socklen_t address_len;
    int accept_result = accept(server_socket, (struct sockaddr *)&client_address, &address_len);
    //printf("新客户端加入成功 %s:%d \n",inet_ntoa(client_address.sin_addr),ntohs(client_address.sin_port));
    
    if (accept_result < 3) {
        perror("accept error");
        return ERROR_ACCEPT;
    }
    else {
        // SO_NOSIGPIPE
        int set = 1;
        setsockopt(accept_result, SOL_SOCKET, SO_NOSIGPIPE, &set, sizeof(int));
        
        memcpy(address, inet_ntoa(client_address.sin_addr), strlen(inet_ntoa(client_address.sin_addr)));
        *port = client_address.sin_port;
        return accept_result;
    }
}

// MARK: - UDP

// @_silgen_name("socket_udp_server") private func socket_udp_server(port: Int32) -> Int32
int socket_udp_server(int port) {
    //创建 Socket UDP
    int server_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (server_socket == -1) {
        return ERROR_SOCKET;
    }
    
    // 创建 Socket 地址结构
    struct sockaddr_in server_addr;
    server_addr.sin_len         = sizeof(struct sockaddr_in);
    server_addr.sin_family      = AF_INET;
    server_addr.sin_port        = htons(port);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    bzero(&(server_addr.sin_zero), 8);
    
    // Socket 设置可复用
    int set_opt = 1;
    int opt_result = setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &set_opt, sizeof(set_opt));
    if (opt_result != 0) {
        return ERROR_REUSEADDR;
    }
    
    // Bind
    int bind_result = bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (bind_result == -1) {
        return ERROR_BIND;
    }
    
    return server_socket;
}

// @_silgen_name("socket_udp_client") private func socket_udp_client() -> Int32
int socket_udp_client() {
    //创建 Socket TCP
    int client_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (client_socket == -1) {
        return ERROR_SOCKET;
    }
    
    // Socket 设置可复用
    int set_opt = 1;
    int opt_result = setsockopt(client_socket, SOL_SOCKET, SO_REUSEADDR, &set_opt, sizeof(set_opt));
    if (opt_result != 0) {
        return ERROR_REUSEADDR;
    }
    
    return client_socket;
}

/// 开启或关闭广播模式 1 为开启
// @_silgen_name("socket_opt") private func c_socket_opt(socket: Int32, open: Int32) -> Void
void socket_opt(int socket, int open) {
    setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &open, sizeof(open));
}

// MARK: - Write

// @_silgen_name("socket_write_t") private func c_socket_write_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
size_t socket_write_t(int socket, const void * buffer, size_t size, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, NULL, &socket_fd_set, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    size_t w_size = write(socket, buffer, size);
    if (w_size != size) {
        perror("write error");
        return ERROR_WRITE;
    }
    else {
        return w_size;
    }
}

// @_silgen_name("socket_send_t") private func c_socket_send_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
size_t socket_send_t(int socket, const void * buffer, size_t size, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, NULL, &socket_fd_set, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    size_t w_size = send(socket, buffer, size, 0);
    if (w_size != size) {
        perror("write error");
        return ERROR_WRITE;
    }
    else {
        return w_size;
    }
}

// @_silgen_name("socket_sendto_t") private func c_socket_sendto_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, address: UnsafePointer<UInt8>, port: Int32, sec: Int32, usec: Int32) -> Int32
size_t socket_sendto_t(int socket, const void * buffer, size_t size, const void * address, int port, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, NULL, &socket_fd_set, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    struct sockaddr_in to_address;
    to_address.sin_len         = sizeof(struct sockaddr_in);
    to_address.sin_family      = AF_INET;
    to_address.sin_port        = htons(port);
    to_address.sin_addr.s_addr = inet_addr(address);
    bzero(&(to_address.sin_zero), 8);
    
    size_t w_size = sendto(socket, buffer, size, 0, (struct sockaddr *)&to_address, sizeof(to_address));
    if (w_size != size) {
        perror("write error");
        return ERROR_WRITE;
    }
    else {
        return w_size;
    }
}

// MARK: - Read

// @_silgen_name("socket_read_t") private func c_socket_read_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
size_t socket_read_t(int socket, void * buffer, size_t size, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, &socket_fd_set, NULL, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    size_t r_size = read(socket, buffer, size);
    if (r_size == -1) {
        perror("read error");
        return ERROR_WRITE;
    }
    else {
        return r_size;
    }
}

// @_silgen_name("socket_recv_t") private func c_socket_recv_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, sec: Int32, usec: Int32) -> Int32
size_t socket_recv_t(int socket, void * buffer, size_t size, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, &socket_fd_set, NULL, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    size_t r_size = recv(socket, buffer, size, 0);
    if (r_size == -1) {
        perror("read error");
        return ERROR_WRITE;
    }
    else {
        return r_size;
    }
}

// @_silgen_name("socket_recvfrom_t") private func c_socket_recvfrom_t(socket: Int32, buffer: UnsafePointer<UInt8>, length: Int32, fromAddress: UnsafePointer<UInt8>, fromPort: UnsafePointer<Int32>, sec: Int32, usec: Int32) -> Int32
size_t socket_recvfrom_t(int socket, void * buffer, size_t size, char * fromAddress, int * fromPort, int sec, int usec) {
    if (sec > 0 || usec > 0) {
        fd_set socket_fd_set;
        struct timeval tv;
        tv.tv_sec = sec;
        tv.tv_usec = usec;
        
        FD_ZERO(&socket_fd_set);
        FD_SET(socket, &socket_fd_set);
        int ret = select(socket + 1, &socket_fd_set, NULL, NULL, &tv);
        
        if (ret < 0) {
            perror("select error");
            return ERROR_SELECT; // select 出错
        }
        else if(ret == 0){
            perror("timeout error");
            return ERROR_TIMEOUT; // select 超时
        }
    }
    
    struct sockaddr_in address;
    socklen_t port;
    size_t r_size = recvfrom(socket, buffer, size, 0, (struct sockaddr *)&address, &port);
    if (r_size == -1) {
        perror("read error");
        return ERROR_WRITE;
    }
    else {
        memcpy(fromAddress, inet_ntoa(address.sin_addr), strlen(inet_ntoa(address.sin_addr)));
        *fromPort = port;
        return r_size;
    }
}

