#include <stdio.h>

char cipherText[] = "bdnpQai|nufimnug`n{Fafhr\0";
char flagForm[] = "flag{";

int key[] = {};

int main ()
{
    for (int i = 0; i < 26; i += 2)
    {
        char tmp = cipherText[i];
        tmp ^= flagForm[i % 5];
        char tmp2 = cipherText[i+1];
        tmp2 ^= flagForm[i - 5 * ((i + 1) / 5) + 1];
        key[i] = tmp;
        key[i+1] = tmp2;
    }

    for (int i = 0; i < 5; i++)
    {
        printf("%d  ", key[i]);
    }

    return 0;
}