#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#include <assert.h>

#include <pthread.h>

#include "k.h"

pthread_t t;
bool IS_RUNNING;
int PORT;

// lifted verbatim from https://www.gnu.org/software/libc/manual/html_node/Inet-Example.html
int
make_socket (uint16_t port)
{
  struct sockaddr_in name;

  /* Create the socket. */
  int sock = socket (PF_INET, SOCK_STREAM, 0);
  assert (sock > 0);
  /* Give the socket a name. */
  name.sin_family = AF_INET;
  name.sin_port = htons (port);
  name.sin_addr.s_addr = htonl (INADDR_ANY);

  assert (bind (sock, (struct sockaddr *) &name, sizeof (name)) == 0);
  return sock;
}

K
callback(I fd)
{
  char *buf;
  int buf_size = 1024;
  int buf_pos = 0;

  char tmpbuf[1024];                                            // temporary buffer for read()
  int nbytes;                                                   // number of bytes read

  buf = calloc(buf_size,sizeof(unsigned char));                 // preallocate 512 bytes

  while (0 < (nbytes = recv(fd, tmpbuf, sizeof(tmpbuf), MSG_DONTWAIT)))
  {
    if (buf_pos + nbytes > buf_size)
    {
      buf_size *= 2;                                            // double the buf_size
      buf = realloc(buf, buf_size * sizeof(unsigned char));     // reallocate memory for buf
    }
    memcpy(buf+buf_pos, tmpbuf, nbytes);                        // copy from tmpbuf into buf
    buf_pos += nbytes;                                          //
  }

  if (buf_pos > 0)                                              // data has been received
  {
    K x=ktn(KG, buf_pos);                                       // create byte array
    memcpy(kG(x), buf, buf_pos);                                // copy buffer into byte array
    k(0, (S)".gw.receive", ki(fd), x, (K)0);                    // push to main thread
  }
  else if (nbytes <= 0 && (errno != EWOULDBLOCK && errno != EAGAIN))
  {
    sd0(fd);                                                    // remove callback
    // FIXME: do socket cleanup here
  }
  R (K)0;
}

K2(k_send) //[handle;bytearray]
{
  if (xt != -KI || (y->t != -KG && y->t != KG))
  {
    krr((S)"type");
  }
  if (y->t == -KG)                       // single char
  {
    R kj(send(x->i, &(y->g), 1, 0));
  }
  else                                 // char array
  {
    J to_send = y->n;                  // setup variables for the sending loop
    J sent = 0;
    J total_sent = 0;

    while (to_send > 0)                // loop until everything has been sent
    {
      sent = send(x->i, kG(y) + total_sent, to_send, 0);  // might not send everything
      total_sent += sent;              // increment total sent
      if (sent < 1) R kj(-1);          // TODO: add some error handling here
      to_send -= sent;                 // decrement to_send counter
    }
    R kj(total_sent);
  }
}

void
run_listener (void)
{
  extern int make_socket (uint16_t port);
  int sock;
  fd_set active_fd_set, read_fd_set;
  struct sockaddr_in clientname;

  /* Create the socket and set it up to accept connections. */
  sock = make_socket (PORT);
  assert(listen (sock, 1) == 0);

  /* Initialize the set of active sockets. */
  FD_ZERO (&active_fd_set);
  FD_SET (sock, &active_fd_set);

  while (1)
  {
    /* Block until input arrives on one or more active sockets. */
    read_fd_set = active_fd_set;
    assert (select (FD_SETSIZE, &read_fd_set, NULL, NULL, NULL) > 0);
    if (FD_ISSET (sock, &read_fd_set))
    {
      socklen_t socklen = sizeof (clientname);
      int new = accept (sock,
                        (struct sockaddr *) &clientname,
                        &socklen);
      assert (new > 0);                                         // sanity
      sd1(new, callback);                                       // add kdb callback
    }
  }
}

void*
run(void *arg)
{
  run_listener();
  return NULL;
}

K1(k_setport)
{
  if (xt != -KI)
  {
    krr((S)"type");
  }
  PORT = xi;
  R (K)0;

}
K1(k_start)
{
  if(PORT == 0)                                                 // dont start if port has not been set
    return krr((S)"port");

  if(IS_RUNNING)                                                // dont create thread if we are already running
    return krr((S)"already_running");

  int err = pthread_create(&t, NULL, &run, NULL);
  if (err != 0)                                                 // throw error if we failed to create the thread
    return krr((S)"thread");

  IS_RUNNING = true;                                            // set IS_RUNNING to true

  return kb(1);
}
