/*==================================================================
 *
 *               University College Dublin
 *          EEEN20010 - Computer Engineering I
 *      "Data Structures and Algorithms through C"
 *
 * File Name:   hangman.c
 *
 * Description: Program to read in a float value indicating the distance travelled by the aeroplane in kilometers, and to print out the
corresponding flight time in hours and minutes..
 *
 * Author:      Oisin Hogan
 *
 * Date:        19 Nov 2020
 *
 *==================================================================*/

/*==================================================================
 * Systems header files
 *==================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*==================================================================
 * Constant definitions
 *==================================================================*/
#define MaxFilenameSize 255
#define MaxWordLenght 45
#define NoLives 10
/*==================================================================
 * Function definitions
 *==================================================================*/
int readfile(char word[]);

int main(void)
{
/*initialise characters for word, loops, word or letter selection and letter guess*/
    unsigned char word[MaxWordLenght], i=0, worl=0, letterguess=0, playagain=0;
/*initialise intergers for the number of letters in the word, number of lives , whether a word is correct, and the number of lives that the user has*/
    int letterno, looselife, wordtest, lifeno;
/*use a for loop to give the user a play again option*/
    for(;;)
    {
/*set initial number of lives to ten, defined above*/
        lifeno = NoLives;
/*make sure that the word string is initialised to all 0's*/
        for(i=0; i<MaxWordLenght; i++)
            word[i] = 0;
/*use readfile to read in the word form the file chosen by the user*/
        readfile(word);

/*count the number of letters in the chosen word*/

        letterno=strlen(word);

/*set the number of blank spaces and the number of letters in the string of users guess equal to that of the chosen word*/
        char unknownword[letterno], wordguess[letterno];

/*use a for loop to fill up the string of the unknown word with '*', blank spaces*/
        for(i=0; i<letterno; i++)
            unknownword[i]='*';
/*set the following character to 0, this helped with the printf used later on*/
        unknownword[i]="0";

        printf("\nReady to start!\n\n");

/*for loop for game */
        for (;;)
        {
            looselife = 1;
/*read from the user if they want to guess a letter or a word*/
            printf_s("The word is %s", unknownword);
            printf("\nNumber of turns remaining:\t %i\nWould you like to guess the word [w] or guess a letter [l]:", lifeno);
            scanf(" %c", &worl);
/*if the user selects letter*/
            if (worl =='l')
            {
                printf("What letter have you chosen?:");
                scanf(" %c", &letterguess);
                printf("\n***********************************************\n\n");
/*for loop to replace '-' with the letter any time the letter shows up, and stop person from loosing a life*/
                for(i=0; i<letterno; i++)
                {
                    if (word[i] == letterguess)
                    {
                        unknownword[i] = letterguess;
                        looselife = 0;
                        printf("Good Choice!");
                    }
                    else;
/*check if the revealed word matches the work*/
                    wordtest = strcmp(word, unknownword);
                }
            }
/*if the user selects word*/
            else if (worl =='w')
            {
                printf("What word have you chosen?:");
                scanf(" %s", &wordguess);
                printf("\n\n***********************************************\n");
/*check if the guess of the word matches the word, and dont stop the user form loosing a life*/
                wordtest = strcmp(word, wordguess);
                if ((strlen(word)) != (strlen(wordguess)))
                    wordtest = 1;
            }

/*if the user selects neither w or l, say it is incompatible*/
            else
            {
                printf("\nInocmpatible, try again\n\n***********************************************\n");
                looselife = 2;
            }

/*check if the word that was guessed, or revealed matches the word, then the user wins*/
            if (wordtest ==0)
            {
                printf("\nCongratulations!\n");
                break;
            }
            else;

/*check if the user looses a life this round*/
            if (looselife==1)
            {
                lifeno--;
                printf("Bad Choice!\n");
            }
/*if the user has not lost a life and guessed correcly*/
            else if (lifeno == 0)
                printf("Good Choice!\n");
/*final case if the user has not lost a life or guesed correctly*/
            else;

/*if the user has run out of lives, declare that they lost*/
            if (lifeno == 0){
                 printf("\nYou Loose\nThe word was %s", word);
                 break;
            printf("\n");
            }
        }

        printf("\n\n***********************************************\nDo you want to play again [y/n]:\n");
        scanf(" %c", &playagain);

        if (playagain == 'n')
            break;
    }
    return(0);
}


/*function to read word from file that will be guessed later on*/
int readfile(char word[])
{
/*create static characters for the file name and an abritrary variable'ch' and interger value j=0*/
    static char filename[MaxFilenameSize], ch;
    int j = 0;

/*create a file data space for the chosen file*/
    FILE *chosenfile;

/*use a for loop to ensure correct file name is given*/
    for(;;)
    {
/*gets is used to get a string for the filename*/
        printf("Give the filename with the unknown word:\n");
        gets(filename);
/*open the chosen file as read only*/
        chosenfile = fopen(filename, "r");
/*if it is an empty file or non existant, then have user choose again*/
        if (chosenfile == NULL)
            printf("not a valid file, please try again\n");
/*if file is valid then assign it to our word string in 'main'*/
        else
        {
/*whlie loop used to gather each character of the word, until the end of file*/
            while((ch = fgetc(chosenfile))!= EOF)
            {
                word[j] = ch;
                j++;
            }
/*then break the for loop*/
            break;
        }
/*close the previously opened file*/
    fclose(chosenfile);
    }
    return(0);
}
