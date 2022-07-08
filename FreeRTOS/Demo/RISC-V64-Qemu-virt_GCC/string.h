/*************************************************************************
  > File Name: string.h
  > Author: SuWeishuai
  > Mail: suwsl@foxmail.com
  > Created Time: Fri 01 Apr 2022 03:02:16 PM CST
 ************************************************************************/

#ifndef STRING_H
#define STRING_H

#include <stdint.h>
#include <stddef.h>

char *strcpy(char *dest, const char *src);
void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
size_t strlen (const char *str);

#endif
