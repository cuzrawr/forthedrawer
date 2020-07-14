#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char const *argv[])
{
	char *str[] = {"Yes", "No", "That yr life", "Now or never", "Do not think about", "Go away from this", "Agree", "Yes, no purpose", "100%", "Roll again", "50\\50", "This work"};
	int horse;
	char tense[254];
	char frst;

	srand(time(NULL));
	horse = rand()%12;

	frst = toupper(tense[0]);

	strcpy(tense, str[horse]);

	memset(tense, frst, 0);

	printf("%s\n",tense );

	return 0;
}
