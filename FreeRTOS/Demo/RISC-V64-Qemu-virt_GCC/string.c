/*************************************************************************
  > File Name: string.c
  > Author: SuWeishuai
  > Mail: suwsl@foxmail.com
  > Created Time: Fri 01 Apr 2022 03:02:53 PM CST
 ************************************************************************/
#include "string.h"

char *strcpy(char *dest, const char *src){
    char *ret = dest;
    while( (*dest++ = *src++) != '\0' );
    return ret;
}

void *memcpy(void *dest, const void *src, size_t n){

    char *ret = dest;
    while( n-- != 0 )
        *(char *)dest++ = *(char *)src++;
    return ret;
}

void *memset(void *s, int c, size_t n) {
    char *p = (char *)s;
    while (n--) {
        *p++ = c;
    }
    return s;
}

size_t strlen (const char *str)
{
    const char *start = str;

    while (*str)
        str++;
    return str - start;
}

