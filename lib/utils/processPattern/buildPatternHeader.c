#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
    char szTemp1[1024],szTemp2[1024];
    FILE *fp = fopen("dict.txt","r");
    FILE *fp1 = fopen("dictList.h","w");
    FILE *fp2 = fopen("dictType.h","w");

    if (fp == NULL || fp1 == NULL || fp2 == NULL) {
        printf("Open file(s) error\n");
        return 0;
    }

    fprintf(fp1,"char g_szDictList[][20] = {\n");
    fprintf(fp2,"char g_szDictType[][20] = {\n");
    while(!feof(fp))
    {
        fscanf(fp,"%s\t%s\n",szTemp1,szTemp2);
        if (szTemp1[0] == '"')
            strcpy(szTemp1,&szTemp1[1]);
        fprintf(fp1,"\"%s\",\n",szTemp1);
        fprintf(fp2,"\"%s\",\n",szTemp2);
    }
    fprintf(fp1,"\"结束符号\"};\n");
    fprintf(fp2,"\"生活\"};\n");

    fclose(fp);
    fclose(fp1);
    fclose(fp2);
    return 0;
}
