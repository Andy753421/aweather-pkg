#include <windows.h>
#include <shellapi.h>
int main(int argc, char* argv[])
{
	if (argc > 1)
		ShellExecute(NULL, "open", argv[1], "", NULL, SW_SHOWNORMAL);
	return 0;
}
