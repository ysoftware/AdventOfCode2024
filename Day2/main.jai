#import "Basic";
#import "File";
#import "Math";

REPORT_SIZE_MAX :: 10;
file_name :: "input.txt";

main :: () {
    file := file_open(file_name);
    input, success := read_entire_file(file);
    if !success {
        print("Error: could not read file %.\n", file_name);
        exit(1);
    }

    is_safe := true;
    is_descending := false;
    last_number := 0;
    reports_count := 0;
    report_size := 0;

    safe_reports_count := 0;

    number := 0;
    number_dec := 1;

    for i: 0..input.count-1 {
        c := input[i];

        if c >= #char "0" && c <= #char "9" {
            digit := c - #char "0";
            number *= 10;
            number += digit;
            number_dec *= 10;
        } else {
            diff := abs(last_number - number);

            if report_size > 1 {
                matches_order := is_descending == (number < last_number);
                if !matches_order || diff < 1 || diff > 3 {
                    is_safe = false;
                }
            } else if report_size == 1 {
                is_descending = number < last_number;
                if diff < 1 || diff > 3 {
                    is_safe = false;
                }
            }

            if c == #char " " {
                report_size += 1;
            } else if c == #char "\n" {
                if is_safe && report_size > 0 {
                    safe_reports_count += 1;
                }

                reports_count += 1;
                report_size = 0;
                is_safe = true;
            } else {
                print("Unsupported character %.\n", c);
            }

            last_number = number;
            number = 0;
            number_dec = 1;
        }
    }

    print("Reports in the file: %.\n", reports_count);
    print("Safe reports: %.\n", safe_reports_count);
}

