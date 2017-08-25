#pragma once

// globals
struct sockaddr_in my_addr;  // socket address
I sockfd;                    // socket file descriptor

// k functions
K2(k_connect);               // (K host, K port)
K1(k_send);                  // (K message)
void k_disconnect(I socket); //
K k_recv(I socket);          //
