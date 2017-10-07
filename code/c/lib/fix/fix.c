// decode.c
// gcc -fno-builtin -Wall -g -fno-omit-frame-pointer -std=c99 -shared -fPIC -DKXVER=3 -O3 -I../include fix.c -o l32/fix.so -m32

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "k.h"

#define NUL '\000'
#define SOH '\001'
#define SEP '='

// fast_atoi taken from https://stackoverflow.com/a/16826908/7290888
int fast_atoi( const char * str )
{
  int val = 0;
  while( *str ) {
    val = val*10 + (*str++ - '0');
  }
  return val;
}

K decode(K x)
{
  if(xt != KC)
  {
    return krr("type");
  }

  const int len = xn;
  char buf[len];
  size_t buf_pos = 0;

  // initialise empty dictionaries
  K tags = ktn(KH, 0);                // list of shorts
  K values = ktn(0, 0);               // mixed list

  for(size_t i = 0; i < len; i++) {   // iterate through the FIX message
    const char c = kC(x)[i];          // extract current character into c
    switch (c) {
      case SEP:                       // tag/value separator
        buf[buf_pos] = NUL;           // terminate buffer with NUL
        H tag = fast_atoi(buf);       // cast buffer to int to short
        ja(&tags,&tag);               // join (short) atom
        buf_pos = 0;                  // reset buffer
        break;
      case SOH:                       // value/tag separator
        jk(&values,kpn(buf,buf_pos)); // join value to values
        buf_pos = 0;                  // reset buffer
        break;
      default:                        // part of tag or value
        buf[buf_pos++] = c;           // add char to buffer and increment offset
      }
  }

  return xD(tags, values);
}
