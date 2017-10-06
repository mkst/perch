// standard includes
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
// sockets
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

// kdb
#include "k.h"

// self
#include "socket.h"

I handle = 0;                          // initialise handle as zero

K1(k_send)
{
  if (xt != KC && xt != -KC)           // only support char or char array
  {
    krr((S)"type");
  }
  if (xt == -KC)                       // single char
  {
    R kj(send(sockfd, &(x->g), 1, 0));
  }
  else                                 // char array
  {
    J to_send = x->n;                  // setup variables for the sending loop
    J sent = 0;
    J total_sent = 0;

    while (to_send > 0)                // loop until everything has been sent
    {
      sent = send(sockfd, kC(x) + total_sent, to_send, 0);  // might not send everything
      total_sent += sent;              // increment total sent
      if (sent < 1) R kj(-1);          // TODO: add some error handling here
      to_send -= sent;                 // decrement to_send counter
    }
    R kj(total_sent);
  }
}

K k_recv(I socket)
{
  // TODO: tune once we learn average message size
  C buf[512];                          // buffer to copy incoming data
  J cnt;                               // store how much data has been received
  K res = ktn(0,0);                    // mixed list to be returned to kdb

  while ((cnt = recv(socket, buf, sizeof(buf), MSG_DONTWAIT)) > 0) // may require multiple calls to recv to exhaust recieve queue
  {
    jk(&res,kpn(buf, cnt));            // join contents of buffer to mixed list
  }

  if (cnt < 0 && errno != EAGAIN && errno != EWOULDBLOCK) // sub-zero cnt means disconnect or failure
  {
    k_disconnect(socket);              // disconnect socket
  }
  if (cnt == 0)
  {
    k_disconnect(socket);              // disconnect socket
  }

  if (res->n > 0)                      // there is something to return
  {
    k(0, (S)".socket.recv", res, (K)0);
  }

  return (K)0;                         // return null
}

K2(k_connect)
{
  if (x->t != KC || y->t != -KI)       // sanity check of types
  {
    return krr((S)"type");
  }
  my_addr.sin_family = AF_INET;        // set family to IPv4
  my_addr.sin_port = htons(y->i);      // set port
  inet_aton((char *)kC(x), &my_addr.sin_addr); // set host
  sockfd = socket (PF_INET, SOCK_STREAM, 0);   // create socket
  I res = connect(sockfd, (struct sockaddr *)&my_addr, sizeof(my_addr));
  if(res == 0)                         // success
  {
    sd1(sockfd, k_recv);               // setup callback
  }
  return kb(res == 0);
}

void k_disconnect(I socket)
{
  k(0, (S)".socket.disconnect", ki(socket), (K)0); // call kdb
  sd0(socket);                         // remove callback
}

K2(multiply)
{
  if (x->i == 6 && y->i == 9)
    return ki(42); // life, the universe, everything
  else
    return ki(x->i * y->i);
}
