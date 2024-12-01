#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define NUMBER_LENGTH_MAX 10
#define FILE_LINES_MAX 10000

char *read_entire_file(char *name) {
    FILE *f = fopen("input.txt", "r");
    fseek(f, 0, SEEK_END);
    long length = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *buffer = malloc(length);
    if (buffer) fread(buffer, 1, length, f);
    fclose(f);
    return buffer;
}

int compare(const void *a, const void *b) {
    int numa = *((int*)a);
    int numb = *((int*)b);

    if (numa == numb)      return 0;
    else if (numa < numb)  return -1;
    else                   return 2;
}

int main(void) {
    char *input = read_entire_file("input.txt");
    int file_length = strlen(input);
    printf("Input length is: %d bytes\n", file_length);

    int list1[FILE_LINES_MAX] = {0};
    int list2[FILE_LINES_MAX] = {0};
    
    int line = 0;
    int cursor = 0;
    bool is_second_number = false;
    char number[NUMBER_LENGTH_MAX+1] = {0};
    int number_length = 0;

    while (cursor < file_length) {
        assert(line < FILE_LINES_MAX && "File can't be this long");
        char c = input[cursor];

        if (c >= '0' && c <= '9') {
            assert(number_length <= NUMBER_LENGTH_MAX && "Number can't be this long");
            number[number_length] = c;
            number_length++;
        } else if (c == ' ') {
            if (number_length > 0) {
                if (!is_second_number) {
                    list1[line] = atoi(number);
                    is_second_number = true;
                } else {
                    list2[line] = atoi(number);
                    is_second_number = false;
                }
                memset(number, 0, NUMBER_LENGTH_MAX);
                number_length = 0;
            }
        } else if (c == '\n') {
            if (number_length > 0) {
                if (is_second_number) {
                    list2[line] = atoi(number);
                    is_second_number = false;
                    memset(number, 0, NUMBER_LENGTH_MAX);
                    number_length = 0;
                } else {
                    printf("ERROR: Incorrect format: did not find another number on line %d.\n", line+1);
                    exit(1);
                }
            }
            line++;
        }
        cursor++;
    }
    printf("Parsed %d lines.\n", line);

    qsort(&list1, line, sizeof(int), compare);
    qsort(&list2, line, sizeof(int), compare);

    int result = 0;
    for (int i=0; i < line; i++) {
        result += abs(list1[i] - list2[i]);
    }

    printf("Result is: %d\n", result);

    return 0;
}
