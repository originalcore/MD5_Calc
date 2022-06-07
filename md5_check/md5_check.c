#include "bsl.h"
#include "stdio.h"
#include <fcntl.h>
#include "version.h"
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include "md5_calc.h"

struct _test_local_st
{
	int fd_text_file;
	unsigned char * put_text_file_mem;
	unsigned char * put_text_file_mem_end;
};

static struct _test_local_st g_priv;

void show_version(void)
{
	printf("\n\n==================================================================================\n");
	printf("**********************************************************************************\n");
	printf ("%s\n", version_string);
	printf("**********************************************************************************\n");                                                                                                        
	printf("==================================================================================\n\n");
}


int main(int argc, char *argv[])
{
	int ret = 0;
	int len_t = 0;
	struct stat st_tat;
	char md5_str[MD5_STR_LEN + 1];
	char md5_str1[MD5_STR_LEN + 1];

	show_version();

	g_priv.fd_text_file = open(argv[1], O_RDONLY);
	if (0 > g_priv.fd_text_file)
	{
		printf( "can't open text file %s\n", argv[3]);
		return -1;
	}

	if(fstat(g_priv.fd_text_file, &st_tat))
	{
		printf( "constan't get fstat\n");
		return -1;
	}
	g_priv.put_text_file_mem = (unsigned char *)mmap(NULL , st_tat.st_size, PROT_READ, MAP_SHARED, g_priv.fd_text_file, 0);
	if (g_priv.put_text_file_mem == (unsigned char *)-1)
	{
		printf( "can't mmap for text file\n");
		return -1;
	}
	g_priv.put_text_file_mem_end = g_priv.put_text_file_mem + st_tat.st_size;
	printf( "st_tat.st_size = %d\n",st_tat.st_size);

	Compute_file_md5(argv[1], md5_str);
	printf("Compute_file_md5   = [%s]\n", md5_str);
	Compute_string_md5(g_priv.put_text_file_mem, st_tat.st_size, md5_str1);
	printf("Compute_string_md5 = [%s]\n", md5_str1);

	munmap(g_priv.put_text_file_mem, g_priv.put_text_file_mem_end - g_priv.put_text_file_mem);

	return 0;
}

