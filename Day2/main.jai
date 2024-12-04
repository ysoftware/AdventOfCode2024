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

    test1();
    test2();
    test3();

    reports_count, safe_reports_count, kinda_safe_reports_count := work(input);
    print("Reports in the file: %.\n", reports_count);
    print("Safe reports: %.\n", safe_reports_count);
    print("Almost safe reports: %.\n", kinda_safe_reports_count);
    print("Total safe-ish reports: %.\n", safe_reports_count + kinda_safe_reports_count);
}

work :: (input: string) -> int, int, int {
    first_number := 0;
    is_first_number_safe := true;
    is_safe := true;
    did_skip_level := false;
    is_descending := false;
    last_number := 0;
    reports_count := 0;
    report_size := 0;

    safe_reports_count := 0;
    kinda_safe_reports_count := 0;

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
            assert(number_dec > 1);

            if report_size > 1 {
                matches_order := is_descending == (number < last_number);
                diff := abs(last_number - number);
                print("\e[33m[%:%]\e[0m", last_number, number);

                // if first failed, we need to check it current with #1 or #2
                // if this fails, we need to try #1

                if report_size == 2 {
                    if !is_first_number_safe {
                        if diff < 1 || diff > 3 {
                            last_number = first_number;
                            is_descending = number < last_number;
                            matches_order = is_descending == (number < last_number);

                            if !matches_order {
                                print("\e[031m(%)\e[0m", matches_order);
                            } else {
                                print("\e[031m(%)\e[0m", diff);
                            }

                            print("\e[032m/\e[0m");
                            print("\e[33m[%:%]\e[0m", last_number, number);
                        }
                    } else if !matches_order || diff < 1 || diff > 3 { // try with #1
                        last_number = first_number;
                        is_descending = number < last_number;
                        matches_order = is_descending == (number < last_number);
                        is_safe = false;

                        if !matches_order {
                            print("\e[031m<%>\e[0m", matches_order);
                        } else {
                            print("\e[031m<%>\e[0m", diff);
                        }

                        print("\e[032m~\e[0m");
                        print("\e[33m[%:%]\e[0m", last_number, number);
                    }
                }

                is_descending = number < last_number;
                matches_order = is_descending == (number < last_number);
                diff = abs(last_number - number);

                if !matches_order || diff < 1 || diff > 3 {
                    if !did_skip_level || is_safe  {
                        if !matches_order {
                            print("\e[035m<%>\e[0m", matches_order);
                        } else {
                            print("\e[035m<%>\e[0m", diff);
                        }
                    }
                    is_safe = false;
                }
            } else if report_size == 1 {
                first_number = last_number;
                print("\e[33m[%:%]\e[0m", last_number, number);

                is_descending = number < last_number;
                diff := abs(last_number - number);
                if diff < 1 || diff > 3 {
                    is_first_number_safe = false;
                    if !is_first_number_safe  print("\e[035m<%>\e[0m", diff);
                }
            }

            if !did_skip_level && !is_safe {
                is_safe = true;
                did_skip_level = true;
                print("\e[36m-%\e[0m ", number);
            } else {
                last_number = number;
                print("% ", number);
            }
            number = 0;
            number_dec = 1;

            if c == #char " " {
                report_size += 1;
            } else if c == #char "\n" {
                assert(report_size > 0);

                if is_safe {
                    if !did_skip_level && is_first_number_safe {
                        safe_reports_count += 1;
                        print(": safe\n");
                    } else if !(!is_first_number_safe && did_skip_level) {
                        print(": safe-ish\n");
                        kinda_safe_reports_count += 1;
                    } else {
                        print(": danger\n");
                    }
                } else {
                    print(": danger\n");
                }

                reports_count += 1;
                report_size = 0;
                is_safe = true;
                is_first_number_safe = true;
                did_skip_level = false;
            } else {
                print("Unsupported character %.\n", c);
            }
        }
    }

    return reports_count, safe_reports_count, kinda_safe_reports_count;
}

test1 :: () {
    input := #string DONE
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
DONE

    reports_count, safe_reports_count, kinda_safe_reports_count := work(input);
    if reports_count != 6                    print("\e[31mTest 1: reports_count: %, expected: %\e[0m\n", reports_count, 6);
    else if safe_reports_count != 2          print("\e[31mTest 1: safe_reports_count: %, expected: %\e[0m\n", safe_reports_count, 2);
    else if kinda_safe_reports_count != 2    print("\e[31mTest 1: kinda_safe_reports_count: %, expected: %\e[0m\n", kinda_safe_reports_count, 2);
    else print("\e[32mTest 1: OK\e[0m\n");
    print("\n");
}

test2 :: () {
    input := #string DONE
0 1
1 4 5
1 1
8 1 3
8 1 9
0 0 1 2 3 4
9 1 5
0 0 0 1 2 4
DONE

    reports_count, safe_reports_count, kinda_safe_reports_count := work(input);
    if reports_count != 8                    print("\e[31mTest 2: reports_count: %, expected: %\e[0m\n", reports_count, 8);
    else if safe_reports_count != 2          print("\e[31mTest 2: safe_reports_count: %, expected: %\e[0m\n", safe_reports_count, 2);
    else if kinda_safe_reports_count != 4    print("\e[31mTest 2: kinda_safe_reports_count: %, expected: %\e[0m\n", kinda_safe_reports_count, 4);
    else print("\e[32mTest 2: OK\e[0m\n");
    print("\n");
}

test3 :: () {
    input := #string DONE
5 8 4 3 2 1
5 4 0 3 2 1
DONE

    reports_count, safe_reports_count, kinda_safe_reports_count := work(input);
    if reports_count != 2                    print("\e[31mTest 3: reports_count: %, expected: %\e[0m\n", reports_count, 2);
    else if safe_reports_count != 0          print("\e[31mTest 3: safe_reports_count: %, expected: %\e[0m\n", safe_reports_count, 0);
    else if kinda_safe_reports_count != 2    print("\e[31mTest 3: kinda_safe_reports_count: %, expected: %\e[0m\n", kinda_safe_reports_count, 2);
    else print("\e[32mTest 3: OK\e[0m\n");
    print("\n");
}
