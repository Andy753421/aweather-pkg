#include <windows.h>
#include <shellapi.h>
int main(int argc, char* argv[])
{
	if (argc > 1) {
		SHELLEXECUTEINFO info = {
			.cbSize = sizeof(info),
			.lpVerb = "open",
			.lpFile = argv[1],
			.nShow  = SW_SHOWNORMAL,
		};
		ShellExecuteEx(&info);
	}
	return 0;
}
