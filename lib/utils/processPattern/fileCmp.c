#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define LINE 1024
#define TEMPLATE_FILE            "template.txt"
#define OUTPUT_FILE              "output.txt"
#define ERROR_FILE               "error.txt"
//#define debug_printf            printf
#define debug_printf
FILE *tfp, *ofp, *efp;
char *tbuf, *obuf, filename[20], *t, *o;

//读取一行
char *ReadData(FILE *fp, char *buf)
{
    return fgets(buf, LINE, fp);//读取一行到buf
}

//错误输出和文本输出
void someprocess(char *buft, char *bufo, int type)
{
    if(type != 0){
        printf("&&&&&&&&&&&&&&&&&&&&&Begin&&&&&&&&&&&&&&&&&&&&&\n");
        printf("[template]---%s[output]--%s[type]--%d\n", buft, bufo, type);
        printf("&&&&&&&&&&&&&&&&&&&&&End&&&&&&&&&&&&&&&&&&&&&\n\n");
        //Begin of #002以追加方式写入（error.txt）
        efp = fopen(ERROR_FILE, "a");
        fprintf(efp, "&&&&&&&&&&&&&&&&&&&&&Begin&&&&&&&&&&&&&&&&&&&&&\n");
        fprintf(efp, "[template]---%s[output]--%s[type]--%d\n", buft, bufo, type);
        fprintf(efp, "&&&&&&&&&&&&&&&&&&&&&End&&&&&&&&&&&&&&&&&&&&&\n\n");
        fclose(efp);
        //End of #002
    }
    else{
        debug_printf("&&&&&&&&&&&&&&&&&&&&&Begin&&&&&&&&&&&&&&&&&&&&&\n");
        debug_printf("[template]%s[output]--%s[type]--%d\n", buft, bufo, type);
        debug_printf("&&&&&&&&&&&&&&&&&&&&&End&&&&&&&&&&&&&&&&&&&&&\n\n");
    }
}

int main(int argc, char *argv[])
{
    //Begin of #001 清空文件error.txt
    efp = fopen(ERROR_FILE, "w");
    ftruncate(fileno(efp), 0);
    rewind(efp);
    fclose(efp);
    //End of #001

    //打开检查样本文件是否存在（template.txt）
    if((tfp=fopen(TEMPLATE_FILE, "r"))==NULL){
        printf("open template.txt file error!!\n");
        return;
    }

    //打开检查目标文件是否存在（output.txt）
    if((ofp=fopen(OUTPUT_FILE, "r"))==NULL){
        printf("open output.txt file error!!\n");
        return;
    }

    //分配单行文本空间（template.txt和output.txt）
    tbuf=(char*)malloc(LINE * sizeof(char));
    obuf=(char*)malloc(LINE * sizeof(char));

    while(1){
        t=ReadData(tfp,tbuf);//每次调用文件指针tfp会自动后移一行
        o=ReadData(ofp,obuf);//每次调用文件指针ofp会自动后移一行
        if(!o)
            break;
        someprocess(tbuf, obuf, strcmp(tbuf, obuf));
    }
    if(t){
        efp = fopen(ERROR_FILE, "a");
        fprintf(efp, "!!!!!!!!!!!!!!!!!!!!!!!!样本（template.txt）文件大于目标（output.txt）文件行数!!!!!!!!!!!!!!!!!!!!!!!!\n");
        fclose(efp);
    }
    //关闭文件（template.txt和output.txt）
    fclose(tfp);
    fclose(ofp);
    //释放内存空间
    free(tbuf);
    free(obuf);
    return 0;
}
