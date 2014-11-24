#include "prout.h"
#include "version.h"
#include <stdio.h>

void prout(void)
{
    puts("prout!");
    printf("La version de l'exe est: %s\n", g_version);
}

